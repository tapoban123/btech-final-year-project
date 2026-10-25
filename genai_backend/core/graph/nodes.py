from __future__ import annotations

import json
import logging
import random
from typing import Any

from langchain_core.messages import HumanMessage, SystemMessage

from core.graph.prompts import (
    INTENT_CLASSIFIER_PROMPT,
    GRADER_SYSTEM_PROMPT,
    REWRITE_PROMPT,
    GENERATE_SYSTEM_PROMPT,
    GENERATE_FEEDBACK_SECTION,
    JUDGE_SYSTEM_PROMPT,
    CHAT_RESPONSE_PROMPT,
)

logger = logging.getLogger(__name__)


def make_classify_intent(fast_llm):
    async def classify_intent(state: dict) -> dict:
        history_text = ""
        for msg in (state.get("chat_history") or [])[-4:]:
            role = msg.get("role", "user")
            history_text += f"{role}: {msg.get('content', '')}\n"

        prompt = f"{INTENT_CLASSIFIER_PROMPT}\n\nConversation history:\n{history_text}\n\nUser message: {state['query']}"

        response = await fast_llm.ainvoke([HumanMessage(content=prompt)])
        text = response.content.strip().lower()

        intent = "document_query" if "document" in text else "general_chat"
        return {"intent": intent}

    return classify_intent


def make_retrieve(retriever):
    async def retrieve(state: dict) -> dict:
        query = state.get("query", state.get("original_query", ""))
        collection_id = state["collection_id"]
        doc_ids = state.get("doc_ids")

        docs = await retriever.retrieve(query, collection_id, doc_ids)
        return {"documents": docs}

    return retrieve


def make_batch_grade(fast_llm, config):
    async def batch_grade(state: dict) -> dict:
        documents = state.get("documents", [])
        question = state.get("original_query", state.get("query", ""))

        if not documents:
            return {
                "grader_results": [],
                "relevant_chunks": [],
                "retrieval_quality": "incorrect",
            }

        shuffled = list(enumerate(documents))
        random.shuffle(shuffled)

        chunks_text = ""
        for idx, (orig_idx, doc) in enumerate(shuffled):
            chunk_id = doc.metadata.get("chunk_id", f"c_{orig_idx}")
            text = doc.page_content[:1600]
            chunks_text += f"\n[{chunk_id}]\n{text}\n"

        prompt = f"Question: {question}\n\nChunks:{chunks_text}"

        try:
            response = await fast_llm.ainvoke([
                SystemMessage(content=GRADER_SYSTEM_PROMPT),
                HumanMessage(content=prompt),
            ])

            raw = response.content.strip()
            if raw.startswith("```"):
                raw = raw.split("```")[1]
                if raw.startswith("json"):
                    raw = raw[4:]

            parsed = json.loads(raw)
            grades = parsed.get("grades", parsed) if isinstance(parsed, dict) else parsed

        except (json.JSONDecodeError, Exception) as e:
            logger.warning("Grader JSON parse failed, treating as ambiguous: %s", e)
            grades = [
                {"chunk_id": doc.metadata.get("chunk_id", f"c_{i}"), "score": 1}
                for i, doc in enumerate(documents)
            ]

        grade_map = {g["chunk_id"]: g.get("score", 0) for g in grades}

        for doc in documents:
            cid = doc.metadata.get("chunk_id", "")
            if cid not in grade_map:
                grade_map[cid] = 0

        relevant = [
            doc for doc in documents
            if grade_map.get(doc.metadata.get("chunk_id", ""), 0) >= 1
        ]

        score2_count = sum(1 for s in grade_map.values() if s >= 2)
        score1_count = sum(1 for s in grade_map.values() if s >= 1)

        if score2_count >= config.grading.correct_min_score2:
            quality = "correct"
        elif score1_count >= config.grading.ambiguous_min_score1:
            quality = "ambiguous"
        else:
            quality = "incorrect"

        return {
            "grader_results": grades,
            "relevant_chunks": relevant,
            "retrieval_quality": quality,
        }

    return batch_grade


def make_rewrite_query(fast_llm):
    async def rewrite_query(state: dict) -> dict:
        question = state.get("original_query", state.get("query", ""))
        grades = state.get("grader_results", [])

        feedback = ", ".join(
            f"{g.get('chunk_id', '?')}: score {g.get('score', 0)}"
            for g in grades[:5]
        )

        prompt = REWRITE_PROMPT.format(question=question, feedback=feedback)
        response = await fast_llm.ainvoke([HumanMessage(content=prompt)])
        rewritten = response.content.strip()

        return {
            "query": rewritten,
            "rewrite_count": state.get("rewrite_count", 0) + 1,
        }

    return rewrite_query


def make_web_search(tavily_api_key: str, max_results: int = 4):
    async def web_search(state: dict) -> dict:
        query = state.get("query", state.get("original_query", ""))

        try:
            from tavily import AsyncTavilyClient
            client = AsyncTavilyClient(api_key=tavily_api_key)
            results = await client.search(query, max_results=max_results)

            web_results = [
                {
                    "url": r.get("url", ""),
                    "title": r.get("title", ""),
                    "content": r.get("content", "")[:1500],
                }
                for r in results.get("results", [])
            ]
        except Exception as e:
            logger.warning("Web search failed: %s", e)
            web_results = []

        return {"web_results": web_results}

    return web_search


