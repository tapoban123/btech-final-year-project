import asyncio
import os
import logging
from datetime import datetime, timezone
from pathlib import Path
from typing import List
from uuid import uuid4

from fastapi import APIRouter, File, HTTPException, UploadFile, status

from models.document import (
    MULTI_FILE_UPLOAD_OPENAPI_EXTRA,
    DocumentsResponse,
    DocumentMetadata,
    DocumentBatchUploadResponse,
    DocumentUploadResponse,
    DocumentSearchRequest,
    DocumentSearchResponse,
    DocumentSearchResult,
)
from models.rag import (
    DocumentQueryRequest,
    MultiDocumentQueryResponse,
    QueryCitation,
)
from services.document_storage import DocumentStorage
from services.cloudinary_storage import CloudinaryStorage
from services.rag_pipeline import rag_pipeline

router = APIRouter(tags=["documents"])
storage = DocumentStorage()
cloudinary_storage = CloudinaryStorage()
logger = logging.getLogger(__name__)
MAX_PDF_SIZE = int(os.getenv("MAX_PDF_SIZE_MB", "25")) * 1024 * 1024
MAX_IMAGE_SIZE = int(os.getenv("MAX_IMAGE_SIZE_MB", "10")) * 1024 * 1024
MAX_CONCURRENT_UPLOADS = int(os.getenv("MAX_CONCURRENT_UPLOADS", "5"))
IMAGE_TYPES = {"image/png": ".png", "image/jpeg": ".jpg", "image/webp": ".webp"}
USER_ID = os.getenv("DUMMY_USER_ID", "local-test-user")


def _canonical_cloudinary_id(result: dict, expected_id: str) -> str:
    """Return the ID shared by Cloudinary, metadata, and Pinecone."""
    public_id = str(result.get("public_id") or expected_id).strip()
    if public_id.endswith(".tmp"):
        public_id = public_id[: -len(".tmp")]
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
    openapi_extra=MULTI_FILE_UPLOAD_OPENAPI_EXTRA,
)
async def upload_documents(
    files: List[UploadFile] = File(
        ...,
        description="One or more PDF or image files (PNG, JPEG, WebP). Select multiple files using the file picker.",
    ),
) -> DocumentBatchUploadResponse:
    """Upload and index one or more document files (PDF or PNG, JPEG, WebP images).

    Each file in the batch is processed independently:
    - PDFs: Signature-verified (`%PDF-`), stored in Cloudinary as raw assets, and text is extracted per-page via PyMuPDF.
    - Images: Validated by MIME type/extension, stored in Cloudinary as image assets, and contextual descriptions are generated via Gemini Vision.
    Extracted contents are chunked, embedded into Pinecone, and cataloged in Supabase.
    """
    if not files:
        raise _error("NO_FILES", "At least one document or image file is required", 400)

    semaphore = asyncio.Semaphore(MAX_CONCURRENT_UPLOADS)

    async def _bounded_upload(file: UploadFile) -> DocumentUploadResponse:
        async with semaphore:
            try:
                return await _upload_document(file)
            except Exception as exc:
                logger.exception(
                    "[UPLOAD] unhandled error processing %r: %s", file.filename, exc
                )
                return DocumentUploadResponse(
                    filename=file.filename or "",
                    content_type=file.content_type or "",
                    size_bytes=0,
                    status="failed",
                    message=f"Upload failed: {exc}",
                )

    results: list[DocumentUploadResponse] = list(
        await asyncio.gather(*[_bounded_upload(file) for file in files])
    )

    successful = sum(result.status in {"uploaded", "completed"} for result in results)
    return DocumentBatchUploadResponse(
        total_files=len(results),
        successful=successful,
        failed=len(results) - successful,
        results=results,
    )


async def _upload_document(file: UploadFile) -> DocumentUploadResponse:
    filename = file.filename or ""
    content_type = file.content_type or ""
    logger.info(
        "[UPLOAD] endpoint hit: filename=%r content_type=%r",
        filename,
        content_type,
    )
    if (content_type or "") in IMAGE_TYPES or Path(filename).suffix.lower() in {
        ".png",
        ".jpg",
        ".jpeg",
        ".webp",
    }:
        return await _upload_image(file)
    if not filename.lower().endswith(".pdf"):
        return DocumentUploadResponse(
            filename=filename,
            content_type=content_type,
            size_bytes=0,
            status="failed",
            message="Only PDF files are supported",
        )
    if content_type not in (
        None,
        "",
        "application/pdf",
        "application/octet-stream",
    ):
        return DocumentUploadResponse(
            filename=filename,
            content_type=content_type,
            size_bytes=0,
            status="failed",
            message="The uploaded file must have PDF content type",
        )

    try:
        file_bytes = await file.read()
    except Exception as exc:
        logger.exception(
            "[UPLOAD] failed reading bytes for filename=%r: %s", filename, exc
        )
        return DocumentUploadResponse(
            filename=filename,
            content_type=content_type,
            size_bytes=0,
            status="failed",
            message=f"Could not read the uploaded file: {exc}",
        )
    finally:
        await file.close()

    # Offload blocking PDF upload, Supabase metadata save, and RAG indexing to a worker thread
    return await asyncio.to_thread(
        _process_pdf_sync,
        filename=filename,
        content_type="application/pdf",
        file_bytes=file_bytes,
    )


