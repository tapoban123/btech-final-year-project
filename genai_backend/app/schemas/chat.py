from __future__ import annotations

from typing import Optional

from pydantic import BaseModel, Field

from app.schemas.query import Source, Verdict


class ChatRequest(BaseModel):
    chat_id: Optional[str] = None
    collection_id: str
    message: str = Field(..., max_length=2000)
    doc_ids: Optional[list[str]] = None


class ChatResponse(BaseModel):
    chat_id: str
    answer: str
    sources: list[Source] = []
    route: str = "chat"
    verdict: Verdict = Verdict(grounded=True, answers_question=True)
    latency_ms: int = 0
    request_id: str = ""
