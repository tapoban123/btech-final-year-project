from __future__ import annotations

import logging
import time
from fastapi import APIRouter, Depends, Request, UploadFile, File, BackgroundTasks
from sqlalchemy.ext.asyncio import AsyncSession

from app.dependencies import get_db_session
from app.schemas.document import DocumentUploadResponse
from app.schemas.job import JobStatusResponse
from app.services import document_service, job_service

logger = logging.getLogger(__name__)

router = APIRouter(prefix="/v1", tags=["documents"])


async def _run_ingestion(
    doc_id: str,
    collection_id: str,
    filename: str,
    file_path: str,
    app_state,
):
    from app.models.tables import get_async_session_factory
    from app.services.job_service import update_job
    from sqlmodel import select
    from app.models.tables import Job, Document

    factory = get_async_session_factory()
    start_time = time.time()
    logger.info("Starting ingestion for document %s (%s)", doc_id, filename)

    async with factory() as session:
        result = await session.execute(
            select(Job).where(Job.document_id == doc_id)
        )
        job = result.scalars().first()
        if not job:
            logger.warning("Job not found for document %s", doc_id)
            return
        job_id = job.id

    try:
        async with factory() as session:
            await update_job(job_id, session, status="processing", progress=0.1)
        logger.debug("Job %s marked as processing", job_id)

        from core.ingestion.pipeline import ingest_document

        async def on_progress(progress: float, status: str = "processing"):
            try:
                async with factory() as session:
                    await update_job(job_id, session, status=status, progress=progress)
                logger.debug("Job %s progress: %.1f%% (%s)", job_id, progress * 100, status)
            except Exception as e:
                logger.warning("Failed to update job progress: %s", e)

        logger.debug("Starting pipeline for %s", filename)
        page_count = await ingest_document(
            file_path=file_path,
            doc_id=doc_id,
            collection_id=collection_id,
            filename=filename,
            vector_store=app_state.vector_store,
            bm25_store=app_state.bm25_store,
            embedding_service=app_state.embedding_service,
            config=app_state.config,
            on_progress=on_progress,
        )
        logger.info("Pipeline completed for %s: %d pages", filename, page_count)

        async with factory() as session:
            doc = await session.get(Document, doc_id)
            if doc:
                doc.status = "ready"
                doc.page_count = page_count
                session.add(doc)
                await session.commit()

            await update_job(job_id, session, status="completed", progress=1.0)
            logger.info("Ingestion done for %s (%.1fs)", doc_id, time.time() - start_time)

    except Exception as e:
        elapsed = time.time() - start_time
        logger.exception("Ingestion failed for document %s after %.1fs", doc_id, elapsed)

        async with factory() as session:
            doc = await session.get(Document, doc_id)
            if doc:
                doc.status = "failed"
                session.add(doc)
                await session.commit()

            await update_job(
                job_id, session, status="failed", error_message=str(e)
            )


@router.post(
    "/collections/{collection_id}/documents",
    response_model=list[DocumentUploadResponse],
    status_code=202,
)
async def upload_documents(
    collection_id: str,
    request: Request,
    background_tasks: BackgroundTasks,
    files: list[UploadFile] = File(...),
    session: AsyncSession = Depends(get_db_session),
):
    from app.config import get_settings

    results = []
    for file in files:
        doc, job = await document_service.upload_document(
            collection_id, file, session
        )

        settings = get_settings()
        from pathlib import Path
        suffix = Path(file.filename or "file").suffix
        file_path = str(settings.upload_dir / collection_id / f"{doc.id}{suffix}")

        background_tasks.add_task(
            _run_ingestion,
            doc.id,
            collection_id,
            doc.filename,
            file_path,
            request.app.state,
        )

        results.append(
            DocumentUploadResponse(
                document_id=doc.id,
                job_id=job.id,
                filename=doc.filename,
            )
        )

    return results


@router.get("/jobs/{job_id}", response_model=JobStatusResponse)
async def get_job_status(
    job_id: str,
    session: AsyncSession = Depends(get_db_session),
):
    job = await job_service.get_job(job_id, session)
    return JobStatusResponse(
        job_id=job.id,
        document_id=job.document_id,
        status=job.status,
        progress=job.progress,
        error_message=job.error_message,
        created_at=job.created_at,
        completed_at=job.completed_at,
    )


@router.delete("/documents/{doc_id}", status_code=204)
async def delete_document(
    doc_id: str,
    request: Request,
    session: AsyncSession = Depends(get_db_session),
):
    doc = await document_service.get_document(doc_id, session)

    if hasattr(request.app.state, "vector_store"):
        await request.app.state.vector_store.delete(doc_id, doc.collection_id)
    if hasattr(request.app.state, "bm25_store"):
        request.app.state.bm25_store.delete(doc_id, doc.collection_id)

    await document_service.delete_document(doc_id, session)
