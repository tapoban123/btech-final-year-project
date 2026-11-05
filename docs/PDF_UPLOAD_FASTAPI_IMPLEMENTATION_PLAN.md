# Improved Implementation Plan: Batch PDF Upload from Flutter to FastAPI

## 1. Objective

Implement a reliable PDF upload workflow connecting the Flutter Android application to the FastAPI backend.

Users should be able to select multiple PDF files and upload them together in a single API request. The backend must validate each file, store valid PDFs using the project's existing storage mechanism, and save document metadata in SQLite.

This is the first upload milestone for the future RAG pipeline.

## 2. Confirmed Architectural Decisions

| Area | Decision |
|---|---|
| Metadata database | Always use SQLite |
| PDF storage | Reuse existing project storage |
| Flutter platforms | Android only |
| Multiple PDF uploads | One batch API request |
| Authentication | Defer to a later milestone |

These decisions must be followed throughout implementation.

## 3. Scope

### Included
- Select one or multiple PDFs in Flutter.
- Upload all selected PDFs in one batch request.
- Validate each PDF independently.
- Store valid PDFs using existing project storage.
- Save metadata in SQLite.
- Return an individual result for every submitted file.
- Display upload progress and success/failure states.
- Handle network and server errors.
- Add backend and Flutter tests.

### Excluded
- PDF text extraction.
- OCR.
- Text chunking.
- Embedding generation.
- Vector database integration.
- RAG retrieval and question answering.
- Authentication and authorization.
- Document sharing between users.

Do not implement these excluded features in this milestone.

## 4. Phase 0: Inspect the Existing Repository

Before modifying code, inspect both the Flutter frontend and FastAPI backend.

### Flutter inspection
- Locate the existing file picker implementation.
- Inspect UploadBloc and its events and states.
- Inspect UploadRepository.
- Inspect UploadApiClient.
- Inspect the existing PDF preview and upload UI.
- Identify the current document model and error-handling conventions.

### Backend inspection
- Inspect the FastAPI application structure.
- Identify existing API routers and configuration.
- Locate the project's current file-storage mechanism.
- Inspect existing database configuration and dependencies.
- Check whether SQLite is already configured.
- Identify existing document-related models or schemas.

### Required output before implementation
Provide:
1. Existing architecture summary.
2. Files that need modification.
3. New files that need creation.
4. Existing storage mechanism and how it will be reused.
5. SQLite integration approach.
6. Any dependencies that need installation.

**Important:** Do not replace existing architecture unnecessarily. If no suitable project storage mechanism exists, stop and ask for approval before introducing a new one.

## 5. API Contract

### Endpoint

`POST /api/v1/documents/upload-batch`

### Request

Content type: `multipart/form-data`

Use the repeated field name `files` for every selected PDF.

Example:

```text
files: document1.pdf
files: document2.pdf
files: document3.pdf
```

The backend must accept multiple files under the same field name.

### Successful response

Return HTTP 201 when all submitted files are successfully uploaded.

Example:

```json
{
  "total_files": 2,
  "successful": 2,
  "failed": 0,
  "results": [
    {
      "filename": "document1.pdf",
      "document_id": "generated-id-1",
      "status": "uploaded",
      "size_bytes": 120000,
      "message": "File uploaded successfully"
    },
    {
      "filename": "document2.pdf",
      "document_id": "generated-id-2",
      "status": "uploaded",
      "size_bytes": 250000,
      "message": "File uploaded successfully"
    }
  ]
}
```

### Partial success

If some files succeed and others fail, return HTTP 200 with individual results for every file.

Example:

```json
{
  "total_files": 2,
  "successful": 1,
  "failed": 1,
  "results": [
    {
      "filename": "document1.pdf",
      "document_id": "generated-id-1",
      "status": "uploaded",
      "message": "File uploaded successfully"
    },
    {
      "filename": "document2.exe",
      "document_id": null,
      "status": "failed",
      "error": {
        "code": "INVALID_FILE_TYPE",
        "message": "Only PDF files are accepted"
      }
    }
  ]
}
```

A failure in one file must not prevent other valid files from being processed.

### Batch-level errors

Use an appropriate HTTP error response when the entire request cannot be processed, such as:
- No files submitted.
- Request exceeds the configured total batch size.
- Malformed multipart request.
- Unexpected server failure.

Use a consistent error structure:

