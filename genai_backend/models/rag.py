from pydantic import BaseModel, Field

from models.document import DocumentMetadata


class DocumentQueryRequest(BaseModel):
    query: str = Field(min_length=2, max_length=4000)


class QueryCitation(BaseModel):
    document_id: str
    document_name: str
    page: int
    snippet: str | None = None
    cloudinary_url: str | None = None
    mime_type: str | None = None


class DocumentQueryResponse(BaseModel):
    answer: str
    sources: list[QueryCitation] = Field(default_factory=list)
    documents: list[DocumentMetadata] = Field(
        default_factory=list,
        description="Matched documents with full metadata from storage",
    )


class MultiDocumentQueryResponse(BaseModel):
    answer: str
    sources: list[QueryCitation] = Field(default_factory=list)
    documents: list[DocumentMetadata] = Field(
        default_factory=list,
        description="Matched documents with full metadata from storage",
    )
