from __future__ import annotations

from typing import Literal, Optional

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
    sources_by_action: dict[str, list[Source]] = Field(default_factory=dict)
    route: str = "chat"
    verdict: Verdict = Verdict(grounded=True, answers_question=True)
    latency_ms: int = 0
    request_id: str = ""


class ChatHistoryItem(BaseModel):
    role: Literal["user", "assistant"]
    content: str
    sources: list[Source] = []
    sources_by_action: dict[str, list[Source]] = Field(default_factory=dict)


class ChatHistoryResponse(BaseModel):
    chat_id: str
    collection_id: Optional[str] = None
    title: str
    messages: list[ChatHistoryItem]


class ChatListItem(BaseModel):
    chat_id: str
    collection_id: Optional[str] = None
    title: str
    updated_at: str
