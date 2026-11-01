# PDF Upload to FastAPI Implementation Plan

This plan implements [PDF_UPLOAD_FASTAPI_SPEC.md](PDF_UPLOAD_FASTAPI_SPEC.md): a real PDF upload flow from the Flutter frontend to the FastAPI backend.

## Quick environment setup

From the repository root:

```powershell
cd genai_backend
Copy-Item .env.example .env
python -m venv .venv
.venv\Scripts\Activate.ps1
python -m pip install --upgrade pip
pip install -r requirements.txt
uvicorn main:app --reload --host 0.0.0.0 --port 8000
```

In a second terminal:

```powershell
cd mobile_app
flutter pub get
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8000
```

Use `http://127.0.0.1:8000` for an iOS simulator or desktop Flutter run. For a physical phone, replace the host with the computer's LAN IP and ensure both devices are on the same network.

## 1. Target outcome

When the user selects a PDF and taps **Confirm Upload**:

1. Flutter sends the actual PDF bytes as `multipart/form-data`.
2. FastAPI validates the file.
3. FastAPI stores the PDF with a generated safe ID.
4. FastAPI returns the document ID and upload status.
5. Flutter updates the item from queued to completed or failed.

The implementation must remove the current mock upload response while keeping the existing upload UI and repository boundaries.

## 2. Work breakdown

### Phase 0 — Baseline and configuration

Tasks:

- Review the current upload screen, BLoC, repository, API client, and models.
- Confirm the backend and mobile app run independently in local development.
- Add a backend `.env.example` or configuration section containing:

  ```text
  UPLOAD_DIR=./storage/uploads
  MAX_PDF_SIZE_MB=25
  API_BASE_URL=http://10.0.2.2:8000
  ```

- Add upload storage paths to `.gitignore`.
- Decide the local device URL: `10.0.2.2` for Android emulator, `127.0.0.1` for simulator/desktop, or the development machine LAN IP for a physical device.

Deliverable: both applications have a documented local API base URL and a safe ignored upload directory.

### Phase 1 — FastAPI upload endpoint

Files to add or modify:

```text
genai_backend/main.py
genai_backend/api/documents.py
genai_backend/services/document_storage.py
genai_backend/models/document.py
genai_backend/requirements.txt
```

Tasks:

- Add the `POST /api/v1/documents/upload` route.
- Accept `UploadFile = File(...)` with the form field name `file`.
- Create a response model for successful uploads.
- Create consistent error responses with `code` and `message`.
- Register the documents router in `main.py`.
- Configure the upload directory at application startup or on first use.

Suggested response model:

```python
class DocumentUploadResponse(BaseModel):
    id: str
    filename: str
    content_type: str
    size_bytes: int
    status: str
    message: str
```

Deliverable: a valid PDF can be uploaded with curl or Swagger UI and receives HTTP `201`.

### Phase 2 — Backend validation and storage

Implement validation before permanently storing the file.

Validation order:

1. Confirm a file was provided.
2. Confirm the filename has a `.pdf` extension.
3. Confirm the declared MIME type is acceptable.
4. Stream the file in bounded chunks.
5. Reject files larger than `MAX_PDF_SIZE_MB`.
6. Reject empty files.
7. Verify the first bytes contain the PDF signature `%PDF-`.
8. Generate a document ID with `uuid4` or an equivalent ID generator.
9. Store using a generated filename such as `{document_id}.pdf`.

Storage rules:

- Never build a path from the original filename.
- Write to a temporary file first.
- Rename the temporary file only after validation succeeds.
- Delete the temporary file if any operation fails.
- Store the original filename only as metadata.

Deliverable: invalid files are rejected without leaving partial files behind.

### Phase 3 — Document metadata persistence

Start with a simple repository abstraction so storage is not coupled to the route.

Minimum metadata:

```text
id
original_filename
stored_filename
content_type
size_bytes
status
created_at
owner_id (nullable until authentication exists)
```

For the first local milestone, metadata may be stored in SQLite or a JSON-backed repository. SQLite is preferred because the later RAG pipeline will need document status and processing metadata.

Initial statuses:

```text
uploaded
processing
ready
failed
```

At upload completion, set the status to `uploaded`. Do not mark the document `ready` until extraction and indexing are implemented.

Deliverable: a document can be looked up by the returned ID after the upload request finishes.

### Phase 4 — Flutter HTTP client

Files to modify:

```text
mobile_app/pubspec.yaml
mobile_app/lib/features/upload/api/upload_api_client.dart
mobile_app/lib/features/upload/repository/upload_repository.dart
```

Tasks:

- Add an HTTP dependency if one is not already present. Use one client consistently, such as `http` or `dio`.
- Add a configurable base URL.
- Implement a multipart request with a `file` part.
- Read the file from the `filePath` already captured by `PlatformFile`.
- Send the original filename as the multipart filename.
- Add a connection and upload timeout.
- Parse the `201` JSON response.
- Convert backend errors into a typed exception containing the backend error code.
- Preserve the returned `id` in the mapped upload model.

Recommended client method:

```dart
Future<Map<String, dynamic>> uploadPdf({
  required String filePath,
  required String filename,
});
```

Important change: the current method accepts only `filename` and `fileType`. It must accept and transmit `filePath`; sending a filename alone is not a real upload.

Deliverable: the Flutter app can upload a real local PDF to the FastAPI endpoint.

