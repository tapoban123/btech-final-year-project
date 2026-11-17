import os
import logging
import tempfile
from pathlib import Path
from typing import List
from uuid import uuid4

from fastapi import APIRouter, File, HTTPException, UploadFile, status

from models.document import (
    DocumentsResponse,
    DocumentMetadata,
    DocumentBatchUploadResponse,
    DocumentUploadResponse,
    DocumentSearchRequest,
    DocumentSearchResponse,
    DocumentSearchResult,
)
from models.rag import DocumentQueryRequest, MultiDocumentQueryResponse
from services.document_storage import DocumentStorage
from services.cloudinary_storage import CloudinaryStorage
from services.rag_pipeline import rag_pipeline

router = APIRouter(tags=["documents"])
storage = DocumentStorage()
cloudinary_storage = CloudinaryStorage()
logger = logging.getLogger(__name__)
MAX_PDF_SIZE = int(os.getenv("MAX_PDF_SIZE_MB", "25")) * 1024 * 1024
MAX_IMAGE_SIZE = int(os.getenv("MAX_IMAGE_SIZE_MB", "10")) * 1024 * 1024
IMAGE_TYPES = {"image/png": ".png", "image/jpeg": ".jpg", "image/webp": ".webp"}
USER_ID = os.getenv("DUMMY_USER_ID", "local-test-user")


def _canonical_cloudinary_id(result: dict, expected_id: str) -> str:
    """Return the ID shared by Cloudinary, metadata, and Pinecone."""
    public_id = str(result.get("public_id") or expected_id).strip()
    if public_id.endswith(".tmp"):
        public_id = public_id[:-len(".tmp")]
    if public_id != expected_id:
        raise RuntimeError(
            f"Cloudinary returned public_id={public_id!r}; expected {expected_id!r}"
        )
    return public_id


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
    files: List[UploadFile] = File(
        ...,
        description="One or more PDF files. Select multiple files using the file picker.",
    ),
) -> DocumentBatchUploadResponse:
    if not files:
        raise _error("NO_FILES", "At least one PDF file is required", 400)
    results: list[DocumentUploadResponse] = []
    for file in files:
        results.append(await _upload_document(file))

    successful = sum(result.status in {"uploaded", "completed"} for result in results)
    return DocumentBatchUploadResponse(
        total_files=len(results),
        successful=successful,
        failed=len(results) - successful,
        results=results,
    )


