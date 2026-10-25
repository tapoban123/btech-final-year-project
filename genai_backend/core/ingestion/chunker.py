from __future__ import annotations

import uuid

from langchain_core.documents import Document
from langchain_text_splitters import RecursiveCharacterTextSplitter


def chunk_text(
    text: str,
    metadata: dict,
    chunk_size: int = 800,
    chunk_overlap: int = 120,
) -> list[Document]:
    if not text.strip():
        return []

    splitter = RecursiveCharacterTextSplitter(
        chunk_size=chunk_size,
        chunk_overlap=chunk_overlap,
        separators=["\n\n", "\n", ". ", " ", ""],
    )

    chunks = splitter.split_text(text)

    documents = []
    for i, chunk in enumerate(chunks):
        chunk_meta = {
            **metadata,
            "chunk_id": f"c_{uuid.uuid4().hex[:8]}",
            "chunk_index": i,
        }
        documents.append(Document(page_content=chunk, metadata=chunk_meta))

    return documents
