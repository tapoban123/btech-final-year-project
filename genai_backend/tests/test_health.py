from __future__ import annotations

import pytest


@pytest.mark.asyncio
async def test_health_check(client):
    resp = await client.get("/v1/health")
    assert resp.status_code == 200
    data = resp.json()
    assert data["status"] == "ok"
    assert data["service"] == "omnidoc-ai"
    assert "version" in data
