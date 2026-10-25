from __future__ import annotations

import uuid
import logging

from langgraph.store.memory import InMemoryStore
from langgraph.checkpoint.memory import MemorySaver

from core.chat.memory import should_summarize, summarize_history, build_chat_context

logger = logging.getLogger(__name__)


class ChatManager:
    def __init__(self):
        self.store = InMemoryStore()
        self.checkpointer = MemorySaver()

    def get_or_create_thread(self, chat_id: str | None = None) -> dict:
        if chat_id is None:
            chat_id = uuid.uuid4().hex[:16]

        namespace = ("chats",)
        try:
            existing = self.store.get(namespace, chat_id)
            if existing and existing.value:
                return existing.value
        except Exception:
            pass

        meta = {
            "chat_id": chat_id,
            "summary": "",
            "messages": [],
            "collection_id": None,
        }
        self.store.put(namespace, chat_id, meta)
        return meta

    def get_chat_context(
        self,
        chat_id: str,
        max_recent: int = 6,
    ) -> tuple[str, list[dict]]:
        namespace = ("chats",)
        try:
            item = self.store.get(namespace, chat_id)
            if item and item.value:
                meta = item.value
                return build_chat_context(
                    meta.get("summary", ""),
                    meta.get("messages", []),
                    max_recent,
                )
        except Exception:
            pass
        return "", []

    async def append_turn(
        self,
        chat_id: str,
        user_msg: str,
        assistant_msg: str,
        llm=None,
        summary_threshold: int = 2000,
    ):
        namespace = ("chats",)
        try:
            item = self.store.get(namespace, chat_id)
            meta = item.value if item else None
        except Exception:
            meta = None

        if meta is None:
            meta = {
                "chat_id": chat_id,
                "summary": "",
                "messages": [],
                "collection_id": None,
            }

        meta["messages"].append({"role": "user", "content": user_msg})
        meta["messages"].append({"role": "assistant", "content": assistant_msg})

        if llm and should_summarize(meta["messages"], summary_threshold):
            old_messages = meta["messages"][:-6]
            if old_messages:
                try:
                    new_summary = await summarize_history(
                        old_messages, llm, meta.get("summary", "")
                    )
                    meta["summary"] = new_summary
                    meta["messages"] = meta["messages"][-6:]
                    logger.info("Summarized chat %s history", chat_id)
                except Exception as e:
                    logger.warning("Summarization failed for chat %s: %s", chat_id, e)

        self.store.put(namespace, chat_id, meta)

    def set_collection(self, chat_id: str, collection_id: str):
        namespace = ("chats",)
        try:
            item = self.store.get(namespace, chat_id)
            if item and item.value:
                meta = item.value
                meta["collection_id"] = collection_id
                self.store.put(namespace, chat_id, meta)
        except Exception:
            pass

    def get_collection_id(self, chat_id: str) -> str | None:
        namespace = ("chats",)
        try:
            item = self.store.get(namespace, chat_id)
            if item and item.value:
                return item.value.get("collection_id")
        except Exception:
            pass
        return None