```json
{
  "detail": {
    "code": "ERROR_CODE",
    "message": "Human-readable explanation"
  }
}
```

## 6. Backend: File Validation

Validate every uploaded file independently.

Required checks:

1. File must have a `.pdf` extension, case-insensitively.
2. MIME type must be `application/pdf`.
3. File must not be empty.
4. File content must begin with the PDF signature `%PDF-`.
5. Each file must not exceed 25 MB.
6. The total batch size must have a configurable limit.

Suggested configuration:

```env
MAX_PDF_SIZE_MB=25
MAX_BATCH_SIZE_MB=100
```

Do not rely only on the filename or MIME type. Validate the actual file content.

### Error codes

| Condition | Error code |
|---|---|
| Invalid extension or content | INVALID_FILE_TYPE |
| Invalid PDF signature | INVALID_FILE |
| Empty file | EMPTY_FILE |
| File exceeds individual limit | FILE_TOO_LARGE |
| Batch exceeds total limit | BATCH_TOO_LARGE |
| Storage failure | UPLOAD_FAILED |

Return per-file errors wherever possible.

## 7. Backend: PDF Storage

Reuse the existing project's storage mechanism.

Implementation requirements:
- Generate a unique ID for every document.
- Never use the original filename directly as a storage path.
- Preserve the original filename as metadata.
- Prevent path traversal and unsafe filename handling.
- Avoid exposing stored PDFs through public URLs.
- Use temporary storage and safe finalization where supported.
- Clean up temporary or partially stored files after failures.

Do not introduce cloud storage or a second local-storage implementation unless repository inspection shows that the existing mechanism cannot support this workflow and approval is obtained.

## 8. Backend: SQLite Metadata

Always use SQLite for document metadata, even if another database is used elsewhere in the project.

Inspect existing database conventions first, but ensure document metadata is persisted in SQLite.

Suggested document fields:

| Field | Purpose |
|---|---|
| id | Unique document ID |
| original_filename | Uploaded filename |
| stored_filename | Generated storage filename or storage key |
| content_type | MIME type |
| size_bytes | File size |
| status | Upload status |
| created_at | Creation timestamp |
| updated_at | Last update timestamp |
| error_message | Optional error information |

Initial successful status:

`uploaded`

Do not store PDF binary content in SQLite. Store only metadata and the reference needed to locate the PDF in existing project storage.

Use transactions and clean up stored files if metadata creation fails.

## 9. Backend: FastAPI Implementation

Implement the batch endpoint using the existing FastAPI architecture.

Responsibilities:
1. Receive the repeated `files` multipart field.
2. Validate the batch request.
3. Validate each file independently.
4. Enforce individual and total size limits.
5. Store valid files using existing project storage.
6. Create SQLite metadata records.
7. Build an individual result for each file.
8. Return the batch response.

Additional requirements:
- Use asynchronous file handling appropriately.
- Read files in bounded chunks rather than loading an unrestricted batch into memory.
- Close uploaded file handles.
- Keep validation, storage, and database logic separated where appropriate.
- Do not perform extraction, embedding, or RAG processing in this endpoint.

## 10. Flutter: API Client

Update the existing UploadApiClient.

It must:
- Accept a list of selected PDF files.
- Build one multipart request.
- Add each file using the multipart field name `files`.
- Send the request to `/api/v1/documents/upload-batch`.
- Use a reasonable connection and response timeout.
- Parse the batch response.
- Preserve each returned document ID.
- Convert API errors into typed application errors.

Android is the only required platform in this milestone. Handle missing file paths and file-access errors clearly.

## 11. Flutter: Repository and BLoC

Preserve the existing UploadBloc and UploadRepository architecture.

### Suggested events
- `UploadFilesRequested`

### Suggested states
- `UploadInitial`
- `UploadInProgress`
- `UploadSuccess`
- `UploadPartialSuccess`
- `UploadFailure`

The state should retain:
- Original filename.
- Local file identifier.
- Upload status.
- Returned document ID, when successful.
- Error message, when unsuccessful.

Use a stable local identifier rather than the filename because multiple files can have the same name.

Keep the UI responsive while the batch request is running.

## 12. Multiple File Upload Behaviour

All selected PDFs must be submitted in one API request.

The backend processes each file independently and returns one result per submitted file.

The frontend must map each result to the correct selected file.

Expected behaviour:
- All files successful: show overall success.
- Some files successful: show partial success and identify failed files.
- All files failed: show failure with individual reasons.
- Network failure: retain the selected files so the user can retry.
- Do not silently discard failed files.

