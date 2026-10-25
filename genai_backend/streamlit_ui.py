"""OmniDoc ChatGPT-style document chat UI.

Run with: streamlit run streamlit_ui.py
"""

from __future__ import annotations

import time

import httpx
import streamlit as st

API = "http://127.0.0.1:8000"

st.set_page_config(page_title="OmniDoc AI", page_icon="🤖", layout="wide")

for key, default in {
    "chat_id": None,
    "chat_messages": [],
    "collections": [],
    "auto_collection_attempted": False,
}.items():
    st.session_state.setdefault(key, default)


def api_get(path: str, **kwargs):
    try:
        response = httpx.get(f"{API}{path}", timeout=30, **kwargs)
        response.raise_for_status()
        return response.json()
    except httpx.HTTPStatusError as exc:
        st.error(f"API error {exc.response.status_code}: {exc.response.text}")
    except httpx.ConnectError:
        st.error("Cannot connect to backend. Is uvicorn running on port 8000?")
    return None


def api_post(path: str, **kwargs):
    try:
        response = httpx.post(f"{API}{path}", timeout=60, **kwargs)
        response.raise_for_status()
        return response.json()
    except httpx.HTTPStatusError as exc:
        st.error(f"API error {exc.response.status_code}: {exc.response.text}")
    except httpx.ConnectError:
        st.error("Cannot connect to backend. Is uvicorn running on port 8000?")
    return None


def refresh_collections() -> None:
    collections = api_get("/v1/collections")
    if collections is not None:
        st.session_state.collections = [
            {"id": item["id"], "name": item["name"]} for item in collections
        ]

    if not st.session_state.collections and not st.session_state.auto_collection_attempted:
        st.session_state.auto_collection_attempted = True
        created = api_post("/v1/collections", json={"name": "My documents"})
        if created:
            st.session_state.collections = [{
                "id": created["id"], "name": created["name"],
            }]


def render_sources(sources: list[dict], sources_by_action: dict[str, list[dict]]) -> None:
    groups = sources_by_action or {"Sources": sources}
    for action, action_sources in groups.items():
        if action != "Sources":
            st.caption(action.replace("_", " "))
        for source in action_sources:
            if source.get("type") == "document":
                filename, page = source.get("filename"), source.get("page")
                if filename and isinstance(page, int):
                    st.write(f"📄 {filename} · page {page}")
                elif filename:
                    st.write(f"📄 {filename}")
            elif source.get("url"):
                label = source.get("title") or source["url"]
                st.markdown(f"🌐 [{label}]({source['url']})")


def upload_files(collection_id: str, files) -> list[dict]:
    payload = [
        ("files", (uploaded.name, uploaded.getvalue(), uploaded.type or "application/octet-stream"))
        for uploaded in files
    ]
    return api_post(f"/v1/collections/{collection_id}/documents", files=payload) or []


def wait_for_ingestion(job_ids: list[str]) -> bool:
    if not job_ids:
        return True
    deadline = time.time() + 120
    while time.time() < deadline:
        statuses = [api_get(f"/v1/jobs/{job_id}") for job_id in job_ids]
        if any(status is None for status in statuses):
            return False
        if any(status.get("status") == "failed" for status in statuses):
            return False
        if all(status.get("status") == "completed" for status in statuses):
            return True
        time.sleep(1)
    return False


def load_thread(chat_id: str) -> None:
    history = api_get(f"/v1/chats/{chat_id}")
    if history:
        st.session_state.chat_id = history["chat_id"]
        st.session_state.chat_messages = history.get("messages", [])
        st.session_state.active_collection_id = history.get("collection_id")


refresh_collections()

# The sidebar is intentionally only thread navigation.
with st.sidebar:
    st.title("🤖 OmniDoc AI")
    if st.button("＋ New chat", width="stretch"):
        st.session_state.chat_id = None
        st.session_state.chat_messages = []
        st.rerun()

    st.divider()
    st.caption("Threads")
    threads = api_get("/v1/chats") or []
    if not threads:
        st.caption("No saved threads yet.")
    for thread in threads:
        title = thread.get("title") or "New chat"
        if st.button(title, key=f"thread_{thread['chat_id']}", width="stretch"):
            load_thread(thread["chat_id"])
            st.rerun()


collection_id = st.session_state.get("active_collection_id")
if not collection_id and st.session_state.collections:
    collection_id = st.session_state.collections[0]["id"]
    st.session_state.active_collection_id = collection_id

st.title("Chat with your documents")
st.caption("Attach a PDF or image with the paperclip, then ask a question about it.")

for message in st.session_state.chat_messages:
    with st.chat_message(message["role"]):
        st.write(message["content"])
        if message.get("sources") or message.get("sources_by_action"):
            with st.expander("Sources"):
                render_sources(message.get("sources", []), message.get("sources_by_action", {}))


submission = st.chat_input(
    "Message OmniDoc…",
    accept_file="multiple",
    file_type=["pdf", "png", "jpg", "jpeg"],
)

if submission:
    prompt = getattr(submission, "text", None)
    attached_files = list(getattr(submission, "files", []) or [])
    if prompt is None:
        prompt = str(submission)
    prompt = prompt.strip()

    if not collection_id:
        st.error("A document collection could not be created. Check the backend connection.")
        st.stop()

    if attached_files:
        upload_results = upload_files(collection_id, attached_files)
        ready = wait_for_ingestion([item["job_id"] for item in upload_results])
        if not ready:
            st.error("The attachment could not be indexed. Please try again.")
            st.stop()
        with st.chat_message("assistant"):
            st.success(f"Uploaded {len(attached_files)} document(s).")

    if prompt:
        st.session_state.chat_messages.append({"role": "user", "content": prompt})
        with st.chat_message("user"):
            st.write(prompt)

        with st.chat_message("assistant"):
            with st.spinner("Thinking…"):
                data = api_post(
                    "/v1/chat",
                    json={
                        "collection_id": collection_id,
                        "message": prompt,
                        "chat_id": st.session_state.chat_id,
                    },
                )
            if data:
                st.session_state.chat_id = data.get("chat_id")
                answer = data.get("answer", "No response")
                sources = data.get("sources", [])
                sources_by_action = data.get("sources_by_action", {})
                st.write(answer)
                if sources or sources_by_action:
                    with st.expander("Sources"):
                        render_sources(sources, sources_by_action)
                st.session_state.chat_messages.append({
                    "role": "assistant",
                    "content": answer,
                    "sources": sources,
                    "sources_by_action": sources_by_action,
                })
            else:
                st.error("No response from the backend.")
