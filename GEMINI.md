# GEMINI.md — Engineering Standards & Architectural Guidelines

This document outlines the architectural principles, coding conventions, and operational guidelines for AI agents and developers contributing to this codebase. All modifications must adhere to these standards.

---

## 1. Project Overview & Architecture

**OmniDoc AI** is a multimodal document intelligence and Retrieval-Augmented Generation (RAG) system. It enables users to upload, parse, index, search, and chat with multi-format documents (PDFs, text files, images with tables/charts) through a cross-platform mobile client backed by a unified Python FastAPI backend.

### Tech Stack Breakdown
- **Client:** Flutter (Android & iOS), Cubit/BLoC state management, local caching, Feature-First architecture.
- **Backend:** **Python with FastAPI** (unified service handling API routing, session management, file MIME validation, streaming ingestion, OCR/vision parsing, semantic chunking, vector embedding generation, and LLM orchestration).
- **Databases:**
  - **Relational/NoSQL:** SQLite / PostgreSQL for user metadata, document status, and chat history.
  - **Vector Database:** Chroma / Qdrant / FAISS for high-dimensional embeddings with Approximate Nearest Neighbor (ANN / HNSW) indexing.
- **Containerization & Runtime:** Docker / Uvicorn for reproducible, lightweight deployment.

---

## 2. Core Architectural Principles: Pragmatic Feature-Modular Pattern

For rapid prototyping, **we do NOT use Clean Architecture (Hexagonal/Onion)**. Clean Architecture introduces heavy ceremony (abstract repository interfaces, use cases, domain entities, and multiple DTO mapping layers) that slows down rapid iteration.

Instead, we use a **Pragmatic Feature-Modular Architecture (Router $\rightarrow$ Service $\rightarrow$ Schema / Model)** that delivers:
- **Low-to-Zero Boilerplate:** Direct function calls and Pydantic validation without intermediate boilerplate layers.
- **Effortless Maintenance:** Code is organized by domain feature; you can locate, edit, or test any feature immediately.
- **Easy Scalability:** Features are decoupled by router and service. If a service expands later, it can be extracted into an independent microservice with minimal friction.

### 2.1. Backend Layout (FastAPI)

```text
backend/
├── app/
│   ├── main.py              # FastAPI app instance, CORS, middleware, router registration
│   ├── config.py            # App settings using pydantic-settings (.env)
│   ├── routers/             # HTTP endpoints grouped by feature (thin controllers)
│   │   ├── auth.py
│   │   ├── documents.py
│   │   └── chat.py
│   ├── services/            # Direct business logic & AI pipelines (no abstract interfaces)
│   │   ├── document_parser.py
│   │   ├── ocr_service.py
│   │   ├── vector_store.py
│   │   └── rag_service.py
│   ├── schemas/             # Pydantic v2 models for request & response validation
│   │   ├── document.py
│   │   └── chat.py
│   └── models/              # Lightweight database models (SQLAlchemy/SQLModel)
└── requirements.txt         # Python dependencies
```

### 2.2. How the Backend Layers Work
1. **Routers (`routers/`):** Thin controllers. Accept Pydantic request models, call the appropriate service function, and return response models or raise standard `HTTPException`.
2. **Services (`services/`):** Straightforward Python functions or classes. Implement business logic, OCR, chunking, and LLM orchestration directly without abstract repository wrappers.
3. **Schemas (`schemas/`):** Pydantic v2 models that handle data validation, JSON serialization, and automatic Swagger docs (`/docs`).
4. **Models (`models/`):** Minimal database tables/models for persisting users, document records, and chat messages.

---

## 3. Technology-Specific Guidelines

### 3.1. Flutter / Dart (Mobile Client)
- **Architecture:** Organize code **by feature** (`features/auth`, `features/documents`, `features/chat`) rather than multi-layered clean architecture folders.
- **State Management:** Use **Cubit** (`flutter_bloc`) for straightforward state emissions without boilerplate event classes.
- **API Communication:** Use direct HTTP clients (`dio` or `http`) inside feature services/cubits.
- **UI Guidelines:**
  - Prefer `const` constructors wherever possible to optimize rebuild cycles.
  - Maintain responsive, adaptive layouts suitable for various mobile screen sizes.
  - Gracefully handle offline states, network reconnections, and background uploads.

### 3.2. Python & FastAPI (Backend Service)
- **Type Safety & Schemas:**
  - Use Python 3.11+ type annotations (`typing`, `Pydantic v2`).
  - All input/output request payloads must be defined via Pydantic models with clear field descriptions.
- **Asynchronous I/O:**
  - Use `async def` for endpoints performing I/O (database queries, vector search, external LLM calls).
  - Use FastAPI's `BackgroundTasks` for long-running document ingestion and OCR so client upload requests return immediately.
- **Document Processing & Chunking:**
  - Preserve document hierarchy (headings, sections, tables) during extraction. Do not blindly slice text by raw character counts.
  - For visual/scanned elements, integrate OCR and layout models to keep tabular data and captions bound to their respective context.
