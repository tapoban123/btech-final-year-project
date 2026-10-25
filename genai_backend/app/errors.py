from __future__ import annotations

import uuid
from fastapi import FastAPI, Request
from fastapi.responses import JSONResponse


class AppError(Exception):
    def __init__(self, code: str, message: str, status_code: int = 400):
        self.code = code
        self.message = message
        self.status_code = status_code


class DocNotReadyError(AppError):
    def __init__(self, message: str = "Document is not ready for querying"):
        super().__init__("DOC_NOT_READY", message, 409)


class CollectionNotFoundError(AppError):
    def __init__(self, collection_id: str = ""):
        super().__init__("COLLECTION_NOT_FOUND", f"Collection not found: {collection_id}", 404)


class DocumentNotFoundError(AppError):
    def __init__(self, doc_id: str = ""):
        super().__init__("DOCUMENT_NOT_FOUND", f"Document not found: {doc_id}", 404)


class JobNotFoundError(AppError):
    def __init__(self, job_id: str = ""):
        super().__init__("JOB_NOT_FOUND", f"Job not found: {job_id}", 404)


class UnsupportedFileError(AppError):
    def __init__(self, message: str = "Unsupported file type"):
        super().__init__("UNSUPPORTED_FILE", message, 415)


class FileTooLargeError(AppError):
    def __init__(self, max_mb: int = 20):
        super().__init__("FILE_TOO_LARGE", f"File exceeds {max_mb}MB limit", 413)


class LLMTimeoutError(AppError):
    def __init__(self):
        super().__init__("LLM_TIMEOUT", "LLM call timed out", 504)


class IngestionError(AppError):
    def __init__(self, message: str = "Document ingestion failed"):
        super().__init__("INGESTION_FAILED", message, 500)


class OcrFailedError(AppError):
    def __init__(self, message: str = "OCR processing failed"):
        super().__init__("OCR_FAILED", message, 500)


def generate_request_id() -> str:
    return f"req_{uuid.uuid4().hex[:12]}"


async def request_id_middleware(request: Request, call_next):
    request.state.request_id = generate_request_id()
    response = await call_next(request)
    response.headers["X-Request-ID"] = request.state.request_id
    return response


def register_error_handlers(app: FastAPI):
    @app.exception_handler(AppError)
    async def app_error_handler(request: Request, exc: AppError):
        request_id = getattr(request.state, "request_id", generate_request_id())
        return JSONResponse(
            status_code=exc.status_code,
            content={
                "error": {
                    "code": exc.code,
                    "message": exc.message,
                    "request_id": request_id,
                }
            },
        )
