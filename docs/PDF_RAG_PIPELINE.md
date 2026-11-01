# PDF RAG pipeline

The backend now exposes a multi-document question-answering endpoint:

```http
POST /api/v1/documents/query
Content-Type: application/json

{
  "document_ids": ["doc_first", "doc_second"],
  "query": "What is the main conclusion?"
}
```

The response contains one grounded answer and its retrieved page snippets per document:

```json
{
  "query": "What is the main conclusion?",
  "results": [
    {
      "document_id": "doc_first",
      "query": "What is the main conclusion?",
      "answer": "... [p. 4]",
      "citations": [{"page": 4, "snippet": "..."}]
    }
  ]
}
```

The LangGraph sequence is:

```text
pdfloader -> chunking -> vector_databasing -> quering -> retrival -> lmm_call
```

`pdfloader` extracts page text with PyMuPDF. `chunking` creates overlapping page-aware
chunks. `vector_databasing` embeds them with Pinecone-hosted `multilingual-e5-large`
and stores them in a Pinecone namespace named for the document. The query is embedded
and the five nearest chunks are passed to the Groq-hosted `openai/gpt-oss-20b` model, which is instructed to answer
only from that context.

Set `GROQ_API_KEY` and `PINECONE_API_KEY` in `genai_backend/.env` before querying. The
Groq model, Pinecone index, region, and embedding model can be changed with the
`GROQ_MODEL`, `PINECONE_INDEX_NAME`, `PINECONE_REGION`, and
`PINECONE_EMBEDDING_MODEL` settings.
