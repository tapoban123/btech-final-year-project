from __future__ import annotations

from langchain_groq import ChatGroq


def get_llm(
    model: str = "openai/gpt-oss-120b",
    temperature: float = 0,
    **kwargs,
) -> ChatGroq:
    return ChatGroq(
        model=model,
        temperature=temperature,
        **kwargs,
    )


def get_main_llm(model: str = "openai/gpt-oss-120b") -> ChatGroq:
    return get_llm(model=model, temperature=0)


def get_fast_llm(model: str = "openai/gpt-oss-20b") -> ChatGroq:
    return get_llm(model=model, temperature=0)
