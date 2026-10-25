from core.chat.manager import ChatManager


async def test_chat_history_persists_and_restores_messages_and_sources(tmp_path):
    history_file = tmp_path / "chats.json"
    manager = ChatManager(history_file)
    thread = manager.get_or_create_thread()
    manager.set_collection(thread["chat_id"], "collection-1")

    source = {"type": "document", "doc_id": "doc-1", "filename": "notes.pdf", "page": 4}
    await manager.append_turn(
        thread["chat_id"], "What does it say?", "It says hello.",
        assistant_sources=[source],
        assistant_sources_by_action={"Hybrid_RAG": [source]},
    )

    restored = ChatManager(history_file)
    saved = restored.get_thread(thread["chat_id"])
    assert saved is not None
    assert saved["collection_id"] == "collection-1"
    assert saved["messages"][0]["content"] == "What does it say?"
    assert saved["messages"][1]["sources"] == [source]
    assert restored.list_threads()[0]["title"] == "What does it say?"
