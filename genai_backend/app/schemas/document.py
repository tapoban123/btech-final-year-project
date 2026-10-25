from __future__ import annotations

from datetime import datetime
from typing import Optional

from pydantic import BaseModel


class DocumentResponse(BaseModel):
    id: str
    collection_id: str
    filename: str
    content_type: str
    size_bytes: int
    page_count: Optional[int]
    doc_type: str
    status: str
    created_at: datetime


class DocumentUploadResponse(BaseModel):
    document_id: str
    job_id: str
    filename: str
