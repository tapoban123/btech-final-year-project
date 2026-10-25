from __future__ import annotations

from langgraph.graph import StateGraph, END

from core.graph.state import GraphState
from core.graph.nodes import (
    make_classify_intent,
    make_retrieve,
    make_batch_grade,
    make_rewrite_query,
    make_web_search,
    make_generate,
    make_chat_respond,
    make_judge,
    make_finalize,
)
from core.graph.edges import (
    route_after_intent,
    route_after_grading,
    route_after_judge,
)
from core.llm import get_main_llm, get_fast_llm


def build_query_graph(retriever, config, checkpointer=None):
    main_llm = get_main_llm(config.llm.main_model)
    fast_llm = get_fast_llm(config.llm.fast_model)

    classify_intent = make_classify_intent(fast_llm)
    retrieve = make_retrieve(retriever)
    batch_grade = make_batch_grade(fast_llm, config)
    rewrite_query = make_rewrite_query(fast_llm)

    from app.config import get_settings
    settings = get_settings()
    web_search = make_web_search(settings.tavily_api_key, config.web_search.max_results)

    generate = make_generate(main_llm)
    chat_respond = make_chat_respond(main_llm)
    judge = make_judge(fast_llm)
    finalize = make_finalize()

    graph = StateGraph(GraphState)

    graph.add_node("classify_intent", classify_intent)
    graph.add_node("retrieve", retrieve)
    graph.add_node("batch_grade", batch_grade)
    graph.add_node("rewrite_query", rewrite_query)
    graph.add_node("web_search", web_search)
    graph.add_node("generate", generate)
    graph.add_node("chat_respond", chat_respond)
    graph.add_node("judge", judge)
    graph.add_node("finalize", finalize)

    graph.set_entry_point("classify_intent")

    graph.add_conditional_edges(
        "classify_intent",
        route_after_intent,
        {
            "retrieve": "retrieve",
            "chat_respond": "chat_respond",
        },
    )

    graph.add_edge("retrieve", "batch_grade")

    def _route_after_grading(state):
        return route_after_grading(state, config)

    graph.add_conditional_edges(
        "batch_grade",
        _route_after_grading,
        {
            "generate": "generate",
            "rewrite_query": "rewrite_query",
        },
    )

    graph.add_edge("rewrite_query", "web_search")
    graph.add_edge("web_search", "generate")

    graph.add_edge("generate", "judge")

    def _route_after_judge(state):
        return route_after_judge(state, config)

    graph.add_conditional_edges(
        "judge",
        _route_after_judge,
        {
            "finalize": "finalize",
            "generate": "generate",
            "rewrite_query": "rewrite_query",
        },
    )

    graph.add_edge("chat_respond", "finalize")

    graph.add_edge("finalize", END)

    return graph.compile(
        checkpointer=checkpointer,
    )
