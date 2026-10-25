from __future__ import annotations

from typing import Literal, Optional

from pydantic import BaseModel, Field


class Source(BaseModel):
    type: Literal["document", "web"]
    doc_id: Optional[str] = None
    filename: Optional[str] = None
    page: Optional[int] = None
    chunk_id: Optional[str] = None
    ocr: Optional[bool] = None
    ocr_confidence: Optional[float] = None
    url: Optional[str] = None
    title: Optional[str] = None


class Verdict(BaseModel):
    grounded: bool
    answers_question: bool


class QueryRequest(BaseModel):
    collection_id: str
    query: str = Field(..., max_length=1000)
    doc_ids: Optional[list[str]] = None


class AnswerResponse(BaseModel):
    answer: str
    sources: list[Source] = []
    route: str = "docs"
    verdict: Verdict = Verdict(grounded=True, answers_question=True)
    retries: int = 0
    latency_ms: int = 0
    request_id: str = ""
