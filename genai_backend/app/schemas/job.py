from __future__ import annotations

from datetime import datetime
from typing import Optional

from pydantic import BaseModel


class JobStatusResponse(BaseModel):
    job_id: str
    document_id: str
    status: str
    progress: float
    error_message: Optional[str]
    created_at: datetime
    completed_at: Optional[datetime]
