from __future__ import annotations

import time

from fastapi import APIRouter, Request

from app.errors import generate_request_id
from app.schemas.chat import ChatRequest, ChatResponse
from app.schemas.query import Source, Verdict
from core.llm import get_fast_llm

router = APIRouter(prefix="/v1", tags=["chat"])


@router.post("/chat", response_model=ChatResponse)
async def chat(
    req: ChatRequest,
    request: Request,
):
    request_id = getattr(request.state, "request_id", generate_request_id())
    chat_manager = request.app.state.chat_manager
    graph = request.app.state.query_graph
    config = request.app.state.config

    thread_meta = chat_manager.get_or_create_thread(req.chat_id)
    chat_id = thread_meta["chat_id"]

    if req.collection_id:
        chat_manager.set_collection(chat_id, req.collection_id)

    summary, recent_messages = chat_manager.get_chat_context(
        chat_id, config.chat.max_recent_messages
    )

    initial_state = {
        "query": req.message,
        "original_query": req.message,
        "collection_id": req.collection_id,
        "doc_ids": req.doc_ids,
        "documents": [],
        "grader_results": [],
        "relevant_chunks": [],
        "web_results": [],
        "retrieval_quality": "incorrect",
        "answer": "",
        "sources": [],
        "verdict": {},
        "judge_feedback": "",
        "route": "docs",
        "generation_count": 0,
        "rewrite_count": 0,
        "chat_history": recent_messages,
        "chat_summary": summary,
        "intent": "",
        "error": None,
        "latency_start": time.time(),
        "request_id": request_id,
    }

    graph_config = {"configurable": {"thread_id": chat_id}}

    result = await graph.ainvoke(initial_state, config=graph_config)

    answer = result.get("answer", "")

    fast_llm = get_fast_llm(config.llm.fast_model)
    await chat_manager.append_turn(
        chat_id,
        req.message,
        answer,
        llm=fast_llm,
        summary_threshold=config.chat.summary_token_threshold,
    )

    verdict_data = result.get("verdict", {})

    return ChatResponse(
        chat_id=chat_id,
        answer=answer,
        sources=[Source(**s) for s in result.get("sources", [])],
        route=result.get("route", "chat"),
        verdict=Verdict(
            grounded=verdict_data.get("grounded", True),
            answers_question=verdict_data.get("answers_question", True),
        ),
        latency_ms=result.get("latency_ms", 0),
        request_id=request_id,
    )
