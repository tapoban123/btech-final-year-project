from dotenv import load_dotenv

load_dotenv()

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from api.documents import router as documents_router

app = FastAPI(
    title="OmniDoc AI Backend",
    version="1.0.0",
    docs_url="/docs",
    openapi_url="/openapi.json",
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(documents_router, prefix="/api/v1")


@app.get("/")
async def root():
    return {"message": "OmniDoc AI API is running"}


@app.get("/health", tags=["system"])
@app.get("/api/v1/health", tags=["system"])
async def health_check():
    return {"status": "ok", "service": "omnidoc-ai-backend"}
