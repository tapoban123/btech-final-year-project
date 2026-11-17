from pydantic import BaseModel, Field


class DocumentQueryRequest(BaseModel):
    query: str = Field(min_length=2, max_length=4000)


class QueryCitation(BaseModel):
    document_id: str
    document_name: str
    page: int
    snippet: str | None = None


class DocumentQueryResponse(BaseModel):
    answer: str
    sources: list[QueryCitation]


class MultiDocumentQueryResponse(BaseModel):
    answer: str
    sources: list[QueryCitation]
