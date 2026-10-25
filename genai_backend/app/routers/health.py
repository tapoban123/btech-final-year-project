from __future__ import annotations

from fastapi import APIRouter

router = APIRouter(prefix="/v1", tags=["health"])


@router.get("/health")
async def health_check():
    return {
        "status": "ok",
        "service": "omnidoc-ai",
        "version": "0.1.0",
    }
