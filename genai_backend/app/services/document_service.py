from __future__ import annotations

import hashlib
from pathlib import Path

from fastapi import UploadFile
from sqlalchemy.ext.asyncio import AsyncSession
from sqlmodel import select

from app.config import get_settings, get_pipeline_config
from app.errors import (
    CollectionNotFoundError,
    DocumentNotFoundError,
    UnsupportedFileError,
    FileTooLargeError,
)
from app.models.tables import Collection, Document, Job

ALLOWED_CONTENT_TYPES = {
    "application/pdf",
    "image/png",
    "image/jpeg",
    "image/jpg",
}


async def upload_document(
    collection_id: str,
    file: UploadFile,
    session: AsyncSession,
) -> tuple[Document, Job]:
    collection = await session.get(Collection, collection_id)
    if not collection:
        raise CollectionNotFoundError(collection_id)

    if file.content_type not in ALLOWED_CONTENT_TYPES:
        raise UnsupportedFileError(
            f"File type '{file.content_type}' not supported. "
            f"Allowed: PDF, PNG, JPG"
        )

    config = get_pipeline_config()
    content = await file.read()
    size_bytes = len(content)
    max_bytes = config.api.max_file_mb * 1024 * 1024

    if size_bytes > max_bytes:
        raise FileTooLargeError(config.api.max_file_mb)

    file_hash = hashlib.sha256(content).hexdigest()

    doc = Document(
        collection_id=collection_id,
        filename=file.filename or "unnamed",
        content_type=file.content_type or "",
        size_bytes=size_bytes,
        file_hash=file_hash,
        status="pending",
    )
    session.add(doc)

    job = Job(
        document_id=doc.id,
        collection_id=collection_id,
        status="queued",
    )
    session.add(job)
    await session.commit()
    await session.refresh(doc)
    await session.refresh(job)

    settings = get_settings()
    doc_dir = settings.upload_dir / collection_id
    doc_dir.mkdir(parents=True, exist_ok=True)
    suffix = Path(file.filename or "file").suffix
    file_path = doc_dir / f"{doc.id}{suffix}"
    file_path.write_bytes(content)

    return doc, job


async def list_documents(
    collection_id: str, session: AsyncSession
) -> list[Document]:
    result = await session.execute(
        select(Document)
        .where(Document.collection_id == collection_id)
        .order_by(Document.created_at.desc())
    )
    return list(result.scalars().all())


async def get_document(doc_id: str, session: AsyncSession) -> Document:
    doc = await session.get(Document, doc_id)
    if not doc:
        raise DocumentNotFoundError(doc_id)
    return doc


async def delete_document(doc_id: str, session: AsyncSession) -> None:
    doc = await session.get(Document, doc_id)
    if not doc:
        raise DocumentNotFoundError(doc_id)

    settings = get_settings()
    doc_dir = settings.upload_dir / doc.collection_id
    for f in doc_dir.glob(f"{doc_id}.*"):
        f.unlink(missing_ok=True)

    jobs = await session.execute(select(Job).where(Job.document_id == doc_id))
    for job in jobs.scalars().all():
        await session.delete(job)

    await session.delete(doc)
    await session.commit()
