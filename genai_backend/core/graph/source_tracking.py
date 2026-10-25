"""Canonical source provenance for a single query-graph invocation."""

from __future__ import annotations

from typing import Any, Iterable
from urllib.parse import urlsplit, urlunsplit


def normalized_url(url: object) -> str | None:
    """Return a comparison key for an absolute HTTP(S) URL, without changing it."""
    if not isinstance(url, str) or not url.strip():
        return None
    value = url.strip()
    parsed = urlsplit(value)
    if parsed.scheme.lower() not in {"http", "https"} or not parsed.netloc:
        return None
    host = parsed.hostname
    if not host:
        return None
    try:
        port = parsed.port
    except ValueError:
        return None
    default_port = (parsed.scheme.lower() == "http" and port == 80) or (
        parsed.scheme.lower() == "https" and port == 443
    )
    netloc = host.lower()
    if port and not default_port:
        netloc = f"{netloc}:{port}"
    if parsed.username:
        netloc = f"{parsed.username}@{netloc}"
    return urlunsplit((parsed.scheme.lower(), netloc, parsed.path or "/", parsed.query, ""))


def document_source(metadata: dict[str, Any]) -> dict[str, Any] | None:
    """Create a PDF source only when its identity and page are known exactly."""
    doc_id, filename, page = metadata.get("doc_id"), metadata.get("filename"), metadata.get("page")
    if (
        not isinstance(doc_id, str) or not doc_id
        or not isinstance(filename, str) or not filename
        or isinstance(page, bool) or not isinstance(page, int) or page < 1
    ):
        return None
    return {
        "type": "document", "doc_id": doc_id, "filename": filename, "page": page,
        "chunk_id": metadata.get("chunk_id") or None, "ocr": metadata.get("ocr"),
        "ocr_confidence": metadata.get("ocr_confidence"),
    }


def web_source(result: dict[str, Any]) -> dict[str, Any] | None:
    """Create a web source only when the result supplied an exact usable URL."""
    url = result.get("url")
    if normalized_url(url) is None:
        return None
    return {"type": "web", "url": url.strip(), "title": result.get("title") or None}


def source_key(source: dict[str, Any]) -> tuple[str, str, object] | None:
    if source.get("type") == "document":
        doc_id, page = source.get("doc_id"), source.get("page")
        if isinstance(doc_id, str) and doc_id and isinstance(page, int) and not isinstance(page, bool):
            return ("document", doc_id, page)
    elif source.get("type") == "web":
        key = normalized_url(source.get("url"))
        if key:
            return ("web", key, None)
    return None


def unique_sources(sources: Iterable[dict[str, Any]]) -> list[dict[str, Any]]:
    """Keep the first exact source for each document/page or normalized URL."""
    seen: set[tuple[str, str, object]] = set()
    unique: list[dict[str, Any]] = []
    for source in sources:
        key = source_key(source)
        if key is not None and key not in seen:
            seen.add(key)
            unique.append(source)
    return unique


def build_source_tracking(
    document_metadata: Iterable[dict[str, Any]], web_results: Iterable[dict[str, Any]], *,
    corrective: bool, self_rag: bool,
) -> tuple[list[dict[str, Any]], dict[str, list[dict[str, Any]]]]:
    """Return global unique sources plus sources used by each RAG action."""
    documents = unique_sources(source for metadata in document_metadata if (source := document_source(metadata)))
    web = unique_sources(source for result in web_results if (source := web_source(result)))
    by_action: dict[str, list[dict[str, Any]]] = {}
    if documents:
        by_action["Corrective_RAG" if corrective else "Hybrid_RAG"] = documents
    if web:
        by_action["Web_Search"] = web
    if self_rag:
        retry_sources = unique_sources([*documents, *web])
        if retry_sources:
            by_action["Self_RAG"] = retry_sources
    return unique_sources([*documents, *web]), by_action
