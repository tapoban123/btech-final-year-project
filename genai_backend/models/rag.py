from pydantic import BaseModel, Field


class DocumentQueryRequest(BaseModel):
    collection_id: str = Field(min_length=4, max_length=200)
    query: str = Field(min_length=2, max_length=4000)


class QueryCitation(BaseModel):
    document_id: str
    document_name: str
    page: int
    snippet: str | None = None


class DocumentQueryResponse(BaseModel):
    collection_id: str
    answer: str
    sources: list[QueryCitation]


class MultiDocumentQueryResponse(BaseModel):
    collection_id: str
    answer: str
    sources: list[QueryCitation]
