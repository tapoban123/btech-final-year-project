from __future__ import annotations

import logging
from typing import Literal

from core.ingestion.pdf_parser import PageInfo
from core.ingestion.image_preprocess import preprocess_image
from core.ingestion.ocr_providers import PaddleOcrProvider, VisionLlmOcrProvider

logger = logging.getLogger(__name__)


def classify_page(page_info: PageInfo) -> Literal["skip", "printed", "handwritten"]:
    if page_info.has_text_layer and page_info.text:
        return "skip"
    return "printed"


async def ocr_page(
    page_info: PageInfo,
    paddle: PaddleOcrProvider,
    vision: VisionLlmOcrProvider,
    handwriting_conf_threshold: float = 0.6,
) -> tuple[str, bool, float]:
    classification = classify_page(page_info)

    if classification == "skip":
        return page_info.text, False, 1.0

    if page_info.image_bytes is None:
        return "", False, 0.0

    processed = preprocess_image(page_info.image_bytes)

    text, confidence = await paddle.ocr(processed)

    if confidence < handwriting_conf_threshold and text.strip():
        logger.info(
            "Page %d: low printed OCR confidence (%.2f), trying vision LLM",
            page_info.page_num,
            confidence,
        )
        vision_text, vision_conf = await vision.ocr(processed)
        if vision_text:
            return vision_text, True, vision_conf

    if not text.strip():
        vision_text, vision_conf = await vision.ocr(processed)
        return vision_text, True, vision_conf

    return text, True, confidence
