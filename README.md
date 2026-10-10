# OmniDoc AI

A college final year project that lets you chat with your documents — including PDFs, text files, and images with charts or tables.

---

## What is this?

Most document Q&A tools only work well with plain text. If your notes, reports, or slides have diagrams, scanned receipts, or data tables, those tools often skip them or lose the context completely.

**OmniDoc AI** solves that. You upload a document or take a photo of notes from your phone, and you can chat with it in plain English. The app finds the exact sections that answer your question, shows you where it got the info from, and explains it clearly without making things up.

---

## How it works

The whole process is simple:

1. **Upload:** Pick a PDF, text file, or image from your phone.
2. **Extract:** The app reads the text. If you uploaded an image or scanned page, it uses OCR and computer vision so charts and graphics aren't ignored.
3. **Split nicely:** It breaks your file into small, sensible pieces while keeping paragraphs and related tables together.
4. **Find the right info:** When you ask a question, the app quickly looks up the exact pieces of your document that match what you're asking.
5. **Get an answer:** The AI uses those pieces to write an honest, accurate answer with citations pointing back to your document.

---

## What we built it with

- **Phone App:** Flutter (works on Android and iOS), with local offline storage so it feels fast and responsive.
- **Backend:** Python with FastAPI to handle file uploads, text parsing, OCR, and AI pipelines in one unified backend.
- **Search & Storage:** A vector database to search through text chunks by meaning, plus a standard database for user profiles and file details.

---

## Why we're building it

We started this project to fix a few real issues we kept running into:

- **Searching only by filenames:** Normal search tools force you to remember the exact file name or exact keywords. If your file is named something like `Scan_001.pdf` or `notes_final.pdf`, good luck finding it. Here, you don't need to remember the name at all — you can search directly by what the document actually talks about.
- **Lost diagrams and layouts:** Normal tools tear apart the formatting of a PDF, throwing away pictures and charts. We wanted visual content to stay connected to the text next to it.
- **AI guessing (hallucinations):** When an AI tries to read a 50-page document all at once, it gets lost and starts making things up. Giving it only the exact parts that matter keeps the answers grounded.
- **Mobile-friendly access:** A lot of smart document tools are built only for desktops. We wanted something simple and light that you can pull out on your phone whenever you need it.

---

## Getting Started

*(Detailed setup steps will be added as the services are connected.)*

1. Clone the repo:
   ```bash
   git clone https://github.com/tapoban123/btech-final-year-project.git
   ```