### Phase 5 — Flutter model and BLoC integration

Files to modify:

```text
mobile_app/lib/features/upload/repository/models/upload_item.dart
mobile_app/lib/features/upload/repository/upload_repository.dart
mobile_app/lib/features/upload/blocs/upload_bloc.dart
mobile_app/lib/features/upload/blocs/upload_state.dart
```

Tasks:

- Add `documentId` to `UploadItem`.
- Add an optional `errorMessage` field.
- Pass `filePath` from the staged item to the repository.
- Use the backend response ID when replacing a staged item.
- Preserve each item’s local path and size after a successful upload.
- Handle multiple uploads independently.
- Mark successful responses as completed.
- Mark failed responses as failed while retaining the filename and error message.
- Ensure the global upload button returns to an enabled state after success or failure.

Avoid using the filename as the result-map key because two files can have the same name. Match staged items using a stable local ID or an explicit request-to-item mapping.

Deliverable: the UI accurately shows per-file upload results and backend document IDs.

### Phase 6 — PDF-only picker path

Files to modify:

```text
mobile_app/lib/features/upload/view/screens/upload_screen.dart
mobile_app/lib/features/upload/services/file_picker_service.dart
```

Tasks:

- Keep the existing Documents option.
- Configure the PDF upload milestone to use `FileType.custom` with `allowedExtensions: ['pdf']`.
- Keep DOCX/TXT selection disabled for this endpoint unless separate backend support is added.
- Support multiple selection if the endpoint is called once per file or the backend is extended to accept a list.
- Display a clear message when the user selects an unsupported file.

For the first implementation, upload each selected PDF as a separate request. This makes error handling and document IDs unambiguous.

Deliverable: only PDFs enter the PDF upload pipeline.

### Phase 7 — Error handling and user experience

Implement these user-visible states:

```text
Selecting
Queued
Uploading
Uploaded
Failed
Retry available
```

Required behavior:

- Cancelled selection does nothing.
- Network failure shows a retryable error.
- File-too-large response explains the configured limit.
- Invalid PDF response explains that the file is not a valid PDF.
- A failed file does not remove successful files from the list.
- The user can remove a queued or failed item.
- The user can retry a failed item without selecting it again when its local file remains available.

Deliverable: upload failures are understandable and recoverable.

### Phase 8 — Testing

#### Backend tests

Add tests for:

- Valid PDF returns `201`.
- Missing file returns `400`.
- Empty file returns `400`.
- Non-PDF extension returns `415`.
- Incorrect MIME type is rejected or signature validation still rejects it.
- Invalid `%PDF-` signature returns `415`.
- Oversized file returns `413`.
- Stored filename is generated and does not contain the original path.
- Temporary files are cleaned after failure.
- Response contains the document ID and byte size.

#### Flutter unit tests

Add tests for:

- Multipart request contains a `file` part.
- Original filename is sent.
- `201` response maps to a completed upload with `documentId`.
- `400`, `413`, `415`, and `500` responses map to useful exceptions.
- Repository forwards `filePath`.
- Duplicate filenames do not overwrite each other in result mapping.

#### Flutter widget/BLoC tests

Add tests for:

- PDF selection stages the file.
- Confirm Upload calls the repository with the real path.
- Successful upload displays completed state.
- Failed upload displays failure state.
- Multiple files can have mixed success and failure.
- Cancelled picker does not call the repository.

Deliverable: automated tests cover the network boundary and the main UI states.

### Phase 9 — Manual integration verification

Run the following sequence:

1. Start FastAPI on the development machine.
2. Confirm `GET /` and Swagger UI are reachable from the selected device/emulator.
3. Upload a small text-based PDF from Flutter.
4. Confirm HTTP `201` in backend logs.
5. Confirm the PDF exists in the configured upload directory.
6. Confirm the returned document ID appears in Flutter state/logging.
7. Upload an invalid file renamed to `.pdf` and confirm rejection.
8. Upload a PDF larger than the limit and confirm `413`.
9. Turn off the backend and confirm the Flutter error state is recoverable.
10. Upload two PDFs with the same filename and confirm both receive different IDs.

Deliverable: an end-to-end upload demonstration suitable for project review.

## 3. Suggested implementation order

Implement in this order to keep each step testable:

1. Backend route with a valid PDF happy path.
2. Backend validation and safe storage.
3. Backend metadata persistence.
4. Flutter HTTP dependency and multipart client.
5. Repository and BLoC integration.
6. Model changes for backend document IDs.
7. Error states and retry handling.
8. Automated tests.
9. Device/emulator integration testing.

## 4. Definition of done

The implementation is complete when:

- A PDF selected in Flutter reaches FastAPI as file bytes.
- FastAPI validates and stores it safely.
- The backend returns a unique document ID.
- Flutter retains that ID and displays the completed state.
- Invalid, oversized, empty, and failed uploads are handled correctly.
- Multiple files do not interfere with one another.
- The upload API and client are covered by automated tests.
- No mock upload response remains in the production upload path.

## 5. RAG handoff

Once this plan is complete, implement the next pipeline using the stored document ID:

```text
uploaded PDF
  -> PyMuPDF text extraction
  -> page-aware chunking
  -> embeddings
  -> vector database
  -> similarity retrieval
  -> LLM answer with page citations
```

The upload endpoint should remain focused on receiving and storing files. Processing should be a separate operation so slow extraction and indexing do not cause the upload request to time out.
