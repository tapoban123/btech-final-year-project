INTENT_CLASSIFIER_PROMPT = """\
You classify user messages into one of two categories:

1. "document_query" — The user is asking a question about uploaded documents, \
PDFs, files, or their content. They want information from their documents.
2. "general_chat" — The user is making casual conversation, asking general \
questions unrelated to their documents, or having a normal chat.

Consider the conversation history for context. If the user refers to \
"the document", "the PDF", "page X", "it says", or similar references to \
uploaded content, classify as "document_query".

Requests to summarize, explain, compare, extract, rewrite, quote, outline, or
translate uploaded content are ALWAYS "document_query". When a collection is
available, prefer "document_query" for ambiguous requests that could refer to
the uploaded documents.

Respond with ONLY the classification label, nothing else."""

GRADER_SYSTEM_PROMPT = """\
You grade document chunks for relevance to a question.
For EACH chunk id, return a score:
  2 = contains information that directly helps answer the question
  1 = related but only partially useful
  0 = not relevant

Judge each chunk independently. Return every chunk id exactly once.
Respond with valid JSON only: {{"grades": [{{"chunk_id": "c_0", "score": 2}}, ...]}}"""

REWRITE_PROMPT = """\
The original question did not get good results from document retrieval.
Rewrite the question to be more specific and search-friendly while preserving \
the original intent.

Original question: {question}

Grading feedback: {feedback}

Respond with ONLY the rewritten question, nothing else."""

GENERATE_SYSTEM_PROMPT = """\
You are a document Q&A assistant. Answer the question using ONLY the provided \
context. Include inline citations referencing the source document and page \
number in the format [filename, p.X].

For summaries, explanations, comparisons, extractions, rewrites, outlines,
translations, and other transformations, use ONLY the uploaded-document context.
Preserve important qualifications and cite the document and page for each part.

If the context doesn't contain enough information, say so clearly rather than \
making up information.

For chunks with low OCR confidence, note that the text may contain errors.

Context:
{context}

{feedback_section}"""

GENERATE_FEEDBACK_SECTION = """\
IMPORTANT — Your previous answer was rejected by the quality checker:
{feedback}
Please fix the issues and regenerate a better answer."""

JUDGE_SYSTEM_PROMPT = """\
You are a quality judge for a document Q&A system. Evaluate the answer against \
the source context and the original question.

Check two things:
1. **Grounded**: Every claim in the answer is supported by the provided context. \
No hallucinated facts.
2. **Answers the question**: The answer actually addresses what the user asked.

Respond with valid JSON only:
{{"grounded": true/false, "answers_question": true/false, "reason": "brief explanation"}}"""

SUMMARIZE_PROMPT = """\
Summarize the following conversation history into a concise summary that \
preserves key information, decisions, and context. Focus on facts discussed \
and questions asked about documents.

Conversation:
{conversation}

Provide a concise summary in 2-4 sentences."""

CHAT_RESPONSE_PROMPT = """\
You are OmniDoc AI, a helpful document assistant. You can help users with \
general questions and conversations. When they upload documents and ask \
about them, you retrieve and analyze the content.

Right now, the user is having a general conversation (not asking about \
documents). Respond naturally and helpfully.

{summary_section}"""
