import os
import logging
import tempfile
from datetime import datetime, timezone
from pathlib import Path
from typing import List
from uuid import uuid4

from fastapi import APIRouter, File, Form, HTTPException, UploadFile, status

from models.document import (
    CollectionDocumentResponse,
    CollectionDocumentsResponse,
    DocumentBatchUploadResponse,
    DocumentUploadResponse,
)
from models.rag import DocumentQueryRequest, DocumentQueryResponse, MultiDocumentQueryResponse
from services.document_storage import DocumentStorage
from services.rag_pipeline import rag_pipeline

router = APIRouter(tags=["documents"])
storage = DocumentStorage()
logger = logging.getLogger(__name__)
MAX_PDF_SIZE = int(os.getenv("MAX_PDF_SIZE_MB", "25")) * 1024 * 1024
MAX_IMAGE_SIZE = int(os.getenv("MAX_IMAGE_SIZE_MB", "10")) * 1024 * 1024
IMAGE_TYPES = {"image/png": ".png", "image/jpeg": ".jpg", "image/webp": ".webp"}


def _error(code: str, message: str, http_status: int) -> HTTPException:
    return HTTPException(
        status_code=http_status,
        detail={"code": code, "message": message},
    )


@router.post(
    "/documents/upload",
    response_model=DocumentBatchUploadResponse,
    status_code=status.HTTP_201_CREATED,
    openapi_extra={
        "requestBody": {
            "content": {
                "multipart/form-data": {
                    "schema": {
                        "type": "object",
                        "required": ["files"],
                        "properties": {
                            "collection_id": {
                                "type": "string",
                                "description": "Existing collection to append to; omit to create one.",
                            },
                            "files": {
                                "type": "array",
                                "items": {"type": "string", "format": "binary"},
                            },
                        },
                    }
                }
            }
        }
    },
)
async def upload_documents(
    collection_id: str | None = Form(None),
    files: List[UploadFile] = File(
        ...,
        description="One or more PDF files. Select multiple files using the file picker.",
    ),
) -> DocumentBatchUploadResponse:
    if not files:
        raise _error("NO_FILES", "At least one PDF file is required", 400)
    requested_collection_id = collection_id
    collection_id = collection_id or f"collection_{uuid4().hex}"
    if requested_collection_id and not storage.collection_exists(collection_id):
        raise _error("COLLECTION_NOT_FOUND", "The requested collection does not exist", 404)
    results: list[DocumentUploadResponse] = []
    for file in files:
        results.append(await _upload_document(file, collection_id))

    successful = sum(result.status == "uploaded" for result in results)
    return DocumentBatchUploadResponse(
        collection_id=collection_id,
        total_files=len(results),
        successful=successful,
        failed=len(results) - successful,
        results=results,
    )


