from __future__ import annotations

import yaml
from functools import lru_cache
from pathlib import Path
from pydantic import BaseModel
from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    model_config = SettingsConfigDict(
        env_file=".env",
        env_file_encoding="utf-8",
        extra="ignore",
    )

    groq_api_key: str = ""
    tavily_api_key: str = ""
    api_key: str = "dev-api-key-change-in-production"
    langsmith_api_key: str = ""
    langsmith_project: str = "omnidoc-ai"
    database_url: str = "sqlite+aiosqlite:///./omnidoc.db"
    upload_dir: Path = Path("./uploads")
    faiss_dir: Path = Path("./faiss_indexes")
    debug: bool = True


class RetrievalConfig(BaseModel):
    top_k: int = 10
    max_chunks_per_doc: int = 4
    chunk_size: int = 800
    chunk_overlap: int = 120
    embedding_model: str = "all-MiniLM-L6-v2"


class OcrConfig(BaseModel):
    text_layer_min_chars: int = 50
    dpi: int = 300
    printed_provider: str = "paddleocr"
    handwriting_provider: str = "vision_llm"
    handwriting_conf_threshold: float = 0.6
    low_conf_flag: float = 0.4
    max_parallel_pages: int = 8


class GradingConfig(BaseModel):
    batch_size: int = 10
    correct_min_score2: int = 1
    ambiguous_min_score1: int = 2


class LoopsConfig(BaseModel):
    max_rewrites: int = 1
    max_generations: int = 2
    graph_timeout_s: int = 60
    recursion_limit: int = 12


class WebSearchConfig(BaseModel):
    max_results: int = 4
    speculative: bool = False


class LlmConfig(BaseModel):
    main_model: str = "openai/gpt-oss-120b"
    fast_model: str = "openai/gpt-oss-20b"
    # Keep OCR on a multimodal model; the main answer model is text-only.
    vision_model: str = "qwen/qwen3.8-27b"
    temperature: float = 0
    max_retries: int = 1


class ChatConfig(BaseModel):
    summary_token_threshold: int = 2000
    max_recent_messages: int = 6


class ApiConfig(BaseModel):
    version: str = "v1"
    max_files_per_upload: int = 10
    max_file_mb: int = 20


class PipelineConfig(BaseModel):
    retrieval: RetrievalConfig = RetrievalConfig()
    ocr: OcrConfig = OcrConfig()
    grading: GradingConfig = GradingConfig()
    loops: LoopsConfig = LoopsConfig()
    web_search: WebSearchConfig = WebSearchConfig()
    llm: LlmConfig = LlmConfig()
    chat: ChatConfig = ChatConfig()
    api: ApiConfig = ApiConfig()


def load_yaml_config(path: str | Path = "config.yaml") -> dict:
    config_path = Path(path)
    if config_path.exists():
        with open(config_path) as f:
            return yaml.safe_load(f) or {}
    return {}


@lru_cache
def get_settings() -> Settings:
    return Settings()


@lru_cache
def get_pipeline_config() -> PipelineConfig:
    raw = load_yaml_config()
    return PipelineConfig(**raw)
