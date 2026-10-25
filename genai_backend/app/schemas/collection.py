from __future__ import annotations

from datetime import datetime
from typing import Optional

from pydantic import BaseModel


class CollectionCreate(BaseModel):
    name: Optional[str] = "Untitled"


class CollectionResponse(BaseModel):
    id: str
    name: str
    created_at: datetime
    document_count: int = 0
