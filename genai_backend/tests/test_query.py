from __future__ import annotations

import pytest


@pytest.mark.asyncio
async def test_query_documents(client, mock_graph):
    resp = await client.post(
        "/v1/query",
        json={"collection_id": "col-1", "query": "What is OmniDoc?"},
        headers={"X-API-Key": "test-api-key"},
    )
    assert resp.status_code == 200
    data = resp.json()
    assert data["answer"] == "Test answer from the pipeline."
    assert data["route"] == "docs"
    assert data["verdict"]["grounded"] is True
    assert data["verdict"]["answers_question"] is True
    assert "request_id" in data
    mock_graph.ainvoke.assert_called_once()


@pytest.mark.asyncio
async def test_query_missing_collection_id(client):
    resp = await client.post(
        "/v1/query",
        json={"query": "test"},
        headers={"X-API-Key": "test-api-key"},
    )
    assert resp.status_code == 422


@pytest.mark.asyncio
async def test_query_too_long(client):
    resp = await client.post(
        "/v1/query",
        json={"collection_id": "col-1", "query": "x" * 1001},
        headers={"X-API-Key": "test-api-key"},
    )
    assert resp.status_code == 422
