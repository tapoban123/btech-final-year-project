from __future__ import annotations

from typing import Literal, Optional, TypedDict

from langchain_core.documents import Document


class GraphState(TypedDict, total=False):
    # Query fields
    query: str
    original_query: str
    collection_id: str
    doc_ids: Optional[list[str]]

    # Retrieval fields
    documents: list[Document]
    grader_results: list[dict]
    relevant_chunks: list[Document]
    web_results: list[dict]
    retrieval_quality: Literal["correct", "ambiguous", "incorrect"]

    # Generation fields
    answer: str
    sources: list[dict]
    sources_by_action: dict[str, list[dict]]
    verdict: dict
    judge_feedback: str
    route: str

    # Counters
    generation_count: int
    rewrite_count: int

    # Chat fields
    chat_history: list[dict]
    chat_summary: str
    intent: Literal["document_query", "general_chat"]

    # Metadata
    error: Optional[str]
    latency_start: float
    request_id: str
