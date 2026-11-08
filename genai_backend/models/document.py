from datetime import datetime

from pydantic import BaseModel


class DocumentUploadResponse(BaseModel):
    id: str | None = None
    document_id: str | None = None
    collection_id: str | None = None
    filename: str
    content_type: str
    size_bytes: int
    status: str
    message: str


class DocumentBatchUploadResponse(BaseModel):
    collection_id: str
    total_files: int
    successful: int
    failed: int
    results: list[DocumentUploadResponse]


class ImageBatchUploadResponse(DocumentBatchUploadResponse):
    pass


class DocumentMetadata(BaseModel):
    id: str
    collection_id: str
    original_filename: str
    stored_filename: str
    content_type: str
    size_bytes: int
    status: str
    created_at: datetime


class CollectionDocumentResponse(BaseModel):
    document_id: str
    collection_id: str
    filename: str
    size_bytes: int
    status: str
    created_at: datetime


class CollectionDocumentsResponse(BaseModel):
    collection_id: str
    documents: list[CollectionDocumentResponse]
