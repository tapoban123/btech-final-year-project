"""
OmniDoc AI — Streamlit UI
Run:  streamlit run streamlit_ui.py
Requires: pip install streamlit httpx
Connects to FastAPI backend at http://127.0.0.1:8000
"""

import httpx
import streamlit as st

API = "http://127.0.0.1:8000"

st.set_page_config(page_title="OmniDoc AI", page_icon="🤖", layout="wide")


# ── Session state defaults ──────────────────────────────────────────────
if "chat_id" not in st.session_state:
    st.session_state.chat_id = None
if "chat_messages" not in st.session_state:
    st.session_state.chat_messages = []
if "collections" not in st.session_state:
    st.session_state.collections = []


# ── Helpers ─────────────────────────────────────────────────────────────
def api_get(path: str, **kwargs):
    try:
        r = httpx.get(f"{API}{path}", timeout=30, **kwargs)
        r.raise_for_status()
        return r.json()
    except httpx.HTTPStatusError as e:
        st.error(f"API error {e.response.status_code}: {e.response.text}")
        return None
    except httpx.ConnectError:
        st.error("Cannot connect to backend. Is uvicorn running on port 8000?")
        return None


def api_post(path: str, **kwargs):
    try:
        r = httpx.post(f"{API}{path}", timeout=60, **kwargs)
        r.raise_for_status()
        return r.json()
    except httpx.HTTPStatusError as e:
        st.error(f"API error {e.response.status_code}: {e.response.text}")
        return None
    except httpx.ConnectError:
        st.error("Cannot connect to backend. Is uvicorn running on port 8000?")
        return None


# ── Sidebar ─────────────────────────────────────────────────────────────
with st.sidebar:
    st.title("🤖 OmniDoc AI")
    st.caption("Multimodal Document Q&A with RAG")
    st.divider()

    # Health check
    if st.button("Check Backend Status"):
        data = api_get("/v1/health")
        if data:
            st.success(f"✅ {data['service']} v{data['version']} — {data['status']}")

    st.divider()

    # Create collection
    st.subheader("Collections")
    col_name = st.text_input("New collection name", placeholder="e.g. my-docs")
    if st.button("Create Collection", disabled=not col_name):
        data = api_post("/v1/collections", json={"name": col_name})
        if data:
            st.session_state.collections.append({"id": data["id"], "name": data["name"]})
            st.success(f"Created: **{data['name']}**")
            st.code(data["id"], language=None)

    # Show saved collections
    if st.session_state.collections:
        st.markdown("**Saved collections:**")
        for c in st.session_state.collections:
            st.text(f"📁 {c['name']}\n   {c['id']}")


# ── Main area with tabs ─────────────────────────────────────────────────
tab_upload, tab_chat = st.tabs(["📤 Upload", "💬 Chat"])

# Collection selector helper
col_options = {c["name"]: c["id"] for c in st.session_state.collections}


# ── Upload Tab ──────────────────────────────────────────────────────────
with tab_upload:
    st.header("Upload Documents")

    if not col_options:
        st.info("Create a collection in the sidebar first.")
    else:
        upload_col = st.selectbox(
            "Collection", options=list(col_options.keys()), key="upload_col"
        )
        upload_col_id = col_options[upload_col]

        uploaded_files = st.file_uploader(
            "Choose files", type=["pdf", "txt", "docx"],
            accept_multiple_files=True,
        )

        if st.button("Upload", disabled=not uploaded_files):
            files = [("files", (f.name, f.getvalue(), f.type)) for f in uploaded_files]
            try:
                r = httpx.post(
                    f"{API}/v1/collections/{upload_col_id}/documents",
                    files=files,
                    timeout=60,
                )
                r.raise_for_status()
                results = r.json()
                for res in results:
                    st.success(f"✅ **{res['filename']}** uploaded — Job: `{res['job_id']}`")

                # Poll jobs
                import time
                progress_bars = {}
                job_ids = [res["job_id"] for res in results]

                status_container = st.container()
                all_done = False
                while not all_done:
                    all_done = True
                    for job_id in job_ids:
                        job = api_get(f"/v1/jobs/{job_id}")
                        if not job:
                            continue
                        pct = int((job.get("progress", 0)) * 100)
                        status = job.get("status", "unknown")

                        if job_id not in progress_bars:
                            progress_bars[job_id] = status_container.progress(0, text=f"Job {job_id[:8]}…")

                        if status == "completed":
                            progress_bars[job_id].progress(100, text=f"✅ Complete")
                        elif status == "failed":
                            progress_bars[job_id].progress(pct, text=f"❌ Failed: {job.get('error_message', '')}")
                        else:
                            all_done = False
                            progress_bars[job_id].progress(pct, text=f"⏳ {status} ({pct}%)")

                    if not all_done:
                        time.sleep(2)

            except httpx.HTTPStatusError as e:
                st.error(f"Upload failed: {e.response.text}")
            except httpx.ConnectError:
                st.error("Cannot connect to backend.")


# ── Chat Tab ────────────────────────────────────────────────────────────
with tab_chat:
    st.header("Chat with Documents")

    if not col_options:
        st.info("Create a collection in the sidebar first.")
    else:
        chat_col = st.selectbox(
            "Collection", options=list(col_options.keys()), key="chat_col"
        )
        chat_col_id = col_options[chat_col]

        # Clear chat button
        if st.button("Clear Chat"):
            st.session_state.chat_messages = []
            st.session_state.chat_id = None
            st.rerun()

        # Display messages
        for msg in st.session_state.chat_messages:
            with st.chat_message(msg["role"]):
                st.write(msg["content"])
                if msg.get("sources"):
                    with st.expander("Sources"):
                        for s in msg["sources"]:
                            icon = "🌐" if s.get("type") == "web" else "📄"
                            name = s.get("filename") or s.get("title") or s.get("url") or ""
                            st.markdown(f"{icon} {name}")

        # Chat input
        if prompt := st.chat_input("Ask something..."):
            st.session_state.chat_messages.append({"role": "user", "content": prompt})
            with st.chat_message("user"):
                st.write(prompt)

            with st.chat_message("assistant"):
                with st.spinner("Thinking..."):
                    data = api_post("/v1/chat", json={
                        "collection_id": chat_col_id,
                        "message": prompt,
                        "chat_id": st.session_state.chat_id,
                    })

                if data:
                    st.session_state.chat_id = data.get("chat_id")
                    answer = data.get("answer", "No response")
                    st.write(answer)

                    sources = data.get("sources", [])
                    if sources:
                        with st.expander("Sources"):
                            for s in sources:
                                icon = "🌐" if s.get("type") == "web" else "📄"
                                name = s.get("filename") or s.get("title") or s.get("url") or ""
                                st.markdown(f"{icon} {name}")

                    st.session_state.chat_messages.append({
                        "role": "assistant",
                        "content": answer,
                        "sources": sources,
                    })
                else:
                    st.write("Error getting response")
                    st.session_state.chat_messages.append({
                        "role": "assistant",
                        "content": "Error getting response",
                    })
