"""Cloudinary adapter for document assets."""

from __future__ import annotations

import io
import os
from pathlib import Path
from typing import Any

import cloudinary
import cloudinary.uploader


class CloudinaryStorage:
    def __init__(self) -> None:
        self._configured = False

    def _configure(self) -> None:
        if self._configured:
            return
        cloudinary_url = os.getenv("CLOUDINARY_URL", "").strip()
        if cloudinary_url:
            cloudinary.config(cloudinary_url=cloudinary_url, secure=True)
        else:
            values = [os.getenv(key, "").strip() for key in (
                "CLOUDINARY_CLOUD_NAME", "CLOUDINARY_API_KEY", "CLOUDINARY_API_SECRET"
            )]
            if not all(values):
                raise RuntimeError("Cloudinary credentials are not configured")
            cloudinary.config(
                cloud_name=values[0], api_key=values[1], api_secret=values[2], secure=True
            )
        self._configured = True

    def upload(
        self,
        file_data: bytes | io.BytesIO | Path | str,
        *,
        public_id: str,
        content_type: str,
        context: dict[str, str] | None = None,
        tags: list[str] | None = None,
    ) -> dict[str, Any]:
        self._configure()
        upload_kwargs: dict[str, Any] = {
            "public_id": public_id,
            "context": context or {},
            "tags": tags or [],
            "overwrite": False,
            "invalidate": True,
        }
        if content_type == "application/pdf":
            upload_kwargs["resource_type"] = "image"
            upload_kwargs["format"] = "pdf"
        elif content_type.startswith("image/"):
            upload_kwargs["resource_type"] = "image"
        else:
            upload_kwargs["resource_type"] = "raw"

        if isinstance(file_data, bytes):
            upload_source = io.BytesIO(file_data)
        elif isinstance(file_data, (Path, str)):
            upload_source = str(file_data)
        else:
            upload_source = file_data
        return cloudinary.uploader.upload(upload_source, **upload_kwargs)

    def delete(
        self,
        *,
        public_id: str,
        content_type: str = "",
        resource_type: str | None = None,
    ) -> None:
        self._configure()
        if not resource_type:
            resource_type = (
                "image"
                if (content_type.startswith("image/") or content_type == "application/pdf")
                else "raw"
            )
        cloudinary.uploader.destroy(public_id, resource_type=resource_type, invalidate=True)
