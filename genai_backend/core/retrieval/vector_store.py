from __future__ import annotations

import json
import logging
from pathlib import Path
from typing import Optional

import faiss
import numpy as np
from langchain_core.documents import Document

logger = logging.getLogger(__name__)


class FaissVectorStore:
    def __init__(self, base_dir: str):
        self._base_dir = Path(base_dir)
        self._base_dir.mkdir(parents=True, exist_ok=True)
        self._indexes: dict[str, faiss.Index] = {}
        self._metadata: dict[str, list[dict]] = {}
        self._documents: dict[str, list[str]] = {}

    def _collection_dir(self, collection_id: str) -> Path:
        d = self._base_dir / collection_id
        d.mkdir(parents=True, exist_ok=True)
        return d

    def _load_collection(self, collection_id: str):
        if collection_id in self._indexes:
            return

        cdir = self._collection_dir(collection_id)
        index_path = cdir / "index.faiss"
        meta_path = cdir / "metadata.json"

        if index_path.exists() and meta_path.exists():
            self._indexes[collection_id] = faiss.read_index(str(index_path))
            with open(meta_path) as f:
                data = json.load(f)
            self._metadata[collection_id] = data["metadata"]
            self._documents[collection_id] = data["texts"]
        else:
            self._indexes[collection_id] = None
            self._metadata[collection_id] = []
            self._documents[collection_id] = []

    def _save_collection(self, collection_id: str):
        cdir = self._collection_dir(collection_id)
        idx = self._indexes.get(collection_id)
        if idx is not None:
            faiss.write_index(idx, str(cdir / "index.faiss"))
        with open(cdir / "metadata.json", "w") as f:
            json.dump(
                {
                    "metadata": self._metadata[collection_id],
                    "texts": self._documents[collection_id],
                },
                f,
            )

    async def add(
        self,
        docs: list[Document],
        embeddings: list[list[float]],
        collection_id: str,
    ):
        if not docs:
            return

        self._load_collection(collection_id)

        vectors = np.array(embeddings, dtype=np.float32)
        faiss.normalize_L2(vectors)

        idx = self._indexes[collection_id]
        if idx is None:
            dim = vectors.shape[1]
            idx = faiss.IndexFlatIP(dim)
            self._indexes[collection_id] = idx

        idx.add(vectors)

        for doc in docs:
            self._metadata[collection_id].append(doc.metadata)
            self._documents[collection_id].append(doc.page_content)

        self._save_collection(collection_id)

    async def search(
        self,
        query_embedding: list[float],
        collection_id: str,
        k: int = 10,
        filter_doc_ids: Optional[list[str]] = None,
    ) -> list[Document]:
        self._load_collection(collection_id)

        idx = self._indexes.get(collection_id)
        if idx is None or idx.ntotal == 0:
            return []

        query_vec = np.array([query_embedding], dtype=np.float32)
        faiss.normalize_L2(query_vec)

        fetch_k = min(k * 3, idx.ntotal)
        scores, indices = idx.search(query_vec, fetch_k)

        results = []
        for score, i in zip(scores[0], indices[0]):
            if i < 0:
                continue
            meta = self._metadata[collection_id][i]
            text = self._documents[collection_id][i]

            if filter_doc_ids and meta.get("doc_id") not in filter_doc_ids:
                continue

            doc = Document(page_content=text, metadata={**meta, "score": float(score)})
            results.append(doc)

        return results[:k]

    async def delete(self, doc_id: str, collection_id: str):
        self._load_collection(collection_id)

        meta_list = self._metadata.get(collection_id, [])
        text_list = self._documents.get(collection_id, [])

        keep_indices = [
            i for i, m in enumerate(meta_list) if m.get("doc_id") != doc_id
        ]

        if len(keep_indices) == len(meta_list):
            return

        self._metadata[collection_id] = [meta_list[i] for i in keep_indices]
        self._documents[collection_id] = [text_list[i] for i in keep_indices]

        idx = self._indexes.get(collection_id)
        if idx is not None and idx.ntotal > 0:
            all_vectors = faiss.rev_swig_ptr(
                idx.get_xb(), idx.ntotal * idx.d
            ).reshape(idx.ntotal, idx.d).copy()

            kept = all_vectors[keep_indices] if keep_indices else np.zeros(
                (0, idx.d), dtype=np.float32
            )

            new_idx = faiss.IndexFlatIP(idx.d)
            if len(kept) > 0:
                new_idx.add(kept)
            self._indexes[collection_id] = new_idx

        self._save_collection(collection_id)
