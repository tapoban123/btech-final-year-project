# PDF Upload Specification

## 1. Purpose
Implement real PDF uploads from the Flutter mobile application to the FastAPI backend using `multipart/form-data`. This is the first milestone of the document RAG pipeline.

## 2. Scope

**Included:**
- Select one or multiple PDFs in Flutter.
- Upload actual file bytes to FastAPI.
- Validate file type, signature, and size.
- Store PDFs securely using generated filenames.
- Generate document IDs and metadata records.
- Return upload status and clear error responses.

**Excluded from this milestone:**
- PDF text extraction and OCR.
- Embedding generation and vector storage.
- RAG retrieval and question answering.
- Authentication and authorization.

## 3. Current Project Context

The Flutter application already has:
- `file_picker` integration supporting PDF, DOC, DOCX, and TXT.
- Upload staging through `UploadBloc`.
- `UploadRepository` and `UploadApiClient`.
- PDF preview functionality.

Currently, `UploadApiClient` returns mock responses, while FastAPI only exposes a root endpoint. Replace the mock implementation with a real upload API.

## 4. Upload Flow

1. User selects PDF files through Flutter.
2. Flutter retrieves file paths and metadata.
3. `UploadApiClient` sends file bytes using multipart/form-data.
4. FastAPI validates the uploaded file.
5. Backend generates a document ID and stores the PDF.
6. A document metadata record is created with status `uploaded`.
7. Backend returns the document ID and upload details to Flutter.

## 5. API Contract

**Endpoint:**
`POST /api/v1/documents/upload`

**Request:** `multipart/form-data`

| Field | Type | Required |
|---|---|---|
| item | String metadata for the upload batch | Yes |
| files | One or more binary PDFs; repeat this field for each file | Yes |

Future optional fields: `title`, `collection_id`.

**Success response:** HTTP `201 Created`

```json
{
  "item": "research-documents",
  "total_files": 2,
  "successful": 2,
  "failed": 0,
  "results": [
    {
      "id": "doc_01JABC123",
      "filename": "report.pdf",
      "content_type": "application/pdf",
      "size_bytes": 245760,
      "status": "uploaded",
      "message": "PDF uploaded successfully"
    }
  ]
}
```

The backend-generated `id` is the canonical document identifier for future extraction, indexing, and chat operations.

**Error response format:**

```json
{
  "detail": {
    "code": "INVALID_FILE_TYPE",
    "message": "Only PDF files are supported"
  }
}
```

| HTTP | Error Code | Condition |
|---|---|---|
| 400 | INVALID_FILE | Missing, empty, or unreadable file |
| 413 | FILE_TOO_LARGE | File exceeds size limit |
| 415 | INVALID_FILE_TYPE | Invalid extension, MIME type, or signature |
| 500 | UPLOAD_FAILED | Unexpected storage or server error |

## 6. Backend Validation

The backend must:
- Accept `.pdf` files only.
- Require MIME type `application/pdf`.
- Verify that file bytes begin with `%PDF-`.
- Reject empty files.
- Enforce a configurable maximum size of 25 MB.
- Generate safe storage filenames using document IDs.
- Preserve the original filename only as metadata.
- Prevent path traversal and clean up incomplete uploads.

Flutter filtering is for usability; backend validation is authoritative.

## 7. Backend Architecture

Recommended structure:

```text
genai_backend/
├── main.py
├── api/
│   └── documents.py
├── services/
│   └── document_storage.py
├── models/
│   └── document.py
├── storage/
│   └── .gitkeep
└── requirements.txt
```

**Route responsibilities:**
1. Receive `UploadFile`.
2. Validate filename, MIME type, and PDF signature.
3. Enforce file size while streaming.
4. Generate a document ID and safe storage path.
5. Store the uploaded PDF.
6. Create a metadata record.
7. Return the documented response.

Use environment variables:

```env
UPLOAD_DIR=./storage/uploads
MAX_PDF_SIZE_MB=25
```

Exclude uploaded files from Git. Do not expose storage publicly.

## 8. Flutter Integration

**File picker:**

```dart
FileType.custom
allowedExtensions: ['pdf']
allowMultiple: true
```

The existing DOC, DOCX, and TXT picker functionality may remain, but only PDFs should use this endpoint.

Replace the mock `uploadFileRaw` method with a real multipart request.

Recommended method:

```dart
Future<Map<String, dynamic>> uploadPdf({
  required String filePath,
  required String filename,
});
```

The API client must:
- Read actual file bytes from the local path.
- Send the multipart field named `file`.
- Preserve the original filename.
- Apply request timeouts.
- Parse JSON responses.
- Handle non-2xx responses using typed exceptions.
- Preserve the backend document ID.

The repository must pass the file path, not just the filename.

## 9. Upload State Management

Retain existing queued, processing, completed, and failed states.

Each upload item must store:

```text
documentId
filename
fileSize
status
errorMessage
```

Each file must have an independent upload result. Partial failures must not hide successful uploads.

## 10. Security and Reliability

- Restrict CORS to required development origins.
- Use HTTPS outside local development.
- Add authentication and document ownership checks before production.
- Avoid logging PDF contents or sensitive metadata.
- Apply upload limits, timeouts, and rate limiting.
- Clean up partially written files.
- Never use user-provided filenames as storage paths.

## 11. Testing and Acceptance Criteria

**Backend tests:**
- Valid PDF upload.
- Invalid extension and MIME type.
- Invalid PDF signature.
- Empty and oversized files.
- Storage failure and incomplete-file cleanup.

**Flutter tests:**
- Multipart request construction.
- Successful `201` response.
- Handling `400`, `413`, and `500` errors.
- Multiple uploads and partial failures.

**Definition of Done:**
- Flutter can select and upload real PDFs.
- FastAPI validates and securely stores them.
- Every successful upload receives a backend-generated document ID.
- Upload metadata persists across application refresh.
- Upload states and errors are correctly displayed.
- Mock responses are completely removed from `UploadApiClient`.

## 12. Future RAG Milestone

After completing uploads, implement:

```text
POST /api/v1/documents/{document_id}/process
GET  /api/v1/documents/{document_id}
POST /api/v1/chat
```

The future pipeline will use PyMuPDF for extraction, preserve page numbers, perform text chunking, generate embeddings, store vectors, and retrieve relevant content for question answering. Responses should include document IDs and page-number citations.
