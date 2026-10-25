from __future__ import annotations

from contextlib import asynccontextmanager

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from starlette.middleware.base import BaseHTTPMiddleware

from app.config import get_settings, get_pipeline_config
from app.errors import register_error_handlers, request_id_middleware


@asynccontextmanager
async def lifespan(app: FastAPI):
    settings = get_settings()
    config = get_pipeline_config()

    settings.upload_dir.mkdir(parents=True, exist_ok=True)
    settings.faiss_dir.mkdir(parents=True, exist_ok=True)

    from app.models.tables import create_tables
    await create_tables()

    from app.dependencies import init_services
    await init_services(app, settings, config)

    yield

    from app.dependencies import shutdown_services
    await shutdown_services(app)


def create_app() -> FastAPI:
    app = FastAPI(
        title="OmniDoc AI",
        description="Multimodal Document Q&A with Corrective + Self-RAG",
        version="0.1.0",
        lifespan=lifespan,
    )

    app.add_middleware(
        CORSMiddleware,
        allow_origins=["*"],
        allow_credentials=True,
        allow_methods=["*"],
        allow_headers=["*"],
    )
    app.add_middleware(BaseHTTPMiddleware, dispatch=request_id_middleware)

    register_error_handlers(app)

    from app.routers import health, collections, documents, chat
    app.include_router(health.router)
    app.include_router(collections.router)
    app.include_router(documents.router)
    app.include_router(chat.router)

    return app


app = create_app()
