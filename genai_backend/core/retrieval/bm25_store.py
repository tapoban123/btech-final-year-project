from __future__ import annotations

import re
from typing import Optional

from langchain_core.documents import Document
from rank_bm25 import BM25Okapi


def _tokenize(text: str) -> list[str]:
    return re.findall(r"\w+", text.lower())


class Bm25Store:
    def __init__(self):
        self._corpora: dict[str, list[list[str]]] = {}
        self._docs: dict[str, list[Document]] = {}
        self._indexes: dict[str, Optional[BM25Okapi]] = {}

    def _rebuild_index(self, collection_id: str):
        corpus = self._corpora.get(collection_id, [])
        if corpus:
            self._indexes[collection_id] = BM25Okapi(corpus)
        else:
            self._indexes[collection_id] = None

    def add(self, docs: list[Document], collection_id: str):
        if collection_id not in self._corpora:
            self._corpora[collection_id] = []
            self._docs[collection_id] = []

        for doc in docs:
            tokens = _tokenize(doc.page_content)
            self._corpora[collection_id].append(tokens)
            self._docs[collection_id].append(doc)

        self._rebuild_index(collection_id)

    def search(
        self,
        query: str,
        collection_id: str,
        k: int = 10,
        filter_doc_ids: Optional[list[str]] = None,
    ) -> list[Document]:
        idx = self._indexes.get(collection_id)
        if idx is None:
            return []

        tokens = _tokenize(query)
        if not tokens:
            return []

        scores = idx.get_scores(tokens)
        doc_list = self._docs[collection_id]

        scored = []
        for i, score in enumerate(scores):
            if score <= 0:
                continue
            doc = doc_list[i]
            if filter_doc_ids and doc.metadata.get("doc_id") not in filter_doc_ids:
                continue
            scored.append((score, doc))

        scored.sort(key=lambda x: x[0], reverse=True)
        return [doc for _, doc in scored[:k]]

    def delete(self, doc_id: str, collection_id: str):
        if collection_id not in self._docs:
            return

        keep = [
            (tokens, doc)
            for tokens, doc in zip(
                self._corpora[collection_id], self._docs[collection_id]
            )
            if doc.metadata.get("doc_id") != doc_id
        ]

        if keep:
            self._corpora[collection_id] = [t for t, _ in keep]
            self._docs[collection_id] = [d for _, d in keep]
        else:
            self._corpora[collection_id] = []
            self._docs[collection_id] = []

        self._rebuild_index(collection_id)