def make_generate(main_llm):
    async def generate(state: dict) -> dict:
        question = state.get("original_query", state.get("query", ""))
        relevant_chunks = state.get("relevant_chunks", [])
        web_results = state.get("web_results", [])
        quality = state.get("retrieval_quality", "correct")
        judge_feedback = state.get("judge_feedback", "")
        gen_count = state.get("generation_count", 0)

        context_parts = []

        if quality != "incorrect":
            for doc in relevant_chunks:
                meta = doc.metadata
                fname = meta.get("filename", "unknown")
                page = meta.get("page", "?")
                ocr_conf = meta.get("ocr_confidence", 1.0)

                header = f"[{fname}, p.{page}]"
                if ocr_conf < 0.4:
                    header += " (low OCR confidence — text may have errors)"

                context_parts.append(f"{header}\n{doc.page_content}")

        for wr in web_results:
            context_parts.append(
                f"[Web: {wr.get('title', 'untitled')}]\n{wr.get('content', '')}"
            )

        context = "\n\n---\n\n".join(context_parts) if context_parts else "No context available."

        feedback_section = ""
        if gen_count > 0 and judge_feedback:
            feedback_section = GENERATE_FEEDBACK_SECTION.format(feedback=judge_feedback)

        system_prompt = GENERATE_SYSTEM_PROMPT.format(
            context=context,
            feedback_section=feedback_section,
        )

        messages = [SystemMessage(content=system_prompt)]

        chat_summary = state.get("chat_summary", "")
        chat_history = state.get("chat_history") or []
        if chat_summary:
            messages.append(SystemMessage(content=f"Conversation summary: {chat_summary}"))
        for msg in chat_history[-6:]:
            if msg["role"] == "user":
                messages.append(HumanMessage(content=msg["content"]))
            else:
                from langchain_core.messages import AIMessage
                messages.append(AIMessage(content=msg["content"]))

        messages.append(HumanMessage(content=question))

        response = await main_llm.ainvoke(messages)
        answer = response.content.strip()

        sources = []
        for doc in relevant_chunks:
            meta = doc.metadata
            sources.append({
                "type": "document",
                "doc_id": meta.get("doc_id", ""),
                "filename": meta.get("filename", ""),
                "page": meta.get("page"),
                "chunk_id": meta.get("chunk_id", ""),
                "ocr": meta.get("ocr", False),
                "ocr_confidence": meta.get("ocr_confidence"),
            })

        for wr in web_results:
            sources.append({
                "type": "web",
                "url": wr.get("url", ""),
                "title": wr.get("title", ""),
            })

        route = "docs"
        if web_results and relevant_chunks:
            route = "docs+web"
        elif web_results and not relevant_chunks:
            route = "web"

        return {
            "answer": answer,
            "sources": sources,
            "route": route,
            "generation_count": gen_count + 1,
        }

    return generate


def make_chat_respond(main_llm):
    async def chat_respond(state: dict) -> dict:
        question = state.get("query", "")
        chat_summary = state.get("chat_summary", "")
        chat_history = state.get("chat_history") or []

        summary_section = ""
        if chat_summary:
            summary_section = f"Previous conversation summary: {chat_summary}"

        system_prompt = CHAT_RESPONSE_PROMPT.format(summary_section=summary_section)

        messages = [SystemMessage(content=system_prompt)]
        for msg in chat_history[-6:]:
            if msg["role"] == "user":
                messages.append(HumanMessage(content=msg["content"]))
            else:
                from langchain_core.messages import AIMessage
                messages.append(AIMessage(content=msg["content"]))

        messages.append(HumanMessage(content=question))

        response = await main_llm.ainvoke(messages)

        return {
            "answer": response.content.strip(),
            "sources": [],
            "route": "chat",
            "verdict": {"grounded": True, "answers_question": True},
            "generation_count": 1,
        }

    return chat_respond


def make_judge(fast_llm):
    async def judge(state: dict) -> dict:
        question = state.get("original_query", state.get("query", ""))
        answer = state.get("answer", "")
        relevant_chunks = state.get("relevant_chunks", [])
        web_results = state.get("web_results", [])

        context_parts = []
        for doc in relevant_chunks:
            context_parts.append(doc.page_content[:800])
        for wr in web_results:
            context_parts.append(wr.get("content", "")[:800])

        context = "\n---\n".join(context_parts) if context_parts else "No context."

        prompt = (
            f"Question: {question}\n\n"
            f"Answer: {answer}\n\n"
            f"Source context:\n{context}"
        )

        try:
            response = await fast_llm.ainvoke([
                SystemMessage(content=JUDGE_SYSTEM_PROMPT),
                HumanMessage(content=prompt),
            ])

            raw = response.content.strip()
            if raw.startswith("```"):
                raw = raw.split("```")[1]
                if raw.startswith("json"):
                    raw = raw[4:]

            result = json.loads(raw)
            return {
                "verdict": {
                    "grounded": result.get("grounded", False),
                    "answers_question": result.get("answers_question", False),
                },
                "judge_feedback": result.get("reason", ""),
            }

        except (json.JSONDecodeError, Exception) as e:
            logger.warning("Judge parse failed: %s", e)
            return {
                "verdict": {"grounded": True, "answers_question": True},
                "judge_feedback": "",
            }

    return judge


def make_finalize():
    def finalize(state: dict) -> dict:
        import time

        latency_start = state.get("latency_start", time.time())
        latency_ms = int((time.time() - latency_start) * 1000)

        verdict = state.get("verdict", {})
        answer = state.get("answer", "")

        if not verdict.get("grounded", True) or not verdict.get("answers_question", True):
            answer += (
                "\n\n⚠️ Note: This answer may not be fully grounded in the "
                "provided documents. Please verify the information independently."
            )

        return {
            "answer": answer,
            "latency_ms": latency_ms,
        }

    return finalize
