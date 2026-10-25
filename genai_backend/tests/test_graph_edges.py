from __future__ import annotations

from unittest.mock import MagicMock

from core.graph.edges import route_after_intent, route_after_grading, route_after_judge


def _make_config(max_rewrites=1, max_generations=2):
    config = MagicMock()
    config.loops.max_rewrites = max_rewrites
    config.loops.max_generations = max_generations
    return config


def test_route_after_intent_document():
    state = {"intent": "document_query"}
    assert route_after_intent(state) == "retrieve"


def test_route_after_intent_general_chat():
    state = {"intent": "general_chat"}
    assert route_after_intent(state) == "chat_respond"


def test_route_after_grading_correct():
    config = _make_config()
    state = {"retrieval_quality": "correct", "rewrite_count": 0}
    assert route_after_grading(state, config) == "generate"


def test_route_after_grading_incorrect_under_limit():
    config = _make_config()
    state = {"retrieval_quality": "incorrect", "rewrite_count": 0}
    assert route_after_grading(state, config) == "rewrite_query"


def test_route_after_grading_incorrect_at_limit():
    config = _make_config()
    state = {"retrieval_quality": "incorrect", "rewrite_count": 1}
    assert route_after_grading(state, config) == "generate"


def test_route_after_judge_pass():
    config = _make_config()
    state = {
        "verdict": {"grounded": True, "answers_question": True},
        "generation_count": 1,
        "rewrite_count": 0,
    }
    assert route_after_judge(state, config) == "finalize"


def test_route_after_judge_not_grounded_can_retry():
    config = _make_config()
    state = {
        "verdict": {"grounded": False, "answers_question": True},
        "generation_count": 1,
        "rewrite_count": 0,
    }
    assert route_after_judge(state, config) == "generate"


def test_route_after_judge_not_grounded_at_limit():
    config = _make_config()
    state = {
        "verdict": {"grounded": False, "answers_question": True},
        "generation_count": 2,
        "rewrite_count": 0,
    }
    assert route_after_judge(state, config) == "finalize"


def test_route_after_judge_grounded_not_answers_can_rewrite():
    config = _make_config()
    state = {
        "verdict": {"grounded": True, "answers_question": False},
        "generation_count": 1,
        "rewrite_count": 0,
    }
    assert route_after_judge(state, config) == "rewrite_query"


def test_route_after_judge_grounded_not_answers_at_limit():
    config = _make_config()
    state = {
        "verdict": {"grounded": True, "answers_question": False},
        "generation_count": 1,
        "rewrite_count": 1,
    }
    assert route_after_judge(state, config) == "finalize"