async def _upload_document(file: UploadFile, collection_id: str) -> DocumentUploadResponse:
    filename = file.filename or ""
    logger.info(
        "[UPLOAD] endpoint hit: filename=%r content_type=%r storage_dir=%s",
        filename,
        file.content_type,
        storage.upload_dir.resolve(),
    )
    if not filename.lower().endswith(".pdf"):
        return DocumentUploadResponse(
            filename=filename,
            content_type=file.content_type or "",
            size_bytes=0,
            status="failed",
            message="Only PDF files are supported",
        )
    if file.content_type not in (None, "", "application/pdf", "application/octet-stream"):
        return DocumentUploadResponse(
            filename=filename,
            content_type=file.content_type or "",
            size_bytes=0,
            status="failed",
            message="The uploaded file must have PDF content type",
        )

    document_id = f"doc_{uuid4().hex}"
    temporary_path: Path | None = None
    size_bytes = 0

    try:
        with tempfile.NamedTemporaryFile(
            mode="wb", prefix=f"{document_id}_", suffix=".tmp", dir=storage.upload_dir, delete=False
        ) as temporary:
            temporary_path = Path(temporary.name)
            first_chunk = await file.read(8192)
            if not first_chunk:
                return DocumentUploadResponse(
                    filename=filename,
                    content_type=file.content_type or "",
                    size_bytes=0,
                    status="failed",
                    message="The uploaded file is empty",
                )
            if not first_chunk.startswith(b"%PDF-"):
                return DocumentUploadResponse(
                    filename=filename,
                    content_type=file.content_type or "",
                    size_bytes=0,
                    status="failed",
                    message="The file is not a valid PDF",
                )
            temporary.write(first_chunk)
            size_bytes = len(first_chunk)

            while True:
                chunk = await file.read(1024 * 1024)
                if not chunk:
                    break
                size_bytes += len(chunk)
                if size_bytes > MAX_PDF_SIZE:
                    return DocumentUploadResponse(
                        filename=filename,
                        content_type=file.content_type or "",
                        size_bytes=size_bytes,
                        status="failed",
                        message="The PDF exceeds the configured size limit",
                    )
                temporary.write(chunk)

        final_path = storage.upload_dir / f"{document_id}.pdf"
        logger.info("[UPLOAD] received file: filename=%r size_bytes=%d", filename, size_bytes)
        logger.info("[UPLOAD] destination storage directory: %s", storage.upload_dir.resolve())
        logger.info("[UPLOAD] final saved file path: %s", final_path.resolve())
        temporary_path.replace(final_path)
        logger.info("[UPLOAD] file saved successfully: %s", final_path.resolve())
        metadata = {
            "id": document_id,
            "document_id": document_id,
            "collection_id": collection_id,
            "original_filename": Path(filename).name,
            "stored_filename": final_path.name,
            "content_type": "application/pdf",
            "size_bytes": size_bytes,
            "status": "uploaded",
            "created_at": datetime.now(timezone.utc).isoformat(),
        }
        storage.save_metadata(metadata)
        try:
            rag_pipeline.prepare_document(
                collection_id=collection_id,
                document_id=document_id,
                document_name=Path(filename).name,
                file_path=final_path,
                content_type="application/pdf",
            )
        except Exception as exc:
            logger.exception("[RAG] processing failed for document_id=%s", document_id)
            try:
                rag_pipeline.delete_document(collection_id=collection_id, document_id=document_id)
            except Exception:
                logger.exception("[RAG] cleanup failed for document_id=%s", document_id)
            final_path.unlink(missing_ok=True)
            storage.delete_document_metadata(document_id)
            return DocumentUploadResponse(
                id=document_id, document_id=document_id, collection_id=collection_id,
                filename=Path(filename).name, content_type="application/pdf",
                size_bytes=size_bytes, status="failed",
                message=f"Could not process the PDF: {exc}",
            )
        return DocumentUploadResponse(
            id=document_id,
            document_id=document_id,
            collection_id=collection_id,
            filename=Path(filename).name,
            content_type="application/pdf",
            size_bytes=size_bytes,
            status="uploaded",
            message="PDF uploaded successfully",
        )
    except OSError as exc:
        logger.exception("[UPLOAD] storage exception for filename=%r: %s", filename, exc)
        return DocumentUploadResponse(
            filename=filename,
            content_type=file.content_type or "",
            size_bytes=size_bytes,
            status="failed",
            message=f"Could not store the PDF: {exc}",
        )
    except Exception as exc:
        logger.exception("[UPLOAD] unexpected exception for filename=%r: %s", filename, exc)
        return DocumentUploadResponse(
            filename=filename,
            content_type=file.content_type or "",
            size_bytes=size_bytes,
            status="failed",
            message="Could not process the uploaded file",
        )
    finally:
        if temporary_path is not None and temporary_path.exists():
            temporary_path.unlink(missing_ok=True)
        await file.close()


