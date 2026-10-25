from __future__ import annotations

import asyncio
import logging
from pathlib import Path
from typing import Callable, Optional

from langchain_core.documents import Document

from core.ingestion.pdf_parser import parse_pdf, parse_image
from core.ingestion.ocr_router import ocr_page
from core.ingestion.ocr_providers import PaddleOcrProvider, VisionLlmOcrProvider
from core.ingestion.chunker import chunk_text

logger = logging.getLogger(__name__)


async def ingest_document(
    file_path: str,
    doc_id: str,
    collection_id: str,
    filename: str,
    vector_store,
    bm25_store,
    embedding_service,
    config,
    on_progress: Optional[Callable] = None,
) -> int:
    path = Path(file_path)
    suffix = path.suffix.lower()

    if suffix == ".pdf":
        pages = parse_pdf(path, min_text_chars=config.ocr.text_layer_min_chars)
    elif suffix in (".png", ".jpg", ".jpeg"):
        pages = parse_image(path)
    else:
        raise ValueError(f"Unsupported file type: {suffix}")

    if on_progress:
        await on_progress(0.2, "processing")

    paddle = PaddleOcrProvider()
    vision = VisionLlmOcrProvider(model=config.llm.main_model)

    all_chunks: list[Document] = []
    semaphore = asyncio.Semaphore(config.ocr.max_parallel_pages)

    async def process_page(page_info):
        async with semaphore:
            try:
                text, was_ocrd, confidence = await ocr_page(
                    page_info,
                    paddle,
                    vision,
                    config.ocr.handwriting_conf_threshold,
                )

                if not text.strip():
                    logger.warning(
                        "Page %d of %s: no text extracted",
                        page_info.page_num, filename,
                    )
                    return []

                doc_type = "handwritten" if was_ocrd and confidence < config.ocr.handwriting_conf_threshold else (
                    "scanned" if was_ocrd else "text"
                )

                metadata = {
                    "doc_id": doc_id,
                    "collection_id": collection_id,
                    "filename": filename,
                    "page": page_info.page_num,
                    "ocr": was_ocrd,
                    "ocr_confidence": round(confidence, 3),
                    "doc_type": doc_type,
                }

                return chunk_text(
                    text,
                    metadata,
                    chunk_size=config.retrieval.chunk_size,
                    chunk_overlap=config.retrieval.chunk_overlap,
                )
            except Exception as e:
                logger.error(
                    "Failed to process page %d of %s: %s",
                    page_info.page_num, filename, e,
                )
                return []

    tasks = [process_page(page) for page in pages]
    results = await asyncio.gather(*tasks)

    for page_chunks in results:
        all_chunks.extend(page_chunks)

    if not all_chunks:
        raise ValueError(f"No text could be extracted from {filename}")

    if on_progress:
        await on_progress(0.6, "indexing")

    texts = [c.page_content for c in all_chunks]
    embeddings = await embedding_service.embed_documents(texts)

    await vector_store.add(all_chunks, embeddings, collection_id)

    if on_progress:
        await on_progress(0.8, "indexing")

    bm25_store.add(all_chunks, collection_id)

    if on_progress:
        await on_progress(0.95, "indexing")

    logger.info(
        "Ingested %s: %d pages, %d chunks", filename, len(pages), len(all_chunks),
    )

    return len(pages)
