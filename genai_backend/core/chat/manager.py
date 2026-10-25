from __future__ import annotations

import uuid
import logging
import json
from datetime import datetime, timezone
from pathlib import Path

from langgraph.store.memory import InMemoryStore
from langgraph.checkpoint.memory import MemorySaver

from core.chat.memory import should_summarize, summarize_history, build_chat_context

logger = logging.getLogger(__name__)


class ChatManager:
    def __init__(self, storage_path: str | Path | None = None):
        self.store = InMemoryStore()
        self.checkpointer = MemorySaver()
        self.storage_path = Path(storage_path) if storage_path else None
        self._threads: dict[str, dict] = self._load_threads()

    def _load_threads(self) -> dict[str, dict]:
        if not self.storage_path or not self.storage_path.exists():
            return {}
        try:
            loaded = json.loads(self.storage_path.read_text(encoding="utf-8"))
            return loaded if isinstance(loaded, dict) else {}
        except (OSError, json.JSONDecodeError) as exc:
            logger.warning("Could not load chat history: %s", exc)
            return {}

    def _persist_threads(self) -> None:
        if not self.storage_path:
            return
        try:
            self.storage_path.parent.mkdir(parents=True, exist_ok=True)
            temporary = self.storage_path.with_suffix(".tmp")
            temporary.write_text(json.dumps(self._threads), encoding="utf-8")
            temporary.replace(self.storage_path)
        except OSError as exc:
            logger.warning("Could not persist chat history: %s", exc)

    def _save_thread(self, meta: dict) -> None:
        meta["updated_at"] = datetime.now(timezone.utc).isoformat()
        self._threads[meta["chat_id"]] = meta
        self._persist_threads()

    def get_or_create_thread(self, chat_id: str | None = None) -> dict:
        if chat_id is None:
            chat_id = uuid.uuid4().hex[:16]

        namespace = ("chats",)
        if chat_id in self._threads:
            meta = self._threads[chat_id]
            self.store.put(namespace, chat_id, meta)
            return meta
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
            "title": "New chat",
            "updated_at": datetime.now(timezone.utc).isoformat(),
        }
        self.store.put(namespace, chat_id, meta)
        self._save_thread(meta)
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
        assistant_sources: list[dict] | None = None,
        assistant_sources_by_action: dict[str, list[dict]] | None = None,
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
        meta["messages"].append({
            "role": "assistant", "content": assistant_msg,
            "sources": assistant_sources or [],
            "sources_by_action": assistant_sources_by_action or {},
        })
        if meta.get("title") in (None, "", "New chat"):
            meta["title"] = user_msg.strip()[:60] or "New chat"

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
        self._save_thread(meta)

    def set_collection(self, chat_id: str, collection_id: str):
        namespace = ("chats",)
        try:
            item = self.store.get(namespace, chat_id)
            if item and item.value:
                meta = item.value
                meta["collection_id"] = collection_id
                self.store.put(namespace, chat_id, meta)
                self._save_thread(meta)
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

    def list_threads(self) -> list[dict]:
        return sorted(
            (
                {
                    "chat_id": meta["chat_id"],
                    "collection_id": meta.get("collection_id"),
                    "title": meta.get("title") or "New chat",
                    "updated_at": meta.get("updated_at", ""),
                }
                for meta in self._threads.values()
            ),
            key=lambda item: item["updated_at"],
            reverse=True,
        )

    def get_thread(self, chat_id: str) -> dict | None:
        return self._threads.get(chat_id)