def _process_pdf_sync(
    filename: str, content_type: str, file_bytes: bytes
) -> DocumentUploadResponse:
    document_id = str(uuid4())
    size_bytes = len(file_bytes)

    if size_bytes == 0:
        return DocumentUploadResponse(
            filename=filename,
            content_type=content_type,
            size_bytes=0,
            status="failed",
            message="The uploaded file is empty",
        )
    if not file_bytes.startswith(b"%PDF-"):
        return DocumentUploadResponse(
            filename=filename,
            content_type=content_type,
            size_bytes=0,
            status="failed",
            message="The file is not a valid PDF",
        )
    if size_bytes > MAX_PDF_SIZE:
        return DocumentUploadResponse(
            filename=filename,
            content_type=content_type,
            size_bytes=size_bytes,
            status="failed",
            message="The PDF exceeds the configured size limit",
        )

    logger.info(
        "[UPLOAD] received file in-memory: filename=%r size_bytes=%d",
        filename,
        size_bytes,
    )
    try:
        cloudinary_result = cloudinary_storage.upload(
            file_bytes,
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
            "cloudinary_url": cloudinary_result.get("secure_url")
            or cloudinary_result.get("url"),
            "cloudinary_asset_id": cloudinary_result.get("asset_id"),
            "cloudinary_resource_type": cloudinary_result.get("resource_type", "image"),
        }
        storage.save_metadata(metadata)
        try:
            rag_pipeline.prepare_document(
                user_id=USER_ID,
                document_id=cloudinary_public_id,
                document_name=Path(filename).name,
                file_data=file_bytes,
                content_type="application/pdf",
            )
        except Exception as exc:
            logger.exception("[RAG] processing failed for document_id=%s", document_id)
            try:
                rag_pipeline.delete_document(user_id=USER_ID, document_id=document_id)
            except Exception:
                logger.exception("[RAG] cleanup failed for document_id=%s", document_id)
            try:
                cloudinary_storage.delete(
                    public_id=cloudinary_public_id, content_type="application/pdf"
                )
            except Exception:
                logger.exception(
                    "[Cloudinary] cleanup failed for document_id=%s", document_id
                )
            storage.update_metadata(
                document_id, status="failed", error_message=str(exc)
            )
            return DocumentUploadResponse(
                id=document_id,
                document_id=document_id,
                filename=Path(filename).name,
                content_type="application/pdf",
                size_bytes=size_bytes,
                status="failed",
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
    except Exception as exc:
        logger.exception(
            "[UPLOAD] unexpected exception for filename=%r: %s", filename, exc
        )
        return DocumentUploadResponse(
            filename=filename,
            content_type=content_type,
            size_bytes=size_bytes,
            status="failed",
            message="Could not process the uploaded file",
        )


async def _upload_image(file: UploadFile) -> DocumentUploadResponse:
    filename = Path(file.filename or "").name
    content_type = file.content_type or ""
    if content_type not in IMAGE_TYPES:
        return DocumentUploadResponse(
            filename=filename,
            content_type=content_type,
            size_bytes=0,
            status="failed",
            message="Only PNG, JPEG, and WebP images are supported",
        )
    try:
        file_bytes = await file.read()
    except Exception as exc:
        logger.exception(
            "[UPLOAD] failed reading image bytes for filename=%r: %s", filename, exc
        )
        return DocumentUploadResponse(
            filename=filename,
            content_type=content_type,
            size_bytes=0,
            status="failed",
            message=f"Could not read the uploaded image: {exc}",
        )
    finally:
        await file.close()

    # Offload blocking image upload, Gemini vision, and RAG indexing to a worker thread
    return await asyncio.to_thread(
        _process_image_sync,
        filename=filename,
        content_type=content_type,
        file_bytes=file_bytes,
    )


def _process_image_sync(
    filename: str, content_type: str, file_bytes: bytes
) -> DocumentUploadResponse:
    document_id = str(uuid4())
    size_bytes = len(file_bytes)
    if size_bytes == 0:
        return DocumentUploadResponse(
            filename=filename,
            content_type=content_type,
            size_bytes=0,
            status="failed",
            message="The image file is empty",
        )
    if size_bytes > MAX_IMAGE_SIZE:
        return DocumentUploadResponse(
            filename=filename,
            content_type=content_type,
            size_bytes=size_bytes,
            status="failed",
            message="The image exceeds the configured size limit",
        )
    try:
        cloudinary_result = cloudinary_storage.upload(
            file_bytes,
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
            "id": document_id,
            "document_id": document_id,
            "user_id": USER_ID,
            "original_filename": filename,
            "stored_filename": None,
            "content_type": content_type,
            "size_bytes": size_bytes,
            "status": "processing",
            "cloudinary_public_id": cloudinary_public_id,
            "cloudinary_url": cloudinary_result.get("secure_url")
            or cloudinary_result.get("url"),
            "cloudinary_asset_id": cloudinary_result.get("asset_id"),
            "cloudinary_resource_type": cloudinary_result.get("resource_type", "image"),
        }
        storage.save_metadata(metadata)
        try:
            rag_pipeline.prepare_document(
                user_id=USER_ID,
                document_id=cloudinary_public_id,
                document_name=filename,
                file_data=file_bytes,
                content_type=content_type,
            )
        except Exception as exc:
            logger.exception(
                "[RAG] image processing failed for document_id=%s", document_id
            )
            try:
                rag_pipeline.delete_document(user_id=USER_ID, document_id=document_id)
            except Exception:
                logger.exception(
                    "[RAG] image cleanup failed for document_id=%s", document_id
                )
            try:
                cloudinary_storage.delete(
                    public_id=cloudinary_public_id, content_type=content_type
                )
            except Exception:
                logger.exception(
                    "[Cloudinary] image cleanup failed for document_id=%s", document_id
                )
            storage.update_metadata(
                document_id, status="failed", error_message=str(exc)
            )
            return DocumentUploadResponse(
                id=document_id,
                document_id=document_id,
                filename=filename,
                content_type=content_type,
                size_bytes=size_bytes,
                status="failed",
                message=f"Could not process the image: {exc}",
                cloudinary_public_id=metadata.get("cloudinary_public_id"),
            )
        storage.update_metadata(document_id, status="completed")
        return DocumentUploadResponse(
            id=document_id,
            document_id=document_id,
            filename=filename,
            content_type=content_type,
            size_bytes=size_bytes,
            status="completed",
            message="Document uploaded and indexed successfully",
            cloudinary_public_id=metadata["cloudinary_public_id"],
        )
    except RuntimeError as exc:
        logger.exception(
            "[UPLOAD] image configuration error for filename=%r: %s", filename, exc
        )
        return DocumentUploadResponse(
            filename=filename,
            content_type=content_type,
            size_bytes=size_bytes,
            status="failed",
            message=str(exc),
        )
    except Exception as exc:
        logger.exception(
            "[UPLOAD] unexpected image processing failed for filename=%r: %s",
            filename,
            exc,
        )
        return DocumentUploadResponse(
            filename=filename,
            content_type=content_type,
            size_bytes=size_bytes,
            status="failed",
            message=f"Could not process the image: {exc}",
        )


@router.post(
    "/documents/query",
    response_model=MultiDocumentQueryResponse,
    status_code=status.HTTP_200_OK,
)
def query_documents(request: DocumentQueryRequest) -> MultiDocumentQueryResponse:
    try:
        result = rag_pipeline.ask(user_id=USER_ID, query=request.query)
    except RuntimeError as exc:
        raise _error("RAG_NOT_CONFIGURED", str(exc), 503) from exc
    except Exception as exc:
        logger.exception("[RAG] query failed")
        raise _error("RAG_QUERY_FAILED", "Could not answer the question", 500) from exc

    raw_sources = result.get("sources", [])
    source_doc_ids: list[str] = []
    for source in raw_sources:
        doc_id = source.get("document_id")
        if doc_id and doc_id not in source_doc_ids:
            source_doc_ids.append(doc_id)

    try:
        records = storage.get_metadata_for_ids(source_doc_ids, USER_ID)
    except Exception as exc:
        logger.warning("[RAG] failed to fetch document metadata: %s", exc)
        records = []

    records_by_id = {record["document_id"]: record for record in records}

    citations = [
        QueryCitation(
            document_id=source.get("document_id", ""),
            document_name=source.get("document_name", ""),
            page=source.get("page", 0),
            snippet=source.get("snippet"),
            cloudinary_url=records_by_id.get(source.get("document_id", ""), {}).get(
                "cloudinary_url"
            ),
            mime_type=(
                records_by_id.get(source.get("document_id", ""), {}).get("mime_type")
                or records_by_id.get(source.get("document_id", ""), {}).get("content_type")
            ),
        )
        for source in raw_sources
    ]

    matched_documents: list[DocumentMetadata] = []
    for doc_id in source_doc_ids:
        if doc_id in records_by_id:
            rec = records_by_id[doc_id]
            matched_documents.append(
                DocumentMetadata(
                    document_id=doc_id,
                    filename=rec.get("original_filename") or rec.get("filename") or "Unknown",
                    size_bytes=rec.get("size_bytes") or 0,
                    status=rec.get("status") or "completed",
                    created_at=rec.get("created_at") or datetime.now(timezone.utc),
                    cloudinary_url=rec.get("cloudinary_url"),
                    mime_type=rec.get("mime_type") or rec.get("content_type"),
                )
            )
        else:
            doc_name = next(
                (s.get("document_name") for s in raw_sources if s.get("document_id") == doc_id),
                "Unknown",
            )
            matched_documents.append(
                DocumentMetadata(
                    document_id=doc_id,
                    filename=doc_name or "Unknown",
                    size_bytes=0,
                    status="unknown",
                    created_at=datetime.now(timezone.utc),
                    cloudinary_url=None,
                    mime_type=None,
                )
            )

    return MultiDocumentQueryResponse(
        answer=result.get("answer", ""),
        sources=citations,
        documents=matched_documents,
    )


@router.post("/documents/search", response_model=DocumentSearchResponse)
def search_documents(request: DocumentSearchRequest) -> DocumentSearchResponse:
    """Return unique, user-owned documents matching a semantic query."""
    logger.info(
        "[SEARCH] endpoint received query_length=%d user_id=%s",
        len(request.query),
        USER_ID,
    )
    try:
        ranked_matches = rag_pipeline.search_documents(
            user_id=USER_ID, query=request.query
        )
        ranked_ids = [item["document_id"] for item in ranked_matches]
        logger.info("[SEARCH] fetching Supabase records for ranked_ids=%r", ranked_ids)
        records = storage.get_metadata_for_ids(ranked_ids, USER_ID)
        logger.info("[SEARCH] Supabase returned %d records", len(records))
    except RuntimeError as exc:
        raise _error("DOCUMENT_SEARCH_NOT_CONFIGURED", str(exc), 503) from exc
    except Exception as exc:
        logger.exception("[SEARCH] document search failed")
        raise _error(
            "DOCUMENT_SEARCH_FAILED", "Could not search documents", 500
        ) from exc

    records_by_id = {record["document_id"]: record for record in records}
    scores_by_id = {item["document_id"]: item["score"] for item in ranked_matches}
    return DocumentSearchResponse(
        query=request.query,
        documents=[
            DocumentSearchResult(
                document_id=document_id,
                filename=records_by_id[document_id]["original_filename"],
                cloudinary_url=records_by_id[document_id].get("cloudinary_url"),
                score=scores_by_id.get(document_id),
            )
            for document_id in ranked_ids
            if document_id in records_by_id
        ],
    )


@router.get("/documents", response_model=DocumentsResponse)
def list_documents() -> DocumentsResponse:
    try:
        return DocumentsResponse(
            documents=[
                DocumentMetadata(
                    document_id=item["id"],
                    filename=item["original_filename"],
                    size_bytes=item["size_bytes"],
                    status=item["status"],
                    created_at=item["created_at"],
                    cloudinary_url=item.get("cloudinary_url"),
                    mime_type=item.get("mime_type") or item.get("content_type"),
                )
                for item in storage.list_metadata(USER_ID)
            ]
        )
    except RuntimeError as exc:
        raise _error("STORAGE_NOT_CONFIGURED", str(exc), 503) from exc
    except Exception as exc:
        logger.exception("[STORAGE] list documents failed")
        raise _error(
            "LIST_DOCUMENTS_FAILED", "Could not fetch document list", 500
        ) from exc


@router.delete("/documents/{document_id}")
def delete_document(document_id: str) -> dict[str, str]:
    try:
        record = storage.get_metadata(document_id, USER_ID)
    except RuntimeError as exc:
        raise _error("STORAGE_NOT_CONFIGURED", str(exc), 503) from exc
    except Exception as exc:
        logger.exception(
            "[STORAGE] get metadata failed for document_id=%s", document_id
        )
        raise _error(
            "DOCUMENT_FETCH_FAILED", "Could not fetch document metadata", 500
        ) from exc

    if record is None:
        raise _error("DOCUMENT_NOT_FOUND", "The requested document does not exist", 404)
    try:
        rag_pipeline.delete_document(user_id=USER_ID, document_id=document_id)
        if record.get("cloudinary_public_id"):
            cloudinary_storage.delete(
                public_id=record["cloudinary_public_id"],
                content_type=record.get("content_type", "application/pdf"),
                resource_type=record.get("cloudinary_resource_type"),
            )
        storage.delete_document_metadata(document_id, USER_ID)
    except Exception as exc:
        logger.exception(
            "[DELETE] document deletion failed for document_id=%s", document_id
        )
        raise _error("DELETE_FAILED", "Could not delete the document", 500) from exc
    return {"document_id": document_id, "status": "deleted"}
