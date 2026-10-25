from __future__ import annotations

import logging
from datetime import datetime, timezone
from typing import Optional

from sqlalchemy.ext.asyncio import AsyncSession

from app.errors import JobNotFoundError
from app.models.tables import Job

logger = logging.getLogger(__name__)


async def get_job(job_id: str, session: AsyncSession) -> Job:
    logger.debug("Fetching job %s", job_id)
    job = await session.get(Job, job_id)
    if not job:
        logger.warning("Job %s not found", job_id)
        raise JobNotFoundError(job_id)
    logger.debug("Job %s status: %s, progress: %.1f%%", job_id, job.status, job.progress * 100)
    return job


async def update_job(
    job_id: str,
    session: AsyncSession,
    *,
    status: Optional[str] = None,
    progress: Optional[float] = None,
    error_message: Optional[str] = None,
) -> Job:
    logger.debug("Updating job %s: status=%s, progress=%s", job_id, status, progress)
    job = await session.get(Job, job_id)
    if not job:
        logger.warning("Job %s not found for update", job_id)
        raise JobNotFoundError(job_id)

    if status is not None:
        job.status = status
    if progress is not None:
        job.progress = progress
    if error_message is not None:
        job.error_message = error_message

    if status in ("completed", "failed"):
        job.completed_at = datetime.now(timezone.utc)

    session.add(job)
    await session.commit()
    await session.refresh(job)
    logger.debug("Job %s updated successfully", job_id)
    return job