Avoid creating duplicate document records when the user retries after an uncertain network response. Inspect whether the existing project supports idempotency; if not, document this limitation and propose a suitable approach before adding unnecessary complexity.

## 13. Flutter UI and Error Handling

Provide clear feedback for:
- File selection.
- Upload in progress.
- Successful uploads.
- Partial success.
- Failed uploads.
- Network disconnection.
- Server errors.
- Unsupported files.
- File size violations.

Display each filename with its individual upload status.

Do not mark a file as uploaded until the backend confirms success and returns its document ID.

## 14. Testing

### Backend tests
Test:
- One valid PDF.
- Multiple valid PDFs in one request.
- Invalid extension.
- Incorrect MIME type.
- Invalid PDF signature.
- Empty file.
- File exceeding 25 MB.
- Batch exceeding the total size limit.
- Mixed valid and invalid files.
- Duplicate original filenames.
- Storage failure.
- SQLite metadata insertion failure.
- Cleanup after failed storage or database operations.
- Empty batch request.

### Flutter tests
Test:
- Selecting one PDF.
- Selecting multiple PDFs.
- Sending one batch request.
- Parsing successful batch responses.
- Parsing partial-success responses.
- Mapping results to the correct local files.
- Displaying individual errors.
- Handling network failures.
- Retrying failed uploads.

### Integration test
Verify the complete workflow:

Flutter Android app → FastAPI batch endpoint → Existing project storage → SQLite metadata → Batch response → Flutter UI.

## 15. Configuration and Dependencies

- Keep configuration in environment variables where appropriate.
- Add SQLite dependencies only if they are not already available.
- Reuse the project's existing storage dependencies.
- Do not add unnecessary cloud-storage packages.
- Add stored PDF directories and SQLite database files to `.gitignore` where applicable.
- Do not commit uploaded PDFs, temporary files, or local database data.

## 16. Implementation Order

1. Inspect the existing repository.
2. Confirm the existing storage mechanism.
3. Confirm SQLite integration and database conventions.
4. Finalize the batch API contract.
5. Implement backend validation.
6. Implement storage and cleanup.
7. Implement SQLite metadata persistence.
8. Implement the FastAPI batch endpoint.
9. Test the endpoint independently.
10. Update Flutter API client.
11. Update repository and BLoC.
12. Update the upload UI.
13. Test multiple-file upload.
14. Perform end-to-end Android integration testing.
15. Document the API and remaining limitations.

## 17. Codex Implementation Instructions

- Work only within the existing repository.
- Inspect before modifying.
- Preserve existing architecture and naming conventions.
- Do not rewrite unrelated modules.
- Do not implement future RAG features in this milestone.
- Do not add authentication.
- Always use SQLite for document metadata.
- Reuse existing project storage.
- Implement one batch API request for multiple PDFs.
- Add tests for new functionality.
- Explain every new dependency.
- Report files created and modified.
- Report test results and unresolved issues.
- Do not claim a feature works unless it has been tested.

## 18. Definition of Done

The milestone is complete when:

- [ ] Android users can select multiple PDFs.
- [ ] Flutter sends all selected PDFs in one batch request.
- [ ] FastAPI validates every file independently.
- [ ] Individual and total size limits are enforced.
- [ ] Valid PDFs are stored using existing project storage.
- [ ] SQLite metadata is created for every successful upload.
- [ ] Every successful document receives a unique ID.
- [ ] Partial success and individual failures are handled correctly.
- [ ] Flutter displays accurate per-file statuses.
- [ ] Network failures can be handled without losing the selected files.
- [ ] Backend and Flutter tests pass.
- [ ] End-to-end Android integration is verified.
- [ ] No extraction, OCR, embedding, vector database, or authentication work has been added.

## 19. Future RAG Integration

The upload milestone must leave a clean foundation for future processing.

A later milestone can use the returned document IDs to:
1. Retrieve document metadata from SQLite.
2. Locate the original PDF in existing storage.
3. Extract text using PyMuPDF.
4. Preserve page numbers.
5. Split text into chunks.
6. Generate embeddings.
7. Store vectors in the selected vector database.
8. Update document processing status.
9. Use document IDs and page numbers for source citations.

For this milestone, a successfully uploaded document remains in the `uploaded` state. Do not automatically mark it as processed or completed.