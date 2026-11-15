# OmniDoc AI Backend Feature Plan

## Cloudinary, Supabase, Pinecone, and Semantic Document Search

## Objective

Add a backend-only document ingestion feature that supports multiple PDF and image uploads through one multipart request.

For every uploaded file, the backend will:

1. Generate one canonical document UUID.
2. Upload the file to Cloudinary.
3. Store document metadata in Supabase PostgreSQL.
4. Process the document through the existing RAG ingestion pipeline.
5. Store embeddings in Pinecone.
6. Return document metadata and the Cloudinary URL to the client.

The Flutter application is intentionally out of scope for this phase.

## Canonical document identity

Every uploaded file is a separate document and receives its own UUID. The same UUID must be used across all services:

```text
Supabase documents.id         = document_id
Cloudinary public_id           = document_id
Pinecone metadata.document_id = document_id
Pinecone vector ID             = <document_id>_<chunk_index>
```

Original filenames are metadata only. Duplicate filenames are allowed.

The backend will use a configured dummy user ID because authentication is not currently part of the project:

```text
DUMMY_USER_ID=<existing user UUID>
```

The client will not provide the user ID.

## Multi-upload API

Continue using the backend multipart upload route:

```text
POST /api/v1/documents/upload
```

The request accepts multiple files:

```text
files: List[UploadFile]
```

Supported formats remain:

- PDF
- PNG
- JPEG
- WebP

Each file is processed independently. A failure for one file must not invalidate successful files in the same request.

The response should include per-file results:

```json
{
  "user_id": "dummy-user-id",
  "total_files": 2,
  "successful": 1,
  "failed": 1,
  "results": [
    {
      "document_id": "document-uuid",
      "filename": "report.pdf",
      "mime_type": "application/pdf",
      "file_size": 123456,
      "status": "completed",
      "cloudinary_url": "https://...",
      "cloudinary_public_id": "document-uuid",
      "message": "Document uploaded and indexed successfully"
    }
  ]
}
```

## Per-document processing flow

For each file:

1. Validate filename, MIME type, file signature, and size.
2. Generate the canonical document UUID.
3. Insert a Supabase document row with `status = processing`.
4. Upload the file to Cloudinary using the document UUID as its public ID.
5. Save Cloudinary metadata and URL in Supabase.
6. Pass the temporary local file to the existing RAG ingestion pipeline.
7. Store Pinecone vectors using the canonical document UUID.
8. Update Supabase to `status = completed`.
9. Delete the temporary local file.

The existing extraction, chunking, embedding, and generation graph should remain structurally unchanged.

## Supabase metadata

The `public.documents` record should contain:

- UUID document ID
- Dummy user ID
- Original filename
- MIME type
- File size
- Cloudinary URL
- Cloudinary public ID and other Cloudinary metadata
- Processing status
- Error message when processing fails
- Created timestamp
- Updated timestamp

The current JSON metadata implementation should not be used for the new workflow. Local temporary files may still be used during processing, but persistent metadata belongs in Supabase.

## Failure handling and cleanup

The normal status flow is:

```text
processing -> completed
processing -> failed
```

If Supabase insertion fails, Cloudinary must not be called.

If Cloudinary upload fails, mark the document as failed and do not call Pinecone.

If RAG processing fails after Cloudinary succeeds:

- Set Supabase status to `failed`.
- Store the error in `error_message`.
- Delete the Cloudinary asset when possible.
- Delete partially inserted Pinecone vectors when possible.

Cleanup failures should be logged without hiding the original error.

## Pinecone storage

The existing Pinecone index remains in use.

Each chunk vector will contain metadata such as:

```text
document_id
document_name
page
text
```

The Pinecone vector ID will be derived from the canonical document UUID:

```text
<document_uuid>_<chunk_index>
```

Collections are not part of this feature. The dummy user ID should be used as the Pinecone namespace so that semantic search covers all documents belonging to that user.

## Semantic document search

