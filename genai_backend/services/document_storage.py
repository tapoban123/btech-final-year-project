import json
import os
from pathlib import Path
from typing import Any


class DocumentStorage:
    """Stores generated PDF files and collection/document metadata."""

    def __init__(self, upload_dir: str | None = None) -> None:
        self.upload_dir = Path(upload_dir or os.getenv("UPLOAD_DIR", "./storage/uploads"))
        self.upload_dir.mkdir(parents=True, exist_ok=True)
        self.metadata_path = self.upload_dir / "documents.json"

    def save_metadata(self, metadata: dict[str, Any]) -> None:
        records = self.list_metadata()
        records.append(metadata)
        self.metadata_path.write_text(json.dumps(records, indent=2), encoding="utf-8")

    def collection_exists(self, collection_id: str) -> bool:
        return any(item.get("collection_id") == collection_id for item in self.list_metadata())

    def list_collection_metadata(self, collection_id: str) -> list[dict[str, Any]]:
        return [item for item in self.list_metadata() if item.get("collection_id") == collection_id]

    def delete_document_metadata(self, document_id: str) -> dict[str, Any] | None:
        records = self.list_metadata()
        removed = next((item for item in records if item.get("id") == document_id), None)
        if removed is not None:
            records = [item for item in records if item.get("id") != document_id]
            self.metadata_path.write_text(json.dumps(records, indent=2), encoding="utf-8")
        return removed

    def delete_collection_metadata(self, collection_id: str) -> list[dict[str, Any]]:
        records = self.list_metadata()
        removed = [item for item in records if item.get("collection_id") == collection_id]
        if removed:
            remaining = [item for item in records if item.get("collection_id") != collection_id]
            self.metadata_path.write_text(json.dumps(remaining, indent=2), encoding="utf-8")
        return removed

    def list_metadata(self) -> list[dict[str, Any]]:
        if not self.metadata_path.exists():
            return []
        try:
            value = json.loads(self.metadata_path.read_text(encoding="utf-8"))
            return value if isinstance(value, list) else []
        except json.JSONDecodeError:
            return []

    def document_path(self, document_id: str) -> Path:
        """Return the generated PDF path; IDs never come from user filenames."""
        if not document_id.startswith("doc_") or "/" in document_id or "\\" in document_id:
            raise ValueError("Invalid document ID")
        return self.upload_dir / f"{document_id}.pdf"
