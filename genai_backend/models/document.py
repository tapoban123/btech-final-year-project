from datetime import datetime

from pydantic import BaseModel, Field


class DocumentUploadResponse(BaseModel):
    id: str | None = None
    document_id: str | None = None
    filename: str
    content_type: str
    size_bytes: int
    status: str
    message: str
    cloudinary_public_id: str | None = None


class DocumentBatchUploadResponse(BaseModel):
    total_files: int
    successful: int
    failed: int
    results: list[DocumentUploadResponse]


class ImageBatchUploadResponse(DocumentBatchUploadResponse):
    pass


class DocumentMetadata(BaseModel):
    document_id: str
    filename: str
    size_bytes: int
    status: str
    created_at: datetime


class DocumentsResponse(BaseModel):
    documents: list[DocumentMetadata]


class DocumentSearchRequest(BaseModel):
    query: str = Field(min_length=2, max_length=4000)


class DocumentSearchResult(BaseModel):
    document_id: str
    filename: str
    cloudinary_url: str | None = None


class DocumentSearchResponse(BaseModel):
    query: str
    documents: list[DocumentSearchResult]
