from __future__ import annotations

from core.chat.memory import estimate_tokens, should_summarize, build_chat_context


def test_estimate_tokens():
    assert estimate_tokens("hello world") > 0
    assert estimate_tokens("") == 0
    assert estimate_tokens("a " * 100) > estimate_tokens("a " * 10)


def test_should_summarize_under_threshold():
    messages = [
        {"role": "user", "content": "Hi"},
        {"role": "assistant", "content": "Hello!"},
    ]
    assert should_summarize(messages, threshold=2000) is False


def test_should_summarize_over_threshold():
    messages = [
        {"role": "user", "content": "word " * 600},
        {"role": "assistant", "content": "word " * 600},
    ]
    assert should_summarize(messages, threshold=100) is True


def test_build_chat_context_no_summary():
    messages = [
        {"role": "user", "content": "Hello"},
        {"role": "assistant", "content": "Hi there"},
    ]
    summary, recent = build_chat_context("", messages, max_recent=6)
    assert summary == ""
    assert len(recent) == 2


def test_build_chat_context_with_summary():
    messages = [{"role": "user", "content": f"msg {i}"} for i in range(10)]
    summary, recent = build_chat_context("Previous summary text", messages, max_recent=6)
    assert summary == "Previous summary text"
    assert len(recent) == 6


def test_build_chat_context_caps_recent():
    messages = [{"role": "user", "content": f"msg {i}"} for i in range(20)]
    _, recent = build_chat_context("", messages, max_recent=6)
    assert len(recent) == 6
    assert recent[-1]["content"] == "msg 19"
