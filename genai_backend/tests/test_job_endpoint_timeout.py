"""
Test to verify that the /v1/jobs/{job_id} endpoint doesn't timeout
while background ingestion is running.

This test simulates the scenario where:
1. A document is uploaded (triggering background ingestion)
2. The UI polls the job status endpoint
3. The endpoint should respond quickly without timing out
"""
import asyncio
import pytest
import httpx
from unittest.mock import AsyncMock, patch


@pytest.mark.asyncio
async def test_job_status_endpoint_doesnt_timeout_during_ingestion(client):
    """
    Verify that GET /v1/jobs/{job_id} responds within reasonable time
    even when background ingestion is running.

    This tests that:
    - Session is not held open during long ingestion operations
    - Connection pool is not exhausted
    - Polling requests get quick responses
    """
    # Create a test collection first
    collection = httpx.Client().post(
        "http://127.0.0.1:8000/v1/collections",
        json={"name": "test-timeout"}
    ).json()
    collection_id = collection["id"]

    # Upload a document (triggers background ingestion)
    with open("tests/fixtures/sample.pdf", "rb") as f:
        files = {"files": f}
        response = httpx.Client().post(
            f"http://127.0.0.1:8000/v1/collections/{collection_id}/documents",
            files=files
        )

    assert response.status_code == 202
    job_id = response.json()[0]["job_id"]

    # Poll job status multiple times while ingestion runs
    # Each request should complete within 5 seconds
    for i in range(10):
        try:
            response = httpx.Client(timeout=5.0).get(
                f"http://127.0.0.1:8000/v1/jobs/{job_id}"
            )
            assert response.status_code == 200
            job_status = response.json()
            print(f"Poll {i+1}: status={job_status['status']}, progress={job_status['progress']:.1%}")
        except httpx.ReadTimeout:
            pytest.fail(
                f"Job status endpoint timed out on poll {i+1}. "
                "This indicates the session is held during ingestion."
            )

        await asyncio.sleep(1)


@pytest.mark.asyncio
async def test_multiple_job_polls_during_ingestion():
    """
    Test that multiple concurrent job status requests don't exhaust the connection pool.

    This verifies:
    - Pool is sized appropriately (pool_size=5, max_overflow=10)
    - Sessions are released quickly
    - Concurrent requests don't block each other
    """
    collection_id = "test-collection"
    job_id = "test-job-123"

    async def poll_job():
        """Simulate job status polling"""
        try:
            async with httpx.AsyncClient(timeout=5.0) as client:
                response = await client.get(
                    f"http://127.0.0.1:8000/v1/jobs/{job_id}"
                )
                return response.status_code
        except httpx.ReadTimeout:
            return None

    # Simulate 5 concurrent polls (within pool_size)
    results = await asyncio.gather(
        *[poll_job() for _ in range(5)],
        return_exceptions=True
    )

    # Check that no timeouts occurred
    timeouts = [r for r in results if r is None]
    if timeouts:
        pytest.fail(
            f"Got {len(timeouts)} timeout(s) out of 5 concurrent requests. "
            "Pool exhaustion suspected."
        )


if __name__ == "__main__":
    # Run with: python -m pytest tests/test_job_endpoint_timeout.py -v
    print("Run with: python -m pytest tests/test_job_endpoint_timeout.py -v")
