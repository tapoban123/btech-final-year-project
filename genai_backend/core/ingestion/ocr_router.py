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

    # Keep the original bytes available: preprocessing can fail on unusual
    # handwritten scans, but the vision model can still often read the source.
    try:
        processed = preprocess_image(page_info.image_bytes)
    except Exception as exc:
        logger.warning(
            "Page %d: image preprocessing failed (%s); forcing vision OCR",
            page_info.page_num, exc,
        )
        processed = page_info.image_bytes

    # Vision OCR is the primary path for image-only pages so handwriting is not
    # first reduced to potentially incorrect printed OCR.
    try:
        vision_text, vision_conf = await vision.ocr(processed)
    except Exception as exc:
        logger.warning("Page %d: primary vision OCR failed: %s", page_info.page_num, exc)
        vision_text, vision_conf = "", 0.0
    if vision_text.strip():
        return vision_text, True, vision_conf

    logger.warning(
        "Page %d: primary vision OCR returned no text; falling back to PaddleOCR",
        page_info.page_num,
    )
    try:
        text, confidence = await paddle.ocr(processed)
    except Exception as exc:
        logger.error("Page %d: fallback printed OCR failed: %s", page_info.page_num, exc)
        return "", True, 0.0

    if confidence < handwriting_conf_threshold:
        logger.info(
            "Page %d: fallback printed OCR confidence %.2f is unreliable",
            page_info.page_num,
            confidence,
        )
        # Vision was already attempted first; do not index unreliable Paddle text.
        logger.error(
            "Page %d: no reliable transcription available after vision and Paddle OCR",
            page_info.page_num,
        )
        return "", True, 0.0

    return text, True, confidence
