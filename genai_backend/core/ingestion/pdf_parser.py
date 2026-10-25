from __future__ import annotations

from dataclasses import dataclass, field
from pathlib import Path
from typing import Optional

import fitz


@dataclass
class PageInfo:
    page_num: int
    text: str
    has_text_layer: bool
    image_bytes: Optional[bytes] = field(default=None, repr=False)


def parse_pdf(file_path: str | Path, min_text_chars: int = 50) -> list[PageInfo]:
    doc = fitz.open(str(file_path))
    pages: list[PageInfo] = []

    for page_num in range(len(doc)):
        page = doc[page_num]
        text = page.get_text("text").strip()
        has_text = len(text) >= min_text_chars

        image_bytes = None
        if not has_text:
            pix = page.get_pixmap(dpi=300)
            image_bytes = pix.tobytes("png")

        pages.append(
            PageInfo(
                page_num=page_num + 1,
                text=text if has_text else "",
                has_text_layer=has_text,
                image_bytes=image_bytes,
            )
        )

    doc.close()
    return pages


def parse_image(file_path: str | Path) -> list[PageInfo]:
    path = Path(file_path)
    image_bytes = path.read_bytes()
    return [
        PageInfo(
            page_num=1,
            text="",
            has_text_layer=False,
            image_bytes=image_bytes,
        )
    ]
