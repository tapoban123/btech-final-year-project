import io
import time
from unittest.mock import patch

import pytest
from fastapi.testclient import TestClient

from main import app
from models.document import DocumentUploadResponse


@pytest.fixture
def client():
    return TestClient(app)


def test_concurrent_multi_file_upload(client):
    """Test that multiple files are processed concurrently rather than sequentially."""
    sleep_delay = 0.2

    def fake_process_pdf(filename, content_type, file_bytes):
        time.sleep(sleep_delay)
        return DocumentUploadResponse(
            id=f"id-{filename}",
            document_id=f"id-{filename}",
            filename=filename,
            content_type=content_type,
            size_bytes=len(file_bytes),
            status="completed",
            message="Uploaded successfully",
            cloudinary_public_id=f"public-{filename}",
        )

    # 3 valid dummy PDFs
    dummy_pdf = b"%PDF-1.4\n1 0 obj\n<<>>\nendobj\ntrailer\n<<>>\n%%EOF"
    files = [
        ("files", ("doc1.pdf", io.BytesIO(dummy_pdf), "application/pdf")),
        ("files", ("doc2.pdf", io.BytesIO(dummy_pdf), "application/pdf")),
        ("files", ("doc3.pdf", io.BytesIO(dummy_pdf), "application/pdf")),
    ]

    start_time = time.perf_counter()
    with patch("api.documents._process_pdf_sync", side_effect=fake_process_pdf):
        response = client.post("/api/v1/documents/upload", files=files)
    elapsed = time.perf_counter() - start_time

    assert response.status_code == 201
    data = response.json()
    assert data["total_files"] == 3
    assert data["successful"] == 3
    assert data["failed"] == 0
    assert len(data["results"]) == 3
    assert data["results"][0]["filename"] == "doc1.pdf"
    assert data["results"][1]["filename"] == "doc2.pdf"
    assert data["results"][2]["filename"] == "doc3.pdf"

    # If sequential, it would take >= 3 * 0.2 = 0.6 seconds.
    # Concurrently, it should finish in around ~0.2 - 0.4 seconds.
    assert elapsed < 0.55, f"Expected concurrent execution under 0.55s, took {elapsed:.2f}s"


def test_concurrent_upload_with_isolated_failures(client):
    """Test that an invalid file failure does not block or fail valid concurrent uploads."""
    def fake_process_pdf(filename, content_type, file_bytes):
        if not file_bytes.startswith(b"%PDF-"):
            return DocumentUploadResponse(
                filename=filename,
                content_type=content_type,
                size_bytes=len(file_bytes),
                status="failed",
                message="The file is not a valid PDF",
            )
        return DocumentUploadResponse(
            id=f"id-{filename}",
            document_id=f"id-{filename}",
            filename=filename,
            content_type=content_type,
            size_bytes=len(file_bytes),
            status="completed",
            message="Uploaded successfully",
            cloudinary_public_id=f"public-{filename}",
        )

    dummy_pdf = b"%PDF-1.4\n1 0 obj\n<<>>\nendobj\ntrailer\n<<>>\n%%EOF"
    files = [
        ("files", ("valid.pdf", io.BytesIO(dummy_pdf), "application/pdf")),
        ("files", ("invalid.txt", io.BytesIO(b"hello world"), "text/plain")),
        ("files", ("corrupted.pdf", io.BytesIO(b"not a pdf"), "application/pdf")),
    ]

    with patch("api.documents._process_pdf_sync", side_effect=fake_process_pdf):
        response = client.post("/api/v1/documents/upload", files=files)

    assert response.status_code == 201
    data = response.json()
    assert data["total_files"] == 3
    assert data["successful"] == 1
    assert data["failed"] == 2

    # Results preserve exact order of input
    assert data["results"][0]["filename"] == "valid.pdf"
    assert data["results"][0]["status"] == "completed"

    assert data["results"][1]["filename"] == "invalid.txt"
    assert data["results"][1]["status"] == "failed"

    assert data["results"][2]["filename"] == "corrupted.pdf"
    assert data["results"][2]["status"] == "failed"
