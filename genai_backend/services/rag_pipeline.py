"""LangGraph PDF retrieval-augmented generation pipeline."""

from __future__ import annotations

import os
import json
import logging
import re
import time
from pathlib import Path
from typing import Any, TypedDict

import fitz
from langgraph.graph import END, StateGraph
from pinecone import Pinecone, ServerlessSpec
from google import genai
from google.genai import types
from openai import OpenAI


logger = logging.getLogger(__name__)


class RAGState(TypedDict, total=False):
    collection_id: str
    document_id: str
    document_name: str
    pdf_path: str
    query: str
    pages: list[dict[str, Any]]
    chunks: list[dict[str, Any]]
    query_embedding: list[float]
    retrieved: list[dict[str, Any]]
    answer: str
    citations: list[dict[str, Any]]


class IngestionState(TypedDict, total=False):
    collection_id: str
    document_id: str
    document_name: str
    file_path: str
    content_type: str
    pages: list[dict[str, Any]]
    chunks: list[dict[str, Any]]


class PDFRAGPipeline:
    """Builds and runs a document-scoped graph for PDF question answering."""

    def __init__(self) -> None:
        self.embedding_model = os.getenv("PINECONE_EMBEDDING_MODEL", "multilingual-e5-large")
        self.grok_model = os.getenv("GROQ_MODEL", "openai/gpt-oss-20b")
        self.index_name = os.getenv("PINECONE_INDEX_NAME", "pdf-rag")
        self.pinecone_region = os.getenv("PINECONE_REGION", "us-east-1")
        self.pinecone_cloud = os.getenv("PINECONE_CLOUD", "aws")
        self._ingestion_graph = self._build_ingestion_graph()
        self._graph = self._build_graph()

    def _build_ingestion_graph(self):
        graph = StateGraph(IngestionState)
        graph.add_node("route_input", self.route_input)
        graph.add_node("extract_pdf", self.extract_pdf)
        graph.add_node("extract_image", self.extract_image)
        graph.add_node("chunking", self.ingestion_chunking)
        graph.add_node("embedding", self.ingestion_embedding)
        graph.set_entry_point("route_input")
        graph.add_conditional_edges(
            "route_input",
            lambda state: "extract_pdf" if state["content_type"] == "application/pdf" else "extract_image",
            {"extract_pdf": "extract_pdf", "extract_image": "extract_image"},
        )
        graph.add_edge("extract_pdf", "chunking")
        graph.add_edge("extract_image", "chunking")
        graph.add_edge("chunking", "embedding")
        graph.add_edge("embedding", END)
        return graph.compile()

    def _build_graph(self):
        graph = StateGraph(RAGState)
        graph.add_node("query_embedding", self.quering)
        graph.add_node("retrieval", self.retrival)
        graph.add_node("llm_call", self.lmm_call)
        graph.set_entry_point("query_embedding")
        graph.add_edge("query_embedding", "retrieval")
        graph.add_edge("retrieval", "llm_call")
        graph.add_edge("llm_call", END)
        return graph.compile()

    def _pinecone(self) -> Pinecone:
        api_key = os.getenv("PINECONE_API_KEY")
        if not api_key:
            raise RuntimeError("PINECONE_API_KEY is not configured")
        return Pinecone(api_key=api_key)

    def _grok(self) -> OpenAI:
        api_key = os.getenv("GROQ_API_KEY")
        if not api_key:
            raise RuntimeError("GROQ_API_KEY is not configured")
        return OpenAI(
            api_key=api_key,
            base_url=os.getenv("GROQ_BASE_URL", "https://api.groq.com/openai/v1"),
        )

    def _gemini(self) -> genai.Client:
        api_key = os.getenv("GEMINI_API_KEY")
        if not api_key:
            raise RuntimeError("GEMINI_API_KEY is not configured")
        return genai.Client(api_key=api_key)

    def _gemini_model(self) -> str:
        model = os.getenv("GEMINI_MODEL", "").strip()
        if not model:
            raise RuntimeError("GEMINI_MODEL is not configured")
        return model

    def _index(self, pinecone: Pinecone):
        if not pinecone.has_index(self.index_name):
            pinecone.create_index(
                name=self.index_name,
                dimension=1024,
                metric="cosine",
                spec=ServerlessSpec(cloud=self.pinecone_cloud, region=self.pinecone_region),
            )
            for _ in range(60):
                if pinecone.describe_index(self.index_name).status["ready"]:
                    break
                time.sleep(1)
            else:
                raise RuntimeError("Pinecone index did not become ready")
        return pinecone.Index(self.index_name)

    def pdfloader(self, state: RAGState) -> dict[str, Any]:
        pages: list[dict[str, Any]] = []
        with fitz.open(state["pdf_path"]) as document:
            for page_number, page in enumerate(document, start=1):
                text = page.get_text("text").strip()
                if text:
                    pages.append({"page": page_number, "text": text})
        if not pages:
            raise ValueError("The PDF does not contain extractable text")
        return {"pages": pages}

    def route_input(self, state: IngestionState) -> dict[str, Any]:
        if state["content_type"] != "application/pdf" and not state["content_type"].startswith("image/"):
            raise ValueError("Unsupported document type")
        return {}

    def extract_pdf(self, state: IngestionState) -> dict[str, Any]:
        pages: list[dict[str, Any]] = []
        with fitz.open(state["file_path"]) as document:
            for page_number, page in enumerate(document, start=1):
                text = page.get_text("text").strip()
                if text:
                    pages.append({"page": page_number, "text": text})
        if not pages:
            raise ValueError("The PDF does not contain extractable text")
        return {"pages": pages}

    def extract_image(self, state: IngestionState) -> dict[str, Any]:
        image_bytes = Path(state["file_path"]).read_bytes()
        prompt = (
            "Analyze this image for retrieval-augmented generation. Produce detailed factual text "
            "covering all visible text (preserve exact wording where readable), entities, labels, "
            "numbers, relationships, layout, tables/charts, symbols, and domain-relevant visual facts. "
            "Separate observations from uncertain interpretations. Do not invent information. "
            "Write plain text that can be chunked and searched later."
        )
        # Keep the client alive until the request has completed.  Creating it
        # inline allows its destructor to close the HTTP client mid-request.
        gemini = self._gemini()
        response = gemini.models.generate_content(
            model=self._gemini_model(),
            contents=[prompt, types.Part.from_bytes(data=image_bytes, mime_type=state["content_type"])],
            config=types.GenerateContentConfig(temperature=0),
        )
        text = (response.text or "").strip()
        if not text:
            raise ValueError("The image model returned no extractable context")
        return {"pages": [{"page": 1, "text": text}]}

    def ingestion_chunking(self, state: IngestionState) -> dict[str, Any]:
        return self.chunking({"pages": state["pages"]})

    def ingestion_embedding(self, state: IngestionState) -> dict[str, Any]:
        return self.vector_databasing({
            "collection_id": state["collection_id"],
            "document_id": state["document_id"],
            "document_name": state["document_name"],
            "chunks": state["chunks"],
        })

    def prepare_document(self, *, collection_id: str, document_id: str, document_name: str,
                         file_path: Path, content_type: str = "application/pdf") -> None:
        """Extract, chunk, embed, and index a PDF or image during document loading."""
        self._ingestion_graph.invoke({
            "collection_id": collection_id,
            "document_id": document_id,
            "document_name": document_name,
            "file_path": str(file_path),
            "content_type": content_type,
        })

    def chunking(self, state: RAGState) -> dict[str, Any]:
        chunks: list[dict[str, Any]] = []
        chunk_size, overlap = 1200, 200
        for page in state["pages"]:
            text = page["text"]
            start = 0
            while start < len(text):
                end = min(start + chunk_size, len(text))
                chunk = text[start:end].strip()
                if chunk:
                    chunks.append({"text": chunk, "page": page["page"]})
                if end == len(text):
                    break
                start = end - overlap
        return {"chunks": chunks}

    def vector_databasing(self, state: RAGState) -> dict[str, Any]:
        pinecone = self._pinecone()
        index = self._index(pinecone)
        namespace = state["collection_id"]
        embeddings = pinecone.inference.embed(
            model=self.embedding_model,
            inputs=[chunk["text"] for chunk in state["chunks"]],
            parameters={"input_type": "passage", "truncate": "END"},
        )
        index.upsert(
            namespace=namespace,
            vectors=[
                {
                    "id": f"{state['document_id']}_{index_number}",
                    "values": embedding.values,
                    "metadata": {
                        "page": chunk["page"],
                        "text": chunk["text"],
                        "document_id": state["document_id"],
                        "document_name": state["document_name"],
                    },
                }
                for index_number, (embedding, chunk) in enumerate(zip(embeddings.data, state["chunks"]))
            ],
        )
        return {}

    def quering(self, state: RAGState) -> dict[str, Any]:
        embeddings = self._pinecone().inference.embed(
            model=self.embedding_model,
            inputs=[state["query"]],
            parameters={"input_type": "query", "truncate": "END"},
        )
        return {"query_embedding": embeddings.data[0].values}

    def retrival(self, state: RAGState) -> dict[str, Any]:
        index = self._index(self._pinecone())
        result = index.query(
            namespace=state["collection_id"],
            vector=state["query_embedding"],
            top_k=5,
            include_metadata=True,
        )
        retrieved = [
            {
                "text": match.metadata.get("text", ""),
                "page": int(match.metadata.get("page", 0)),
                "document_id": match.metadata.get("document_id", ""),
                "document_name": match.metadata.get("document_name", ""),
                "distance": match.score,
            }
            for match in result.matches
        ]
        return {"retrieved": retrieved}

    def lmm_call(self, state: RAGState) -> dict[str, Any]:
        context = "\n\n".join(
            f"[{item['document_name']}, page {item['page']}]\n{item['text']}" for item in state["retrieved"]
        )
        system_instruction = (
            "Answer only from the supplied PDF context. Combine relevant facts from "
            "multiple documents without repeating them. Do not invent facts. If the "
            "context does not contain the answer, say so clearly. Cite sources as "
            "[Document Name, p. N]."
        )
        user_prompt = f"PDF context:\n{context}\n\nQuestion: {state['query']}"

        try:
            gemini = self._gemini()
            response = gemini.models.generate_content(
                model=self._gemini_model(),
                contents=user_prompt,
                config=types.GenerateContentConfig(
                    system_instruction=system_instruction,
                    temperature=0,
                ),
            )
            answer = response.text or ""
        except Exception as gemini_error:
            logger.warning(
                "Gemini LLM call failed; falling back to Grok: %s",
                gemini_error,
            )
            try:
                response = self._grok().chat.completions.create(
                    model=self.grok_model,
                    temperature=0,
                    messages=[
                        {"role": "system", "content": system_instruction},
                        {"role": "user", "content": user_prompt},
                    ],
                )
                answer = response.choices[0].message.content or ""
            except Exception as grok_error:
                raise RuntimeError("Both Gemini and Grok LLM calls failed") from grok_error
        citations = []
        seen_sources = set()
        for item in state["retrieved"]:
            source_key = (item["document_id"], item["page"])
            if source_key not in seen_sources:
                seen_sources.add(source_key)
                citations.append({
                    "document_id": item["document_id"],
                    "document_name": item["document_name"],
                    "page": item["page"],
                    "snippet": item["text"][:240],
                })
        return {
            "answer": answer,
            "citations": citations,
        }
    def ask(self, *, collection_id: str, query: str) -> dict[str, Any]:
        result = self._graph.invoke(
            {
                "collection_id": collection_id,
                "query": query.strip(),
            }
        )
        return {"answer": result["answer"], "sources": result["citations"]}

    def delete_document(self, *, collection_id: str, document_id: str) -> None:
        index = self._index(self._pinecone())
        index.delete(namespace=collection_id, filter={"document_id": document_id})

    def delete_collection(self, collection_id: str) -> None:
        index = self._index(self._pinecone())
        index.delete(namespace=collection_id, delete_all=True)


rag_pipeline = PDFRAGPipeline()
