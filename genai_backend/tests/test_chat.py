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
async def test_chat_message_too_long(client):
    resp = await client.post(
        "/v1/chat",
        json={"collection_id": "col-1", "message": "x" * 2001},
        headers={"X-API-Key": "test-api-key"},
    )
    assert resp.status_code == 422