async def _upload_document(file: UploadFile) -> DocumentUploadResponse:
    filename = file.filename or ""
    logger.info("[UPLOAD] endpoint hit: filename=%r content_type=%r", filename, file.content_type)
    if (file.content_type or "") in IMAGE_TYPES or Path(filename).suffix.lower() in {".png", ".jpg", ".jpeg", ".webp"}:
        return await _upload_image(file)
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

    document_id = str(uuid4())
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

        logger.info("[UPLOAD] received file: filename=%r size_bytes=%d", filename, size_bytes)
        cloudinary_result = cloudinary_storage.upload(
            temporary_path,
            public_id=document_id,
            content_type="application/pdf",
            context={
                "document_id": document_id,
                "original_filename": Path(filename).name,
                "content_type": "application/pdf",
            },
            tags=["document", "pdf"],
        )
        cloudinary_public_id = _canonical_cloudinary_id(cloudinary_result, document_id)
        metadata = {
            "id": document_id,
            "document_id": document_id,
            "user_id": USER_ID,
            "original_filename": Path(filename).name,
            "stored_filename": None,
            "content_type": "application/pdf",
            "size_bytes": size_bytes,
            "status": "processing",
            "cloudinary_public_id": cloudinary_public_id,
            "cloudinary_url": cloudinary_result.get("secure_url") or cloudinary_result.get("url"),
            "cloudinary_asset_id": cloudinary_result.get("asset_id"),
            "cloudinary_resource_type": cloudinary_result.get("resource_type", "raw"),
        }
        storage.save_metadata(metadata)
        try:
            rag_pipeline.prepare_document(
                user_id=USER_ID,
                document_id=cloudinary_public_id,
                document_name=Path(filename).name,
                file_path=temporary_path,
                content_type="application/pdf",
            )
        except Exception as exc:
            logger.exception("[RAG] processing failed for document_id=%s", document_id)
            try:
                rag_pipeline.delete_document(user_id=USER_ID, document_id=document_id)
            except Exception:
                logger.exception("[RAG] cleanup failed for document_id=%s", document_id)
            try:
                cloudinary_storage.delete(public_id=cloudinary_public_id, content_type="application/pdf")
            except Exception:
                logger.exception("[Cloudinary] cleanup failed for document_id=%s", document_id)
            storage.update_metadata(document_id, status="failed", error_message=str(exc))
            return DocumentUploadResponse(
                id=document_id, document_id=document_id,
                filename=Path(filename).name, content_type="application/pdf",
                size_bytes=size_bytes, status="failed",
                message=f"Could not process the PDF: {exc}",
                cloudinary_public_id=metadata.get("cloudinary_public_id"),
            )
        storage.update_metadata(document_id, status="completed")
        return DocumentUploadResponse(
            id=document_id,
            document_id=document_id,
            filename=Path(filename).name,
            content_type="application/pdf",
            size_bytes=size_bytes,
            status="completed",
            message="Document uploaded and indexed successfully",
            cloudinary_public_id=metadata["cloudinary_public_id"],
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
    files: List[UploadFile] = File(..., description="One or more PNG, JPEG, or WebP images."),
) -> DocumentBatchUploadResponse:
    if not files:
        raise _error("NO_FILES", "At least one image file is required", 400)
    results = [await _upload_image(file) for file in files]
    successful = sum(result.status in {"uploaded", "completed"} for result in results)
    return DocumentBatchUploadResponse(
        total_files=len(results),
        successful=successful,
        failed=len(results) - successful,
        results=results,
    )


async def _upload_image(file: UploadFile) -> DocumentUploadResponse:
    filename = Path(file.filename or "").name
    content_type = file.content_type or ""
    if content_type not in IMAGE_TYPES:
        return DocumentUploadResponse(filename=filename, content_type=content_type, size_bytes=0,
                                      status="failed", message="Only PNG, JPEG, and WebP images are supported")
    document_id = str(uuid4())
    temporary_path: Path | None = None
    size_bytes = 0
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
        cloudinary_result = cloudinary_storage.upload(
            temporary_path,
            public_id=document_id,
            content_type=content_type,
            context={
                "document_id": document_id,
                "original_filename": filename,
                "content_type": content_type,
            },
            tags=["document", "image"],
        )
        cloudinary_public_id = _canonical_cloudinary_id(cloudinary_result, document_id)
        metadata = {
            "id": document_id, "document_id": document_id,
            "user_id": USER_ID,
            "original_filename": filename, "stored_filename": None,
            "content_type": content_type, "size_bytes": size_bytes, "status": "processing",
            "cloudinary_public_id": cloudinary_public_id,
            "cloudinary_url": cloudinary_result.get("secure_url") or cloudinary_result.get("url"),
            "cloudinary_asset_id": cloudinary_result.get("asset_id"),
            "cloudinary_resource_type": cloudinary_result.get("resource_type", "image"),
        }
        storage.save_metadata(metadata)
        try:
            rag_pipeline.prepare_document(user_id=USER_ID, document_id=cloudinary_public_id,
                                          document_name=filename, file_path=temporary_path,
                                          content_type=content_type)
        except Exception as exc:
            logger.exception("[RAG] image processing failed for document_id=%s", document_id)
            try:
                rag_pipeline.delete_document(user_id=USER_ID, document_id=document_id)
            except Exception:
                logger.exception("[RAG] image cleanup failed for document_id=%s", document_id)
            try:
                cloudinary_storage.delete(public_id=cloudinary_public_id, content_type=content_type)
            except Exception:
                logger.exception("[Cloudinary] image cleanup failed for document_id=%s", document_id)
            storage.update_metadata(document_id, status="failed", error_message=str(exc))
            return DocumentUploadResponse(id=document_id, document_id=document_id,
                                          filename=filename, content_type=content_type, size_bytes=size_bytes,
                                          status="failed", message=f"Could not process the image: {exc}",
                                          cloudinary_public_id=metadata.get("cloudinary_public_id"))
        storage.update_metadata(document_id, status="completed")
        return DocumentUploadResponse(id=document_id, document_id=document_id,
                                      filename=filename, content_type=content_type, size_bytes=size_bytes,
                                      status="completed", message="Document uploaded and indexed successfully",
                                      cloudinary_public_id=metadata["cloudinary_public_id"])
    except OSError as exc:
        logger.exception("[UPLOAD] image storage failed for filename=%r", filename)
        return DocumentUploadResponse(filename=filename, content_type=content_type, size_bytes=size_bytes,
                                      status="failed", message=f"Could not store the image: {exc}")
    finally:
        if temporary_path is not None and temporary_path.exists():
            temporary_path.unlink(missing_ok=True)
        await file.close()


