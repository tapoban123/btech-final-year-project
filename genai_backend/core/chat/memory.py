from __future__ import annotations

from langchain_core.messages import HumanMessage, SystemMessage

from core.graph.prompts import SUMMARIZE_PROMPT


def estimate_tokens(text: str) -> int:
    return int(len(text.split()) * 1.3)


def should_summarize(messages: list[dict], threshold: int = 2000) -> bool:
    total = sum(estimate_tokens(m.get("content", "")) for m in messages)
    return total > threshold


async def summarize_history(
    messages: list[dict],
    llm,
    existing_summary: str = "",
) -> str:
    conversation = ""
    if existing_summary:
        conversation += f"Previous summary: {existing_summary}\n\n"

    for msg in messages:
        role = msg.get("role", "user")
        content = msg.get("content", "")
        conversation += f"{role}: {content}\n"

    prompt = SUMMARIZE_PROMPT.format(conversation=conversation)

    response = await llm.ainvoke([HumanMessage(content=prompt)])
    return response.content.strip()


def build_chat_context(
    summary: str,
    recent_messages: list[dict],
    max_recent: int = 6,
) -> tuple[str, list[dict]]:
    trimmed = recent_messages[-max_recent:] if len(recent_messages) > max_recent else recent_messages
    return summary, trimmed
