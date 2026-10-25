from __future__ import annotations

import base64
import logging
from typing import Optional

logger = logging.getLogger(__name__)


class PaddleOcrProvider:
    def __init__(self):
        self._engine: Optional[object] = None

    def _get_engine(self):
        if self._engine is None:
            from paddleocr import PaddleOCR
            self._engine = PaddleOCR(use_angle_cls=True, lang="en", show_log=False)
        return self._engine

    async def ocr(self, image_bytes: bytes) -> tuple[str, float]:
        import numpy as np
        import cv2

        arr = np.frombuffer(image_bytes, dtype=np.uint8)
        img = cv2.imdecode(arr, cv2.IMREAD_COLOR)
        if img is None:
            return "", 0.0

        engine = self._get_engine()
        result = engine.ocr(img, cls=True)

        if not result or not result[0]:
            return "", 0.0

        lines = []
        confidences = []
        for line in result[0]:
            text = line[1][0]
            conf = line[1][1]
            lines.append(text)
            confidences.append(conf)

        full_text = "\n".join(lines)
        avg_conf = sum(confidences) / len(confidences) if confidences else 0.0
        return full_text, avg_conf


class VisionLlmOcrProvider:
    def __init__(self, model: str = "qwen/qwen3.8-27b"):
        self._model = model

    async def ocr(self, image_bytes: bytes) -> tuple[str, float]:
        from core.llm import get_llm
        from langchain_core.messages import HumanMessage

        llm = get_llm(model=self._model, temperature=0)

        b64 = base64.b64encode(image_bytes).decode("utf-8")
        message = HumanMessage(
            content=[
                {
                    "type": "text",
                    "text": (
                        "You are the mandatory fallback OCR for a document page. "
                        "Transcribe all printed and handwritten text in this image "
                        "exactly as written. Pay special attention to handwriting, "
                        "faint strokes, and mixed handwritten/printed content. "
                        "Preserve line breaks and formatting. Do not summarize, "
                        "explain, or invent unreadable text. Output only the "
                        "transcribed text, nothing else."
                    ),
                },
                {
                    "type": "image_url",
                    "image_url": {"url": f"data:image/png;base64,{b64}"},
                },
            ]
        )

        try:
            response = await llm.ainvoke([message])
            content = response.content
            if isinstance(content, list):
                text = "\n".join(
                    item.get("text", "")
                    for item in content
                    if isinstance(item, dict) and item.get("type") == "text"
                ).strip()
            else:
                text = str(content).strip()
            return text, 0.7
        except Exception as e:
            logger.error("Vision LLM OCR failed: %s", e)
            return "", 0.0