@router.post("/documents/query", response_model=MultiDocumentQueryResponse, status_code=status.HTTP_200_OK)
def query_documents(request: DocumentQueryRequest) -> MultiDocumentQueryResponse:
    try:
        result = rag_pipeline.ask(user_id=USER_ID, query=request.query)
    except RuntimeError as exc:
        raise _error("RAG_NOT_CONFIGURED", str(exc), 503) from exc
    except Exception as exc:
        logger.exception("[RAG] query failed")
        raise _error("RAG_QUERY_FAILED", "Could not answer the question", 500) from exc
    return MultiDocumentQueryResponse(**result)


@router.post("/documents/search", response_model=DocumentSearchResponse)
def search_documents(request: DocumentSearchRequest) -> DocumentSearchResponse:
    """Return unique, user-owned documents matching a semantic query."""
    logger.info("[SEARCH] endpoint received query_length=%d user_id=%s", len(request.query), USER_ID)
    try:
        ranked_ids = rag_pipeline.search_document_ids(user_id=USER_ID, query=request.query)
        logger.info("[SEARCH] fetching Supabase records for ranked_ids=%r", ranked_ids)
        records = storage.get_metadata_for_ids(ranked_ids, USER_ID)
        logger.info("[SEARCH] Supabase returned %d records", len(records))
    except RuntimeError as exc:
        raise _error("DOCUMENT_SEARCH_NOT_CONFIGURED", str(exc), 503) from exc
    except Exception as exc:
        logger.exception("[SEARCH] document search failed")
        raise _error("DOCUMENT_SEARCH_FAILED", "Could not search documents", 500) from exc

    records_by_id = {record["document_id"]: record for record in records}
    return DocumentSearchResponse(
        query=request.query,
        documents=[
            DocumentSearchResult(
                document_id=document_id,
                filename=records_by_id[document_id]["original_filename"],
                cloudinary_url=records_by_id[document_id].get("cloudinary_url"),
            )
            for document_id in ranked_ids
            if document_id in records_by_id
        ],
    )


@router.get("/documents", response_model=DocumentsResponse)
def list_documents() -> DocumentsResponse:
    return DocumentsResponse(documents=[DocumentMetadata(
        document_id=item["id"], filename=item["original_filename"], size_bytes=item["size_bytes"],
        status=item["status"], created_at=item["created_at"],
    ) for item in storage.list_metadata(USER_ID)])


@router.delete("/documents/{document_id}")
def delete_document(document_id: str) -> dict[str, str]:
    record = storage.get_metadata(document_id, USER_ID)
    if record is None:
        raise _error("DOCUMENT_NOT_FOUND", "The requested document does not exist", 404)
    try:
        rag_pipeline.delete_document(user_id=USER_ID, document_id=document_id)
        if record.get("cloudinary_public_id"):
            cloudinary_storage.delete(public_id=record["cloudinary_public_id"],
                                      content_type=record.get("content_type", "application/pdf"))
        storage.delete_document_metadata(document_id, USER_ID)
    except Exception as exc:
        logger.exception("[DELETE] document deletion failed for document_id=%s", document_id)
        raise _error("DELETE_FAILED", "Could not delete the document", 500) from exc
    return {"document_id": document_id, "status": "deleted"}
