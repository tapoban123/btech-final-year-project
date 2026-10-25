from __future__ import annotations

import pytest


@pytest.mark.asyncio
async def test_chat_new_conversation(client, mock_graph, mock_chat_manager):
    resp = await client.post(
        "/v1/chat",
        json={"collection_id": "col-1", "message": "Hello!"},
        headers={"X-API-Key": "test-api-key"},
    )
    assert resp.status_code == 200
    data = resp.json()
    assert data["chat_id"] == "test-chat-123"
    assert data["answer"] == "Test answer from the pipeline."
    mock_chat_manager.get_or_create_thread.assert_called_once()
    mock_graph.ainvoke.assert_called_once()


@pytest.mark.asyncio
async def test_chat_with_existing_chat_id(client, mock_chat_manager):
    resp = await client.post(
        "/v1/chat",
        json={
            "collection_id": "col-1",
            "message": "Follow up question",
            "chat_id": "existing-123",
        },
        headers={"X-API-Key": "test-api-key"},
    )
    assert resp.status_code == 200
    mock_chat_manager.get_or_create_thread.assert_called_once_with("existing-123")


@pytest.mark.asyncio
async def test_chat_returns_sources_by_action(client, mock_graph):
    source = {"type": "document", "doc_id": "d1", "filename": "guide.pdf", "page": 2}
    mock_graph.ainvoke.return_value = {
        "answer": "Test answer from the pipeline.",
        "sources": [source],
        "sources_by_action": {"Corrective_RAG": [source]},
        "route": "docs",
        "verdict": {"grounded": True, "answers_question": True},
    }
    resp = await client.post(
        "/v1/chat",
        json={"collection_id": "col-1", "message": "Question"},
        headers={"X-API-Key": "test-api-key"},
    )
    assert resp.status_code == 200
    returned = resp.json()["sources_by_action"]["Corrective_RAG"][0]
    assert {key: returned[key] for key in source} == source


@pytest.mark.asyncio
async def test_chat_history_endpoints(client, mock_chat_manager):
    source = {"type": "document", "doc_id": "d1", "filename": "guide.pdf", "page": 2}
    mock_chat_manager.list_threads.return_value = [{
        "chat_id": "chat-1", "collection_id": "col-1", "title": "A question", "updated_at": "now",
    }]
    mock_chat_manager.get_thread.return_value = {
        "chat_id": "chat-1", "collection_id": "col-1", "title": "A question",
        "messages": [
            {"role": "user", "content": "A question"},
            {"role": "assistant", "content": "An answer", "sources": [source]},
        ],
    }
    listing = await client.get("/v1/chats", headers={"X-API-Key": "test-api-key"})
    history = await client.get("/v1/chats/chat-1", headers={"X-API-Key": "test-api-key"})
    assert listing.status_code == 200
    assert listing.json()[0]["title"] == "A question"
    assert history.status_code == 200
    assert history.json()["messages"][1]["sources"][0]["page"] == 2


@pytest.mark.asyncio
async def test_chat_message_too_long(client):
    resp = await client.post(
        "/v1/chat",
        json={"collection_id": "col-1", "message": "x" * 2001},
        headers={"X-API-Key": "test-api-key"},
    )
    assert resp.status_code == 422
