from __future__ import annotations

from typing import AsyncGenerator

from fastapi import Depends, FastAPI, Header, HTTPException
from sqlalchemy.ext.asyncio import AsyncSession

from app.config import Settings, PipelineConfig
from app.models.tables import get_async_session_factory


async def get_db_session() -> AsyncGenerator[AsyncSession, None]:
    factory = get_async_session_factory()
    async with factory() as session:
        yield session


async def verify_api_key(x_api_key: str = Header(default="")) -> str:
    from app.config import get_settings
    settings = get_settings()
    if settings.api_key and x_api_key != settings.api_key:
        raise HTTPException(status_code=401, detail="Invalid API key")
    return x_api_key


def get_retriever(app: FastAPI):
    return app.state.retriever


def get_query_graph(app: FastAPI):
    return app.state.query_graph


def get_chat_manager(app: FastAPI):
    return app.state.chat_manager


async def init_services(app: FastAPI, settings: Settings, config: PipelineConfig):
    import os
    os.environ.setdefault("GROQ_API_KEY", settings.groq_api_key)

    from core.retrieval.embeddings import EmbeddingService
    from core.retrieval.vector_store import FaissVectorStore
    from core.retrieval.bm25_store import Bm25Store
    from core.retrieval.hybrid import HybridRetriever
    from core.chat.manager import ChatManager
    from core.graph.builder import build_query_graph

    embedding_service = EmbeddingService(config.retrieval.embedding_model)
    vector_store = FaissVectorStore(str(settings.faiss_dir))
    bm25_store = Bm25Store()

    retriever = HybridRetriever(
        vector_store=vector_store,
        bm25_store=bm25_store,
        embedding_service=embedding_service,
        config=config.retrieval,
    )

    chat_manager = ChatManager(settings.upload_dir / "chats.json")

    query_graph = build_query_graph(
        retriever=retriever,
        config=config,
        checkpointer=chat_manager.checkpointer,
    )

    app.state.retriever = retriever
    app.state.embedding_service = embedding_service
    app.state.vector_store = vector_store
    app.state.bm25_store = bm25_store
    app.state.query_graph = query_graph
    app.state.chat_manager = chat_manager
    app.state.config = config
    app.state.settings = settings


async def shutdown_services(app: FastAPI):
    pass