This section concerns semantic search results displayed to the user, not RAG context selection.

Pinecone returns chunk-level matches. The backend should convert those chunk matches into document-level results:

1. Retrieve a larger candidate set, such as the top 30 chunks.
2. Apply a configurable similarity threshold.
3. Group matches by `document_id`.
4. Rank each document using its strongest matching chunk and a small bonus for additional strong chunks.
5. Limit the number of chunks contributed by one document.
6. Return one result per document.

Recommended starting values:

```text
Pinecone candidate chunks: 30
Final document results: 10
Maximum chunks per document: 3
Maximum returned source documents: 10
```

The response should contain:

```text
document_id
filename
cloudinary_url
similarity_score
page
snippet
```

The Cloudinary URL should be retrieved from Supabase metadata and returned directly. The frontend should not need to reconstruct Cloudinary URLs.

### MMR and confidence

MMR can be introduced if chunk-level results remain too repetitive. It should be applied to the candidate results after the initial Pinecone query, with a starting relevance/diversity value around `0.7`.

However, document grouping and a per-document chunk limit are the first recommended implementation because they directly solve the requirement of preventing one document from occupying all search-result positions.

Pinecone similarity scores are not calibrated confidence percentages. A similarity threshold should be evaluated using representative search queries and relevant/irrelevant result labels. The API should return the score as a ranking signal, not as a user-facing confidence claim.

## Query and document endpoints

The new user-scoped workflow should provide:

```text
POST /api/v1/documents/query
GET  /api/v1/documents
DELETE /api/v1/documents/{document_id}
```

The backend automatically applies `DUMMY_USER_ID` and does not accept ownership from the client.

Document deletion must verify ownership, delete Pinecone vectors, delete the Cloudinary asset, and delete the Supabase row.

Collection-specific routes may remain temporarily for compatibility but are not part of the new feature design.

## Expected backend changes

Existing files likely to change:

- `api/documents.py`
- `services/rag_pipeline.py`
- `models/document.py`
- `models/rag.py`
- `services/document_storage.py`
- `main.py`
- `requirements.txt`
- `env_example`

New modules likely needed:

```text
config.py
db/session.py
db/models.py
services/document_repository.py
services/cloudinary_storage.py
```

The SQLAlchemy layer should use asynchronous PostgreSQL access through `asyncpg`.

## Recommended implementation sequence

1. Add centralized environment configuration.
2. Add Cloudinary configuration and upload service.
3. Add asynchronous SQLAlchemy engine, session management, and document model.
4. Add a Supabase document repository.
5. Update the upload endpoint for multi-file processing.
6. Implement canonical UUID propagation through Cloudinary, Supabase, and Pinecone.
7. Add status and error updates.
8. Change Pinecone namespace scope from collection ID to dummy user ID.
9. Implement document-level semantic search aggregation.
10. Add document listing and ownership-checked deletion.
11. Add cleanup handling for partial failures.
12. Add backend tests and integration checks.

## Testing requirements

Test the following cases:

- Single-file PDF upload.
- Multi-file PDF upload.
- Mixed PDF and image upload.
- Duplicate original filenames.
- Invalid MIME type.
- Invalid PDF signature.
- Empty and oversized files.
- Partial success in a multi-upload request.
- Cloudinary failure.
- Supabase failure.
- Pinecone failure.
- RAG extraction failure.
- Shared document ID across all services.
- Document search returning one result per document.
- One document not occupying every result position.
- Similarity threshold filtering.
- Document deletion and cleanup.

## Scope and assumptions

- Backend only; Flutter is not modified.
- Authentication is deferred.
- A dummy user ID is used from environment configuration.
- Collections are excluded from the new design.
- PDFs and common image formats are supported.
- Existing RAG extraction and indexing logic is preserved.
- Supabase stores document metadata.
- Cloudinary stores document files.
- Pinecone stores embeddings and chunk metadata.
- The Supabase UUID is the single canonical document identifier.
