import os
import logging
import tempfile
from datetime import datetime, timezone
from pathlib import Path
from uuid import uuid4

from fastapi import APIRouter, File, HTTPException, UploadFile, status

from models.document import DocumentUploadResponse
from services.document_storage import DocumentStorage

router = APIRouter(tags=["documents"])
storage = DocumentStorage()
logger = logging.getLogger(__name__)
MAX_PDF_SIZE = int(os.getenv("MAX_PDF_SIZE_MB", "25")) * 1024 * 1024


def _error(code: str, message: str, http_status: int) -> HTTPException:
    return HTTPException(
        status_code=http_status,
        detail={"code": code, "message": message},
    )


@router.post(
    "/documents/upload",
    response_model=DocumentUploadResponse,
    status_code=status.HTTP_201_CREATED,
)
async def upload_document(file: UploadFile = File(...)) -> DocumentUploadResponse:
    filename = file.filename or ""
    logger.info(
        "[UPLOAD] endpoint hit: filename=%r content_type=%r storage_dir=%s",
        filename,
        file.content_type,
        storage.upload_dir.resolve(),
    )
    if not filename.lower().endswith(".pdf"):
        raise _error("INVALID_FILE_TYPE", "Only PDF files are supported", 415)
    if file.content_type not in (None, "", "application/pdf", "application/octet-stream"):
        raise _error("INVALID_FILE_TYPE", "The uploaded file must have PDF content type", 415)

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
                raise _error("INVALID_FILE", "The uploaded file is empty", 400)
            if not first_chunk.startswith(b"%PDF-"):
                raise _error("INVALID_FILE_TYPE", "The file is not a valid PDF", 415)
            temporary.write(first_chunk)
            size_bytes = len(first_chunk)

            while True:
                chunk = await file.read(1024 * 1024)
                if not chunk:
                    break
                size_bytes += len(chunk)
                if size_bytes > MAX_PDF_SIZE:
                    raise _error("FILE_TOO_LARGE", "The PDF exceeds the configured size limit", 413)
                temporary.write(chunk)

        final_path = storage.upload_dir / f"{document_id}.pdf"
        logger.info("[UPLOAD] received file: filename=%r size_bytes=%d", filename, size_bytes)
        logger.info("[UPLOAD] destination storage directory: %s", storage.upload_dir.resolve())
        logger.info("[UPLOAD] final saved file path: %s", final_path.resolve())
        temporary_path.replace(final_path)
        logger.info("[UPLOAD] file saved successfully: %s", final_path.resolve())
        metadata = {
            "id": document_id,
            "original_filename": Path(filename).name,
            "stored_filename": final_path.name,
            "content_type": "application/pdf",
            "size_bytes": size_bytes,
            "status": "uploaded",
            "created_at": datetime.now(timezone.utc).isoformat(),
        }
        storage.save_metadata(metadata)
        return DocumentUploadResponse(
            id=document_id,
            filename=Path(filename).name,
            content_type="application/pdf",
            size_bytes=size_bytes,
            status="uploaded",
            message="PDF uploaded successfully",
        )
    except HTTPException as exc:
        logger.warning("[UPLOAD] rejected: filename=%r status=%s detail=%s", filename, exc.status_code, exc.detail)
        raise
    except OSError as exc:
        logger.exception("[UPLOAD] storage exception for filename=%r: %s", filename, exc)
        raise _error("UPLOAD_FAILED", f"Could not store the PDF: {exc}", 500) from exc
    except Exception as exc:
        logger.exception("[UPLOAD] unexpected exception for filename=%r: %s", filename, exc)
        raise
    finally:
        if temporary_path is not None and temporary_path.exists():
            temporary_path.unlink(missing_ok=True)
        await file.close()
