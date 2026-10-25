from __future__ import annotations

import uuid
from datetime import datetime, timezone
from typing import Optional

from sqlmodel import SQLModel, Field, create_engine
from sqlalchemy.ext.asyncio import AsyncSession, create_async_engine
from sqlalchemy.orm import sessionmaker

from app.config import get_settings


def _utcnow() -> datetime:
    return datetime.now(timezone.utc)


def _new_id() -> str:
    return uuid.uuid4().hex[:16]


class Collection(SQLModel, table=True):
    id: str = Field(default_factory=_new_id, primary_key=True)
    name: str = Field(default="Untitled")
    created_at: datetime = Field(default_factory=_utcnow)


class Document(SQLModel, table=True):
    id: str = Field(default_factory=_new_id, primary_key=True)
    collection_id: str = Field(index=True)
    filename: str
    content_type: str = ""
    size_bytes: int = 0
    page_count: Optional[int] = None
    doc_type: str = "unknown"
    status: str = Field(default="pending")
    file_hash: Optional[str] = None
    created_at: datetime = Field(default_factory=_utcnow)


class Job(SQLModel, table=True):
    id: str = Field(default_factory=_new_id, primary_key=True)
    document_id: str = Field(index=True)
    collection_id: str = Field(index=True)
    status: str = Field(default="queued")
    progress: float = 0.0
    error_message: Optional[str] = None
    created_at: datetime = Field(default_factory=_utcnow)
    completed_at: Optional[datetime] = None


_async_engine = None


def get_async_engine():
    global _async_engine
    if _async_engine is None:
        settings = get_settings()
        _async_engine = create_async_engine(
            settings.database_url,
            echo=settings.debug,
            pool_size=5,
            max_overflow=10,
            pool_pre_ping=True,
            connect_args={"timeout": 10}
        )
    return _async_engine


def get_async_session_factory():
    engine = get_async_engine()
    return sessionmaker(engine, class_=AsyncSession, expire_on_commit=False)


async def create_tables():
    engine = get_async_engine()
    async with engine.begin() as conn:
        await conn.run_sync(SQLModel.metadata.create_all)
