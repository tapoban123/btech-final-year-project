from core.graph.source_tracking import build_source_tracking, normalized_url
from core.graph.nodes import make_generate
from langchain_core.documents import Document


class _Response:
    content = "Grounded answer"


class _Llm:
    async def ainvoke(self, messages):
        return _Response()


def test_source_tracking_deduplicates_pages_and_normalized_urls_per_query():
    sources, by_action = build_source_tracking(
        [
            {"doc_id": "d1", "filename": "guide.pdf", "page": 2, "chunk_id": "a"},
            {"doc_id": "d1", "filename": "guide.pdf", "page": 2, "chunk_id": "b"},
            {"doc_id": "d1", "filename": "guide.pdf", "page": 4, "chunk_id": "c"},
        ],
        [
            {"url": "HTTPS://Example.com:443/path#section", "title": "First"},
            {"url": "https://example.com/path", "title": "Duplicate"},
        ],
        corrective=True, self_rag=True,
    )
    assert [(s["doc_id"], s["page"]) for s in sources if s["type"] == "document"] == [("d1", 2), ("d1", 4)]
    assert [s["url"] for s in sources if s["type"] == "web"] == ["HTTPS://Example.com:443/path#section"]
    assert [s["page"] for s in by_action["Corrective_RAG"]] == [2, 4]
    assert len(by_action["Web_Search"]) == 1
    assert len(by_action["Self_RAG"]) == 3


def test_source_tracking_omits_unknown_pages_and_urls_without_guessing():
    sources, by_action = build_source_tracking(
        [{"doc_id": "d1", "filename": "guide.pdf", "page": None}, {"doc_id": "d2", "filename": "other.pdf", "page": 0}],
        [{"url": ""}, {"url": "not-a-url"}], corrective=False, self_rag=False,
    )
    assert sources == []
    assert by_action == {}
    assert normalized_url("https://EXAMPLE.com:443/a#fragment") == "https://example.com/a"


async def test_generation_preserves_reranked_source_metadata_and_deduplicates():
    generate = make_generate(_Llm())
    page_two = {"doc_id": "d1", "filename": "guide.pdf", "page": 2, "chunk_id": "first"}
    result = await generate({
        "original_query": "Question", "relevant_chunks": [
            Document(page_content="first chunk", metadata=page_two),
            Document(page_content="second chunk", metadata={**page_two, "chunk_id": "second"}),
        ],
        "web_results": [], "retrieval_quality": "correct", "generation_count": 0,
    })
    assert result["sources"] == [{
        "type": "document", "doc_id": "d1", "filename": "guide.pdf", "page": 2,
        "chunk_id": "first", "ocr": None, "ocr_confidence": None,
    }]
    assert result["sources_by_action"] == {"Hybrid_RAG": result["sources"]}


async def test_generation_keeps_the_query_source_ledger_across_self_rag_retries():
    generate = make_generate(_Llm())
    source = {"type": "document", "doc_id": "d1", "filename": "guide.pdf", "page": 2}
    result = await generate({
        "original_query": "Question", "relevant_chunks": [Document(
            page_content="chunk", metadata={**source, "chunk_id": "new"},
        )],
        "web_results": [], "retrieval_quality": "correct", "generation_count": 1,
        "sources": [source], "sources_by_action": {"Hybrid_RAG": [source]},
    })
    assert len(result["sources"]) == 1
    assert set(result["sources_by_action"]) == {"Hybrid_RAG", "Self_RAG"}
