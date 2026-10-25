from __future__ import annotations

import pytest
from pydantic import ValidationError


def test_query_request_validation():
    from app.schemas.query import QueryRequest

    req = QueryRequest(collection_id="c1", query="test query")
    assert req.collection_id == "c1"
    assert req.doc_ids is None


def test_query_request_max_length():
    from app.schemas.query import QueryRequest

    with pytest.raises(ValidationError):
        QueryRequest(collection_id="c1", query="x" * 1001)


def test_chat_request_validation():
    from app.schemas.chat import ChatRequest

    req = ChatRequest(collection_id="c1", message="hello")
    assert req.chat_id is None
    assert req.doc_ids is None


def test_chat_request_with_chat_id():
    from app.schemas.chat import ChatRequest

    req = ChatRequest(collection_id="c1", message="hi", chat_id="abc")
    assert req.chat_id == "abc"


def test_source_model():
    from app.schemas.query import Source

    doc_src = Source(type="document", doc_id="d1", filename="test.pdf", page=3)
    assert doc_src.type == "document"
    assert doc_src.url is None

    web_src = Source(type="web", url="https://example.com", title="Example")
    assert web_src.type == "web"
    assert web_src.doc_id is None


def test_verdict_model():
    from app.schemas.query import Verdict

    v = Verdict(grounded=True, answers_question=False)
    assert v.grounded is True
    assert v.answers_question is False


def test_answer_response_defaults():
    from app.schemas.query import AnswerResponse

    resp = AnswerResponse(answer="Test")
    assert resp.sources == []
    assert resp.retries == 0
    assert resp.route == "docs"


def test_collection_create():
    from app.schemas.collection import CollectionCreate

    c = CollectionCreate()
    assert c.name is None

    c2 = CollectionCreate(name="My Docs")
    assert c2.name == "My Docs"
