from __future__ import annotations

from sqlalchemy.ext.asyncio import AsyncSession
from sqlmodel import select, func

from app.errors import CollectionNotFoundError
from app.models.tables import Collection, Document


async def create_collection(name: str, session: AsyncSession) -> Collection:
    collection = Collection(name=name)
    session.add(collection)
    await session.commit()
    await session.refresh(collection)
    return collection


async def get_collection(collection_id: str, session: AsyncSession) -> Collection:
    result = await session.get(Collection, collection_id)
    if not result:
        raise CollectionNotFoundError(collection_id)
    return result


async def list_collections(session: AsyncSession) -> list[Collection]:
    result = await session.execute(select(Collection).order_by(Collection.created_at.desc()))
    return list(result.scalars().all())


async def get_document_count(collection_id: str, session: AsyncSession) -> int:
    result = await session.execute(
        select(func.count(Document.id)).where(Document.collection_id == collection_id)
    )
    return result.scalar() or 0
