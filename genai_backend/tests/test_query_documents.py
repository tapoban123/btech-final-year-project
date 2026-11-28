from datetime import datetime, timezone
from unittest.mock import MagicMock, patch

import pytest
from fastapi.testclient import TestClient

from main import app
from models.document import DocumentMetadata
from models.rag import MultiDocumentQueryResponse, QueryCitation


@pytest.fixture
def client():
    return TestClient(app)


def test_multi_document_query_response_model():
    now = datetime.now(timezone.utc)
    doc_meta = DocumentMetadata(
        document_id="doc-123",
        filename="report.pdf",
        size_bytes=1024,
        status="completed",
        created_at=now,
        cloudinary_url="https://res.cloudinary.com/test/doc-123.pdf",
        mime_type="application/pdf",
    )
    citation = QueryCitation(
        document_id="doc-123",
        document_name="report.pdf",
        page=2,
        snippet="Sample snippet from report",
        cloudinary_url="https://res.cloudinary.com/test/doc-123.pdf",
        mime_type="application/pdf",
    )
    response = MultiDocumentQueryResponse(
        answer="This is the answer.",
        sources=[citation],
        documents=[doc_meta],
    )

    data = response.model_dump()
    assert data["answer"] == "This is the answer."
    assert len(data["sources"]) == 1
    assert data["sources"][0]["document_id"] == "doc-123"
    assert data["sources"][0]["cloudinary_url"] == "https://res.cloudinary.com/test/doc-123.pdf"
    assert len(data["documents"]) == 1
    assert data["documents"][0]["document_id"] == "doc-123"
    assert data["documents"][0]["filename"] == "report.pdf"
    assert data["documents"][0]["size_bytes"] == 1024
    assert data["documents"][0]["status"] == "completed"
    assert data["documents"][0]["cloudinary_url"] == "https://res.cloudinary.com/test/doc-123.pdf"
    assert data["documents"][0]["mime_type"] == "application/pdf"


def test_query_documents_endpoint_success(client):
    mock_rag_result = {
        "answer": "Photosynthesis is the process by which plants make food.",
        "sources": [
            {
                "document_id": "bio-uuid-1",
                "document_name": "biology.pdf",
                "page": 5,
                "snippet": "Plants use chlorophyll to capture light energy...",
            }
        ],
    }

    mock_supabase_records = [
        {
            "id": "bio-uuid-1",
            "document_id": "bio-uuid-1",
            "original_filename": "biology.pdf",
            "size_bytes": 204850,
            "status": "completed",
            "created_at": "2026-11-22T08:00:00Z",
            "cloudinary_url": "https://res.cloudinary.com/test/bio-uuid-1.pdf",
            "mime_type": "application/pdf",
            "content_type": "application/pdf",
        }
    ]

    with (
        patch("api.documents.rag_pipeline.ask", return_value=mock_rag_result),
        patch("api.documents.storage.get_metadata_for_ids", return_value=mock_supabase_records),
    ):
        resp = client.post("/api/v1/documents/query", json={"query": "What is photosynthesis?"})
        assert resp.status_code == 200
        data = resp.json()

        assert data["answer"] == "Photosynthesis is the process by which plants make food."
        assert len(data["sources"]) == 1
        assert data["sources"][0]["document_id"] == "bio-uuid-1"
        assert data["sources"][0]["document_name"] == "biology.pdf"
        assert data["sources"][0]["page"] == 5
        assert data["sources"][0]["cloudinary_url"] == "https://res.cloudinary.com/test/bio-uuid-1.pdf"
        assert data["sources"][0]["mime_type"] == "application/pdf"

        assert len(data["documents"]) == 1
        doc = data["documents"][0]
        assert doc["document_id"] == "bio-uuid-1"
        assert doc["filename"] == "biology.pdf"
        assert doc["size_bytes"] == 204850
        assert doc["status"] == "completed"
        assert doc["created_at"].startswith("2026-11-22T08:00:00")
        assert doc["cloudinary_url"] == "https://res.cloudinary.com/test/bio-uuid-1.pdf"
        assert doc["mime_type"] == "application/pdf"


def test_query_documents_empty_sources(client):
    mock_rag_result = {
        "answer": "I could not find relevant information in the documents.",
        "sources": [],
    }

    with patch("api.documents.rag_pipeline.ask", return_value=mock_rag_result):
        resp = client.post("/api/v1/documents/query", json={"query": "Quantum physics"})
        assert resp.status_code == 200
        data = resp.json()
        assert data["answer"] == "I could not find relevant information in the documents."
        assert data["sources"] == []
        assert data["documents"] == []


def test_query_documents_fallback_when_db_missing(client):
    mock_rag_result = {
        "answer": "Answer from unindexed doc.",
        "sources": [
            {
                "document_id": "missing-uuid",
                "document_name": "unknown_file.pdf",
                "page": 1,
                "snippet": "Some snippet...",
            }
        ],
    }

    with (
        patch("api.documents.rag_pipeline.ask", return_value=mock_rag_result),
        patch("api.documents.storage.get_metadata_for_ids", return_value=[]),
    ):
        resp = client.post("/api/v1/documents/query", json={"query": "Test query"})
        assert resp.status_code == 200
        data = resp.json()
        assert len(data["documents"]) == 1
        assert data["documents"][0]["document_id"] == "missing-uuid"
        assert data["documents"][0]["filename"] == "unknown_file.pdf"
        assert data["documents"][0]["status"] == "unknown"

