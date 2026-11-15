"""Cloudinary adapter for document assets."""

from __future__ import annotations

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

    def upload(self, file_path: Path, *, public_id: str, content_type: str) -> dict[str, Any]:
        self._configure()
        resource_type = "image" if content_type.startswith("image/") else "raw"
        return cloudinary.uploader.upload(
            str(file_path), public_id=public_id, resource_type=resource_type,
            overwrite=False, invalidate=True,
        )

    def delete(self, *, public_id: str, content_type: str) -> None:
        self._configure()
        resource_type = "image" if content_type.startswith("image/") else "raw"
        cloudinary.uploader.destroy(public_id, resource_type=resource_type, invalidate=True)
