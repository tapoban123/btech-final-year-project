from __future__ import annotations


def route_after_intent(state: dict) -> str:
    intent = state.get("intent", "document_query")
    if intent == "general_chat":
        return "chat_respond"
    return "retrieve"


def route_after_grading(state: dict, config) -> str:
    quality = state.get("retrieval_quality", "incorrect")

    if quality == "correct":
        return "generate"

    if state.get("rewrite_count", 0) < config.loops.max_rewrites:
        return "rewrite_query"

    return "generate"


def route_after_rewrite(state: dict) -> str:
    return "web_search"


def route_after_web_search(state: dict) -> str:
    return "generate"


def route_after_judge(state: dict, config) -> str:
    verdict = state.get("verdict", {})
    grounded = verdict.get("grounded", False)
    answers = verdict.get("answers_question", False)

    if grounded and answers:
        return "finalize"

    if not grounded and state.get("generation_count", 0) < config.loops.max_generations:
        return "generate"

    if grounded and not answers and state.get("rewrite_count", 0) < config.loops.max_rewrites:
        return "rewrite_query"

    return "finalize"