@router.post(
    "/documents/images/upload",
    response_model=DocumentBatchUploadResponse,
    status_code=status.HTTP_201_CREATED,
    openapi_extra={
        "requestBody": {
            "content": {
                "multipart/form-data": {
                    "schema": {
                        "type": "object",
                        "required": ["files"],
                        "properties": {
                            "collection_id": {
                                "type": "string",
                                "description": "Existing collection to append to; omit to create one.",
                            },
                            "files": {
                                "type": "array",
                                "items": {"type": "string", "format": "binary"},
                                "description": "One or more PNG, JPEG, or WebP images.",
                            },
                        },
                    }
                }
            }
        }
    },
)
async def upload_images(
    collection_id: str | None = Form(None),
    files: List[UploadFile] = File(..., description="One or more PNG, JPEG, or WebP images."),
) -> DocumentBatchUploadResponse:
    requested_collection_id = collection_id
    collection_id = collection_id or f"collection_{uuid4().hex}"
    if requested_collection_id and not storage.collection_exists(collection_id):
        raise _error("COLLECTION_NOT_FOUND", "The requested collection does not exist", 404)
    if not files:
        raise _error("NO_FILES", "At least one image file is required", 400)
    results = [await _upload_image(file, collection_id) for file in files]
    successful = sum(result.status == "uploaded" for result in results)
    return DocumentBatchUploadResponse(
        collection_id=collection_id,
        total_files=len(results),
        successful=successful,
        failed=len(results) - successful,
        results=results,
    )


async def _upload_image(file: UploadFile, collection_id: str) -> DocumentUploadResponse:
    filename = Path(file.filename or "").name
    content_type = file.content_type or ""
    if content_type not in IMAGE_TYPES:
        return DocumentUploadResponse(filename=filename, content_type=content_type, size_bytes=0,
                                      status="failed", message="Only PNG, JPEG, and WebP images are supported")
    document_id = f"doc_{uuid4().hex}"
    temporary_path: Path | None = None
    size_bytes = 0
    final_path = storage.upload_dir / f"{document_id}{IMAGE_TYPES[content_type]}"
    try:
        with tempfile.NamedTemporaryFile(mode="wb", prefix=f"{document_id}_", suffix=".tmp",
                                         dir=storage.upload_dir, delete=False) as temporary:
            temporary_path = Path(temporary.name)
            while True:
                chunk = await file.read(1024 * 1024)
                if not chunk:
                    break
                size_bytes += len(chunk)
                if size_bytes > MAX_IMAGE_SIZE:
                    return DocumentUploadResponse(filename=filename, content_type=content_type,
                                                  size_bytes=size_bytes, status="failed",
                                                  message="The image exceeds the configured size limit")
                temporary.write(chunk)
        if size_bytes == 0:
            return DocumentUploadResponse(filename=filename, content_type=content_type, size_bytes=0,
                                          status="failed", message="The image file is empty")
        temporary_path.replace(final_path)
        metadata = {
            "id": document_id, "document_id": document_id, "collection_id": collection_id,
            "original_filename": filename, "stored_filename": final_path.name,
            "content_type": content_type, "size_bytes": size_bytes, "status": "uploaded",
            "created_at": datetime.now(timezone.utc).isoformat(),
        }
        storage.save_metadata(metadata)
        try:
            rag_pipeline.prepare_document(collection_id=collection_id, document_id=document_id,
                                          document_name=filename, file_path=final_path,
                                          content_type=content_type)
        except Exception as exc:
            logger.exception("[RAG] image processing failed for document_id=%s", document_id)
            try:
                rag_pipeline.delete_document(collection_id=collection_id, document_id=document_id)
            except Exception:
                logger.exception("[RAG] image cleanup failed for document_id=%s", document_id)
            final_path.unlink(missing_ok=True)
            storage.delete_document_metadata(document_id)
            return DocumentUploadResponse(id=document_id, document_id=document_id, collection_id=collection_id,
                                          filename=filename, content_type=content_type, size_bytes=size_bytes,
                                          status="failed", message=f"Could not process the image: {exc}")
        return DocumentUploadResponse(id=document_id, document_id=document_id, collection_id=collection_id,
                                      filename=filename, content_type=content_type, size_bytes=size_bytes,
                                      status="uploaded", message="Image analyzed and indexed successfully")
    except OSError as exc:
        logger.exception("[UPLOAD] image storage failed for filename=%r", filename)
        return DocumentUploadResponse(filename=filename, content_type=content_type, size_bytes=size_bytes,
                                      status="failed", message=f"Could not store the image: {exc}")
    finally:
        if temporary_path is not None and temporary_path.exists():
            temporary_path.unlink(missing_ok=True)
        await file.close()