- **RAG & Search Pipeline:**
  - Ensure embeddings are normalized and aligned with the vector index dimensions.
  - Retrieve top-k chunks with relevance thresholds to prevent context dilution.
  - Structure LLM system prompts to demand grounded responses with direct citations (page/section) and minimize hallucinations.
- **Error Handling:**
  - Raise standard `HTTPException(status_code=..., detail=...)` with structured JSON error details.
  - Never let unhandled exceptions leak raw stack traces to the client.

---

## 4. Security & Data Protection

1. **Zero Secret Leaks:**
   - Never commit API keys, database credentials, or auth tokens. Use `.env` files and environment variables.
   - Keep `.env*` (except `.env.example`) strictly in `.gitignore`.
2. **Input Sanitization:**
   - Sanitize all file uploads and query strings. Validate file extensions, magic bytes, and size limits before processing.
3. **Data Isolation:**
   - Ensure tenant/user data isolation at both the database and vector index level (metadata filtering on `user_id` / `workspace_id`).
4. **PII Handling:**
   - Redact or mask sensitive personal information before sending payloads to external LLM providers when possible.

---

## 5. Error Handling & Resilience

- **Fail Gracefully:** External AI APIs may rate-limit or fail. Implement exponential backoff, circuit breakers, and user-facing fallback messages.
- **Predictable APIs:** Return consistent, structured JSON error responses with clear codes and actionable messages.
- **Asynchronous Processing:** Long-running OCR and embedding tasks must run as background jobs with polling or status updates to keep client latency low.

---

## 6. Strict Test-Driven Development (TDD) & Quality Assurance

All contributions must follow strict **Test-Driven Development (TDD)** principles (**Red $\rightarrow$ Green $\rightarrow$ Refactor**). Every feature must be validated by automated test suites before being merged or considered complete.

### 6.1. TDD Workflow Guidelines
1. **Write Tests First / Concurrently:** Define the expected behavior, domain contracts, and failure modes in tests prior to finalizing business logic.
2. **Deterministic & Isolated:** Tests must never depend on live external network calls, remote databases, or uncontrolled random delays. Always use mocks (`mocktail` / `pytest-mock`).
3. **No Flaky Tests:** Keep widget test trees constrained, pump fake async timers cleanly, and avoid unbounded loops.

### 6.2. Test Hierarchy per Feature (Flutter Client)
Each feature directory under `features/<feature>/` must be accompanied by matching test coverage under `test/features/<feature>/`:

1. **Unit Tests (`unit/`):**
   - Test domain models (`DocumentItem`, `ChatMessage`, `SynthesisPoint`, etc.), `copyWith`, and value equality (`Equatable`).
   - Test repository data transformations and parsing logic in isolation.
2. **API & Mock Response Tests (`api/`):**
   - Test API client behaviors against mocked JSON responses using `mocktail`.
   - Validate HTTP 200 success paths, empty payload scenarios, HTTP 400/500 exceptions, and network timeouts.
3. **BLoC / State Management Tests (`blocs/`):**
   - Use `bloc_test` to verify event-to-state stream transitions.
   - Test initial states, asynchronous loading sequences, state updates on user interactions, and error state transitions.
4. **Widget & Screen Interaction Tests (`view/`):**
   - Test component rendering, semantic texts, icons, and theme bindings.
   - Simulate user gestures (tapping chips, toggling selections, entering text in search/chat input, tapping action buttons, sheet modals).
5. **Edge Case Tests (`edge_cases/`):**
   - Test empty list states (*"No documents found"*).
   - Test extreme search queries (special characters, whitespace, case-insensitivity, no-match queries).
   - Test multi-selection toggles (selecting, unselecting, batch actions on 0 vs N items).
   - Test rapid message dispatching and feedback toggles in chat.

### 6.3. Backend Testing (FastAPI)
- **Unit Testing:** Validate semantic chunking, prompt templating, and vector math with mock dependencies using `pytest`.
- **Integration Testing:** Test FastAPI HTTP routes and background tasks using `httpx.AsyncClient` or FastAPI's `TestClient`.
- **RAG Quality Evaluation:** Track RAG performance against standard benchmarks (Faithfulness, Answer Relevance, Context Recall) before modifying retrieval strategies.

---

## 7. Working Rules for AI Agents

1. **Keep It Simple & Actionable:** Avoid premature abstractions, complex design patterns, or unnecessary boilerplate.
2. **Preserve Existing Code & Comments:** Never delete unrelated code, comments, or docstrings unless explicitly asked.
3. **Atomic & Focused Diffs:** Make targeted changes that solve the user's specific request. Avoid unsolicited mass refactoring.
4. **Self-Documenting Endpoints:** Always attach response schemas and docstrings to FastAPI endpoints so Swagger UI (`/docs`) remains up to date.
5. **Verify Before Suggesting:** Double-check library versions, file paths, and type signatures before generating code.
6. **Link Files in Explanations:** When discussing code or referencing files, provide clickable markdown links using the `file://` scheme.
