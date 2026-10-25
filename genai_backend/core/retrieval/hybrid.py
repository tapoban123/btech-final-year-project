from __future__ import annotations

from collections import defaultdict
from typing import Optional

from langchain_core.documents import Document

from core.retrieval.vector_store import FaissVectorStore
from core.retrieval.bm25_store import Bm25Store
from core.retrieval.embeddings import EmbeddingService


class HybridRetriever:
    def __init__(
        self,
        vector_store: FaissVectorStore,
        bm25_store: Bm25Store,
        embedding_service: EmbeddingService,
        config,
    ):
        self.vector_store = vector_store
        self.bm25_store = bm25_store
        self.embedding_service = embedding_service
        self.config = config

    async def retrieve(
        self,
        query: str,
        collection_id: str,
        doc_ids: Optional[list[str]] = None,
    ) -> list[Document]:
        query_embedding = await self.embedding_service.embed_query(query)

        vector_results = await self.vector_store.search(
            query_embedding,
            collection_id,
            k=self.config.top_k * 2,
            filter_doc_ids=doc_ids,
        )

        bm25_results = self.bm25_store.search(
            query,
            collection_id,
            k=self.config.top_k * 2,
            filter_doc_ids=doc_ids,
        )

        merged = self._reciprocal_rank_fusion(vector_results, bm25_results)

        capped = self._cap_per_doc(merged, self.config.max_chunks_per_doc)

        return capped[: self.config.top_k]

    def _reciprocal_rank_fusion(
        self,
        *result_lists: list[Document],
        k: int = 60,
    ) -> list[Document]:
        scores: dict[str, float] = defaultdict(float)
        doc_map: dict[str, Document] = {}

        for results in result_lists:
            for rank, doc in enumerate(results):
                key = doc.metadata.get("chunk_id", doc.page_content[:100])
                scores[key] += 1.0 / (k + rank + 1)
                if key not in doc_map:
                    doc_map[key] = doc

        sorted_keys = sorted(scores, key=scores.get, reverse=True)
        return [doc_map[k] for k in sorted_keys if k in doc_map]

    def _cap_per_doc(
        self, docs: list[Document], max_per_doc: int
    ) -> list[Document]:
        counts: dict[str, int] = defaultdict(int)
        capped = []
        for doc in docs:
            did = doc.metadata.get("doc_id", "unknown")
            if counts[did] < max_per_doc:
                capped.append(doc)
                counts[did] += 1
        return capped
