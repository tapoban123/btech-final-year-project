from __future__ import annotations

import os
import sys
from pathlib import Path
from unittest.mock import AsyncMock, MagicMock

import pytest
from httpx import ASGITransport, AsyncClient

sys.path.insert(0, str(Path(__file__).resolve().parent.parent))

os.environ.setdefault("GROQ_API_KEY", "test-key")
os.environ.setdefault("TAVILY_API_KEY", "test-key")
os.environ.setdefault("API_KEY", "test-api-key")
os.environ.setdefault("DATABASE_URL", "sqlite+aiosqlite:///./test_omnidoc.db")


@pytest.fixture
def mock_graph():
    graph = AsyncMock()
    graph.ainvoke = AsyncMock(return_value={
        "answer": "Test answer from the pipeline.",
        "sources": [],
        "route": "docs",
        "verdict": {"grounded": True, "answers_question": True},
        "generation_count": 1,
        "latency_ms": 42,
    })
    return graph


@pytest.fixture
def mock_chat_manager():
    manager = MagicMock()
    manager.get_or_create_thread.return_value = {"chat_id": "test-chat-123"}
    manager.get_chat_context.return_value = ("", [])
    manager.set_collection = MagicMock()
    manager.append_turn = AsyncMock()
    manager.checkpointer = MagicMock()
    return manager


@pytest.fixture
def mock_retriever():
    retriever = AsyncMock()
    retriever.retrieve = AsyncMock(return_value=[])
    return retriever


@pytest.fixture
def mock_embedding_service():
    svc = AsyncMock()
    svc.embed_documents = AsyncMock(return_value=[[0.1] * 384])
    svc.embed_query = AsyncMock(return_value=[0.1] * 384)
    return svc


@pytest.fixture
def mock_vector_store():
    store = AsyncMock()
    store.add = AsyncMock()
    store.search = AsyncMock(return_value=[])
    store.delete = AsyncMock()
    return store


@pytest.fixture
def mock_bm25_store():
    store = MagicMock()
    store.add = MagicMock()
    store.search = MagicMock(return_value=[])
    store.delete = MagicMock()
    return store


def _make_test_app(
    mock_graph, mock_chat_manager, mock_retriever,
    mock_embedding_service, mock_vector_store, mock_bm25_store,
):
    from app.main import create_app
    from app.config import get_pipeline_config

    app = create_app()
    config = get_pipeline_config()

    app.state.query_graph = mock_graph
    app.state.chat_manager = mock_chat_manager
    app.state.retriever = mock_retriever
    app.state.embedding_service = mock_embedding_service
    app.state.vector_store = mock_vector_store
    app.state.bm25_store = mock_bm25_store
    app.state.config = config
    app.state.settings = MagicMock()
    return app


@pytest.fixture
async def client(
    mock_graph, mock_chat_manager, mock_retriever,
    mock_embedding_service, mock_vector_store, mock_bm25_store,
):
    app = _make_test_app(
        mock_graph, mock_chat_manager, mock_retriever,
        mock_embedding_service, mock_vector_store, mock_bm25_store,
    )
    transport = ASGITransport(app=app)
    async with AsyncClient(transport=transport, base_url="http://test") as ac:
        yield ac
