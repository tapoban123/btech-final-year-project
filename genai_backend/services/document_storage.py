import os
import logging
from datetime import datetime, timezone
from typing import Any

import httpx

logger = logging.getLogger(__name__)


class DocumentStorage:
    """Stores and manages document metadata in Supabase."""

    def __init__(self) -> None:
        self.supabase_url = os.getenv("SUPABASE_URL", "").strip().rstrip("/")
        self.supabase_key = (
            os.getenv("SUPABASE_SERVICE_ROLE_KEY", "").strip()
            or os.getenv("SUPABASE_KEY", "").strip()
        )

    def _headers(self) -> dict[str, str]:
        if not self.supabase_url or not self.supabase_key:
            raise RuntimeError("SUPABASE_URL and SUPABASE_SERVICE_ROLE_KEY are not configured")
        return {
            "apikey": self.supabase_key,
            "Authorization": f"Bearer {self.supabase_key}",
            "Content-Type": "application/json",
        }

    def _request(self, method: str, path: str, **kwargs: Any) -> Any:
        logger.info(
            "[SUPABASE] request method=%s path=%s params=%s",
            method,
            path,
            kwargs.get("params", {}),
        )
        try:
            response = httpx.request(
                method, f"{self.supabase_url}/rest/v1/{path}",
                headers=self._headers(), timeout=15, **kwargs,
            )
            response.raise_for_status()
            logger.info(
                "[SUPABASE] response status=%s path=%s",
                response.status_code,
                path,
            )
        except httpx.HTTPStatusError as exc:
            detail = exc.response.text[:500]
            logger.error(
                "[SUPABASE] HTTP failure status=%s path=%s detail=%s",
                exc.response.status_code,
                path,
                detail,
            )
            raise RuntimeError(f"Supabase request failed ({exc.response.status_code}): {detail}") from exc
        except httpx.HTTPError as exc:
            logger.error("[SUPABASE] transport failure path=%s error=%s", path, exc)
            raise RuntimeError(f"Supabase request failed: {exc}") from exc
        if not response.content:
            return None
        return response.json()

    def save_metadata(self, metadata: dict[str, Any]) -> None:
        row = {
            "id": metadata["id"],
            "user_id": metadata["user_id"],
            "filename": metadata["original_filename"],
            "mime_type": metadata["content_type"],
            "file_size": metadata["size_bytes"],
            "cloudinary_asset_id": metadata.get("cloudinary_asset_id"),
            "cloudinary_public_id": metadata.get("cloudinary_public_id"),
            "cloudinary_url": metadata.get("cloudinary_url"),
            "cloudinary_resource_type": metadata.get("cloudinary_resource_type"),
            "status": metadata.get("status", "processing"),
            "error_message": metadata.get("error_message"),
        }
        self._request("POST", "documents", params={"select": "id"}, json=row)

    def update_metadata(self, document_id: str, *, status: str, error_message: str | None = None) -> None:
        self._request(
            "PATCH", "documents", params={"id": f"eq.{document_id}"},
            json={
                "status": status,
                "error_message": error_message,
                "updated_at": datetime.now(timezone.utc).isoformat(),
            },
        )

    def list_metadata(self, user_id: str) -> list[dict[str, Any]]:
        rows = self._request("GET", "documents", params={"select": "*", "user_id": f"eq.{user_id}", "order": "created_at.asc"})
        return [self._to_metadata(row) for row in rows or []]

    def get_metadata(self, document_id: str, user_id: str) -> dict[str, Any] | None:
        rows = self._request("GET", "documents", params={"select": "*", "id": f"eq.{document_id}", "user_id": f"eq.{user_id}"})
        return self._to_metadata(rows[0]) if rows else None

    def get_metadata_for_ids(self, document_ids: list[str], user_id: str) -> list[dict[str, Any]]:
        """Fetch only documents owned by the user for the supplied IDs."""
        logger.info(
            "[SUPABASE] batch document lookup user_id=%s document_ids=%r",
            user_id,
            document_ids,
        )
        if not document_ids:
            logger.info("[SUPABASE] batch document lookup skipped: no document IDs")
            return []
        rows = self._request(
            "GET", "documents",
            params={
                "select": "*",
                "id": f"in.({','.join(document_ids)})",
                "user_id": f"eq.{user_id}",
            },
        )
        return [self._to_metadata(row) for row in rows or []]

    def delete_document_metadata(self, document_id: str, user_id: str) -> dict[str, Any] | None:
        record = self.get_metadata(document_id, user_id)
        if record:
            self._request("DELETE", "documents", params={"id": f"eq.{document_id}", "user_id": f"eq.{user_id}"})
        return record

    @staticmethod
    def _to_metadata(row: dict[str, Any]) -> dict[str, Any]:
        return {
            "id": row["id"], "document_id": row["id"], "user_id": row.get("user_id"),
            "original_filename": row.get("filename", ""),
            "mime_type": row.get("mime_type", ""),
            "content_type": row.get("mime_type", ""), "size_bytes": row.get("file_size", 0),
            "status": row.get("status", ""), "created_at": row.get("created_at"),
            "cloudinary_public_id": row.get("cloudinary_public_id"),
            "cloudinary_url": row.get("cloudinary_url"),
            "cloudinary_asset_id": row.get("cloudinary_asset_id"),
            "cloudinary_resource_type": row.get("cloudinary_resource_type"),
            "error_message": row.get("error_message"),
        }
