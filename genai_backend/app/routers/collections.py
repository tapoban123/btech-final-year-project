from __future__ import annotations

from fastapi import APIRouter, Depends
from sqlalchemy.ext.asyncio import AsyncSession

from app.dependencies import get_db_session
from app.schemas.collection import CollectionCreate, CollectionResponse
from app.schemas.document import DocumentResponse
from app.services import collection_service, document_service

router = APIRouter(prefix="/v1", tags=["collections"])


@router.get("/collections", response_model=list[CollectionResponse])
async def list_collections(session: AsyncSession = Depends(get_db_session)):
    collections = await collection_service.list_collections(session)
    result = []
    for collection in collections:
        result.append(CollectionResponse(
            id=collection.id,
            name=collection.name,
            created_at=collection.created_at,
            document_count=await collection_service.get_document_count(collection.id, session),
        ))
    return result


@router.post("/collections", response_model=CollectionResponse, status_code=201)
async def create_collection(
    body: CollectionCreate,
    session: AsyncSession = Depends(get_db_session),
):
    collection = await collection_service.create_collection(body.name or "Untitled", session)
    count = await collection_service.get_document_count(collection.id, session)
    return CollectionResponse(
        id=collection.id,
        name=collection.name,
        created_at=collection.created_at,
        document_count=count,
    )


@router.get(
    "/collections/{collection_id}/documents",
    response_model=list[DocumentResponse],
)
async def list_documents(
    collection_id: str,
    session: AsyncSession = Depends(get_db_session),
):
    await collection_service.get_collection(collection_id, session)
    docs = await document_service.list_documents(collection_id, session)
    return [
        DocumentResponse(
            id=d.id,
            collection_id=d.collection_id,
            filename=d.filename,
            content_type=d.content_type,
            size_bytes=d.size_bytes,
            page_count=d.page_count,
            doc_type=d.doc_type,
            status=d.status,
            created_at=d.created_at,
        )
        for d in docs
    ]
