# HTTPX ReadTimeout Fix - PostgreSQL Migration

## Problem Summary

After migrating from SQLite to PostgreSQL, the Streamlit UI experienced `httpx.ReadTimeout` errors when calling `/v1/jobs/{job_id}` endpoint after ~30 seconds during document ingestion.

- **Error Location**: `streamlit_ui.py` line 130: `job = api_get(f"/v1/jobs/{job_id}")`
- **Symptom**: Endpoint hung for 30+ seconds, then timed out
- **Health Check**: `/v1/health` responded successfully (no server crash)
- **Context**: Occurred after document ingestion was triggered, never during idle

## Root Cause

The background ingestion task held a database session **open for the entire duration** of document processing (minutes), blocking connection pool resources.

### What Was Happening

**`app/routers/documents.py` - Original `_run_ingestion`:**
```python
async def _run_ingestion(...):
    factory = get_async_session_factory()
    async with factory() as session:  # ← Session opened here
        # Fetch job
        await update_job(job.id, session, status="processing", progress=0.1)
        
        # This takes MINUTES but session is still open
        page_count = await ingest_document(...)  
        
        # Only released here
        await session.commit()
```

**PostgreSQL Connection Pool (default asyncpg):**
- Pool size: 10 connections
- Max overflow: 10 additional connections
- Total available: 20 connections max

**The Bottleneck:**
1. Background task opens a session → claims 1 connection
2. While `ingest_document()` runs (OCR, LLM, embeddings):
   - Performing I/O (not using the connection)
   - But connection still reserved in pool
   - Pool has only 9 connections left
3. Multiple document uploads → multiple sessions open → pool exhausted
4. Incoming `/v1/jobs/{job_id}` request → no connection available → waits → timeout

**Why SQLite Didn't Have This Issue:**
- SQLite is file-based, no connection pooling
- Sessions didn't consume a limited resource
- Background tasks didn't block other requests

## Solution

### 1. Refactored Background Task to Release Session During Long Operations

**File: `app/routers/documents.py`**

Changed from:
```python
async with factory() as session:
    # Fetch job
    # Run long ingestion (session held)
    # Update job (session held)
    # Commit (session released)
```

To:
```python
# Fetch job briefly
async with factory() as session:
    job = ...
    job_id = job.id
# Session released immediately

# Run long ingestion (no session)
await ingest_document(...)

# Acquire fresh session only when updating
async def on_progress(progress, status):
    async with factory() as session:  # ← New session for each update
        await update_job(job_id, session, status, progress)

# Final update
async with factory() as session:
    await update_job(job_id, session, ...)
```

**Key Changes:**
- Session opened and closed in distinct blocks
- Long-running `ingest_document()` doesn't hold a session
- Progress callbacks acquire fresh sessions on-demand
- Each session is short-lived (sub-second operations)

### 2. Optimized Connection Pool Configuration

**File: `app/models/tables.py`**

Added explicit pool settings:
```python
create_async_engine(
    settings.database_url,
    echo=settings.debug,
    pool_size=5,           # Reduced from default 10 to match typical load
    max_overflow=10,       # Allow burst to 15 total connections
    pool_pre_ping=True,    # Detect stale connections
    connect_args={"timeout": 10}  # Connection timeout
)
```

**Rationale:**
- `pool_size=5`: Sufficient for typical concurrent requests (health check, job polling, uploads)
- `max_overflow=10`: Accommodates temporary bursts
- `pool_pre_ping=True`: Validates connections before use (prevents stale connection errors)
- `connect_args={"timeout": 10}`: Fail fast if database is unavailable

### 3. Added Comprehensive Logging

**Files: `app/routers/documents.py`, `app/services/job_service.py`**

Added DEBUG and INFO level logging to track:
- Ingestion start/end with elapsed time
- Progress update timestamps
- Job fetch/update operations
- Exception details with elapsed time

Example log output:
```
INFO:app.routers.documents:Starting ingestion for document abc123 (report.pdf)
DEBUG:app.routers.documents:Job xyz789 marked as processing
DEBUG:app.routers.documents:Starting pipeline for report.pdf
DEBUG:app.services.job_service:Fetching job xyz789
DEBUG:app.routers.documents:Job xyz789 progress: 20.0% (processing)
INFO:app.routers.documents:Pipeline completed for report.pdf: 15 pages
INFO:app.routers.documents:Ingestion done for abc123 (45.3s)
```

