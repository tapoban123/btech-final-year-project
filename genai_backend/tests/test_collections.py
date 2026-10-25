from __future__ import annotations

import pytest


@pytest.mark.asyncio
async def test_create_collection(client):
    resp = await client.post(
        "/v1/collections",
        json={"name": "Test Collection"},
        headers={"X-API-Key": "test-api-key"},
    )
    assert resp.status_code == 201
    data = resp.json()
    assert data["name"] == "Test Collection"
    assert "id" in data
    assert data["document_count"] == 0


@pytest.mark.asyncio
async def test_create_collection_default_name(client):
    resp = await client.post(
        "/v1/collections",
        json={"name": None},
        headers={"X-API-Key": "test-api-key"},
    )
    assert resp.status_code == 201
    data = resp.json()
    assert data["name"] == "Untitled"


@pytest.mark.asyncio
async def test_list_documents_for_missing_collection(client):
    resp = await client.get(
        "/v1/collections/nonexistent-id/documents",
        headers={"X-API-Key": "test-api-key"},
    )
    assert resp.status_code == 404
