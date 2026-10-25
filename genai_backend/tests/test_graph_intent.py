import pytest

from core.graph.nodes import make_classify_intent


class Response:
    content = "general_chat"


class Llm:
    async def ainvoke(self, messages):
        return Response()


@pytest.mark.asyncio
async def test_summary_request_always_uses_document_intent():
    classify = make_classify_intent(Llm())
    result = await classify({
        "query": "Summarize the uploaded document",
        "chat_history": [],
    })
    assert result["intent"] == "document_query"