## Changed Files

1. **`app/routers/documents.py`**
   - Refactored `_run_ingestion()` to release sessions during long operations
   - Added logging and timing
   - Session lifecycle: open → close → reopen as needed

2. **`app/models/tables.py`**
   - Added explicit pool configuration to `get_async_engine()`
   - Imported `NullPool` (for future connection pooling strategies)
   - Added pool monitoring parameters

3. **`app/services/job_service.py`**
   - Added logging to `get_job()` and `update_job()` 
   - Logs include job ID, status, progress, and operation results

4. **`tests/test_job_endpoint_timeout.py`** (new)
   - Test to verify endpoint responsiveness during ingestion
   - Simulates concurrent job polling
   - Validates no timeouts occur

## How to Verify the Fix

### 1. Check Logs During Document Upload

Run the backend with `DEBUG=true` in `.env`:
```
DEBUG=true
```

Upload a document and monitor logs:
```
INFO:app.routers.documents:Starting ingestion for document abc... (file.pdf)
DEBUG:app.routers.documents:Job xyz... marked as processing
DEBUG:app.routers.documents:Starting pipeline for file.pdf
DEBUG:app.services.job_service:Job xyz... progress: 20.0% (processing)
DEBUG:app.services.job_service:Job xyz... progress: 40.0% (processing)
INFO:app.routers.documents:Pipeline completed for file.pdf: N pages
INFO:app.routers.documents:Ingestion done for abc... (XX.Xs)
```

**Expected:** Each progress update opens and closes its own session (not held).

### 2. Test Job Status Polling

While a document is being ingested, poll the job endpoint:
```powershell
$jobId = "job-id-from-upload"
for ($i = 0; $i -lt 10; $i++) {
    $start = Get-Date
    $response = Invoke-RestMethod -Uri "http://127.0.0.1:8000/v1/jobs/$jobId" -TimeoutSec 5
    $elapsed = ((Get-Date) - $start).TotalMilliseconds
    Write-Host "Poll $($i+1): status=$($response.status) progress=$($response.progress) (${elapsed}ms)"
    Start-Sleep -Seconds 1
}
```

**Expected:** 
- All requests complete within 100-500ms
- No timeouts (ReadTimeout errors)
- Status and progress update smoothly

### 3. Verify Connection Pool State

Check PostgreSQL connection count:
```sql
SELECT count(*) FROM pg_stat_activity WHERE datname = 'omnidoc';
```

**Expected:**
- Idle: 1-2 connections (the app)
- During ingestion: 2-4 connections (app + temporary requests)
- Never reaches pool_size limit (5 + 10 overflow = 15)

### 4. Run Unit Tests

```powershell
cd E:\vs_code\Final_Year_Project_Sapta\OmniDoc\genai_backend
python -m pytest tests/test_job_endpoint_timeout.py -v
```

## Performance Impact

- **Request Latency**: No change (sessions still async)
- **Memory**: Slightly lower (fewer open sessions at once)
- **Connection Pool**: More efficient (connections released sooner)
- **Database Load**: No change (same operations, better timing)

## Backward Compatibility

✅ **Full Compatibility Maintained**
- API contract unchanged (`/v1/jobs/{job_id}` response format identical)
- UI doesn't need changes
- Ingestion pipeline logic unchanged
- Database schema unchanged
- Can be deployed as drop-in replacement

## Testing Checklist

- [ ] Backend starts without errors
- [ ] Collection creation works
- [ ] Document upload returns 202 (job queued)
- [ ] Job polling returns 200 and current status
- [ ] Job status updates during ingestion
- [ ] No timeout errors after 30 seconds
- [ ] Multiple concurrent uploads don't exhaust pool
- [ ] Ingestion completes successfully
- [ ] Logs show proper session lifecycle
- [ ] Document marked as "ready" after ingestion

## Future Improvements

1. **Connection Pool Monitoring**: Add metrics endpoint to expose pool utilization
2. **Async Job Status**: Consider WebSocket for real-time updates instead of polling
3. **Ingestion Queue**: Move to a proper task queue (Celery, RQ) for production
4. **Circuit Breaker**: Add circuit breaker pattern for database connection failures
