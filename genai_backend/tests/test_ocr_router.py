import pytest

from core.ingestion.ocr_router import ocr_page
from core.ingestion.pdf_parser import PageInfo


class Paddle:
    def __init__(self, result=None, error=None):
        self.result = result
        self.error = error

    async def ocr(self, image):
        if self.error:
            raise self.error
        return self.result


class Vision:
    def __init__(self, result=None, error=None):
        self.result = result
        self.error = error
        self.calls = 0

    async def ocr(self, image):
        self.calls += 1
        if self.error:
            raise self.error
        return self.result


def page():
    return PageInfo(page_num=3, text="", has_text_layer=False, image_bytes=b"image")


@pytest.mark.asyncio
async def test_vision_is_the_primary_ocr_path():
    vision = Vision(("handwritten text", 0.7))
    paddle = Paddle(("unused", 0.9))
    text, was_ocr, confidence = await ocr_page(page(), paddle, vision)
    assert (text, was_ocr, confidence) == ("handwritten text", True, 0.7)
    assert vision.calls == 1


@pytest.mark.asyncio
async def test_paddle_is_fallback_when_vision_returns_no_text():
    vision = Vision(("", 0.0))
    result = await ocr_page(page(), Paddle(("printed text", 0.9)), vision)
    assert result == ("printed text", True, 0.9)
    assert vision.calls == 1


@pytest.mark.asyncio
async def test_failed_primary_vision_does_not_index_bad_low_confidence_text():
    vision = Vision(error=RuntimeError("llm unavailable"))
    result = await ocr_page(page(), Paddle(("unreliable", 0.1)), vision)
    assert result == ("", True, 0.0)
