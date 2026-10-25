from __future__ import annotations

import asyncio
from functools import partial

from langchain_huggingface import HuggingFaceEmbeddings


class EmbeddingService:
    def __init__(self, model: str = "all-MiniLM-L6-v2"):
        self._embeddings = HuggingFaceEmbeddings(
            model_name=model,
            model_kwargs={"device": "cpu"},
            encode_kwargs={"normalize_embeddings": True},
        )

    async def embed_documents(self, texts: list[str]) -> list[list[float]]:
        loop = asyncio.get_event_loop()
        return await loop.run_in_executor(
            None, partial(self._embeddings.embed_documents, texts)
        )

    async def embed_query(self, text: str) -> list[float]:
        loop = asyncio.get_event_loop()
        return await loop.run_in_executor(
            None, partial(self._embeddings.embed_query, text)
        )

    @property
    def embeddings(self):
        return self._embeddings