@router.post(
    "/documents/query",
    response_model=MultiDocumentQueryResponse,
    status_code=status.HTTP_200_OK,
)
def query_documents(request: DocumentQueryRequest) -> MultiDocumentQueryResponse:
    if not storage.collection_exists(request.collection_id):
        raise _error("COLLECTION_NOT_FOUND", "The requested collection does not exist", 404)
    try:
        result = rag_pipeline.ask(collection_id=request.collection_id, query=request.query)
    except RuntimeError as exc:
        raise _error("RAG_NOT_CONFIGURED", str(exc), 503) from exc
    except Exception as exc:
        logger.exception("[RAG] query failed for collection_id=%s", request.collection_id)
        raise _error("RAG_QUERY_FAILED", "Could not answer the question", 500) from exc
    return MultiDocumentQueryResponse(collection_id=request.collection_id, **result)


@router.get("/collections/{collection_id}/documents", response_model=CollectionDocumentsResponse)
def list_collection_documents(collection_id: str) -> CollectionDocumentsResponse:
    records = storage.list_collection_metadata(collection_id)
    if not records:
        raise _error("COLLECTION_NOT_FOUND", "The requested collection does not exist", 404)
    return CollectionDocumentsResponse(
        collection_id=collection_id,
        documents=[CollectionDocumentResponse(
            document_id=item["id"], collection_id=collection_id,
            filename=item["original_filename"], size_bytes=item["size_bytes"],
            status=item["status"], created_at=item["created_at"],
        ) for item in records],
    )


@router.delete("/collections/{collection_id}/documents/{document_id}")
def delete_collection_document(collection_id: str, document_id: str) -> dict[str, str]:
    record = next((item for item in storage.list_collection_metadata(collection_id)
                   if item.get("id") == document_id), None)
    if record is None:
        raise _error("DOCUMENT_NOT_FOUND", "The requested document does not exist in this collection", 404)
    try:
        rag_pipeline.delete_document(collection_id=collection_id, document_id=document_id)
        storage.document_path(document_id, record.get("stored_filename")).unlink(missing_ok=True)
        storage.delete_document_metadata(document_id)
    except Exception as exc:
        logger.exception("[RAG] document deletion failed for document_id=%s", document_id)
        raise _error("DELETE_FAILED", "Could not delete the document", 500) from exc
    return {"collection_id": collection_id, "document_id": document_id, "status": "deleted"}


@router.delete("/collections/{collection_id}")
def delete_collection(collection_id: str) -> dict[str, str]:
    records = storage.list_collection_metadata(collection_id)
    if not records:
        raise _error("COLLECTION_NOT_FOUND", "The requested collection does not exist", 404)
    try:
        rag_pipeline.delete_collection(collection_id)
        for record in records:
            storage.document_path(record["id"], record.get("stored_filename")).unlink(missing_ok=True)
        storage.delete_collection_metadata(collection_id)
    except Exception as exc:
        logger.exception("[RAG] collection deletion failed for collection_id=%s", collection_id)
        raise _error("DELETE_FAILED", "Could not delete the collection", 500) from exc
    return {"collection_id": collection_id, "status": "deleted"}
