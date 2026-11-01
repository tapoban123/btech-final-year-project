import json
import os
from pathlib import Path
from typing import Any


class DocumentStorage:
    """Stores uploaded PDFs and lightweight metadata for the first milestone."""

    def __init__(self, upload_dir: str | None = None) -> None:
        self.upload_dir = Path(upload_dir or os.getenv("UPLOAD_DIR", "./storage/uploads"))
        self.upload_dir.mkdir(parents=True, exist_ok=True)
        self.metadata_path = self.upload_dir / "documents.json"

    def save_metadata(self, metadata: dict[str, Any]) -> None:
        records = self.list_metadata()
        records.append(metadata)
        self.metadata_path.write_text(json.dumps(records, indent=2), encoding="utf-8")

    def list_metadata(self) -> list[dict[str, Any]]:
        if not self.metadata_path.exists():
            return []
        try:
            value = json.loads(self.metadata_path.read_text(encoding="utf-8"))
            return value if isinstance(value, list) else []
        except json.JSONDecodeError:
            return []
