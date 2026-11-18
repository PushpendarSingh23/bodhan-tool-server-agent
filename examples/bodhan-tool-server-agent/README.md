# Bodhan Tool Server & Task Agent

> **Production-grade Model Context Protocol (MCP) Server and Autonomous Task Agent built exclusively for Bodhan AI's sovereign Indic models.**

[![Python 3.10+](https://img.shields.io/badge/python-3.10+-blue.svg)](https://www.python.org/downloads/)
[![MCP Specification](https://img.shields.io/badge/MCP-1.0-green.svg)](https://modelcontextprotocol.io/)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

---

## Architecture Overview

This recipe implements a decoupled, modular architecture adhering to strict separation of concerns:

```
┌────────────────────────────────────────────────────────────────────────┐
│                        Task Agent (`bodhan_agent`)                     │
│                                                                        │
│  CLI Command: python -m bodhan_agent --task ... --files ... --out ...  │
│                                                                        │
│   ┌────────────────┐      ┌─────────────────┐     ┌────────────────┐   │
│   │  Task Planner  │ ---> │ Execution Loop  │ --->│ Budget Tracker │   │
│   │ (OpenAI-compat)│      │  (Act & Retry)  │     │ (Steps/INR/sec)│   │
│   └────────────────┘      └────────┬────────┘     └────────────────┘   │
│                                    │                                   │
│                           ┌────────┴────────┐                          │
│                           │ Output Verifier │                          │
│                           │ (Script/Length) │                          │
│                           └────────┬────────┘                          │
└────────────────────────────────────┼───────────────────────────────────┘
                                     │ JSON-RPC / MCP Client or Shared Layer
                                     ▼
┌────────────────────────────────────────────────────────────────────────┐
│                        MCP Server (`bodhan_mcp`)                       │
│                                                                        │
│   Exposes Bodhan Models via Stdio (`python -m bodhan_mcp`)             │
│                                                                        │
│   ┌────────────────────────────────────────────────────────────────┐   │
│   │ Content-Addressed Deterministic Cache (.cache/bodhan)          │   │
│   └────────────────────────────────┬───────────────────────────────┘   │
│                                    ▼                                   │
│   ┌───────────────────┬───────────────────┬────────────────────────┐   │
│   │ Indic-Transcribe  │  Indic-Translate  │      Indic-Speak       │   │
│   │  (Core & Flex)    │ (22+ Languages)   │  (22+ Langs & Voices)  │   │
│   │  [<=30s windows]  │ [32K ctx & docs]  │  [AI Disclaimer Tag]   │   │
│   ├───────────────────┴───────────────────┴────────────────────────┤   │
│   │ Indic-OCR (Multi-page PDF & image text extraction)             │   │
│   ├────────────────────────────────────────────────────────────────┤   │
│   │ Media Helpers (inspect_media, chunk_audio, file-ref validation)│   │
│   └────────────────────────────────┬───────────────────────────────┘   │
│                                    ▼                                   │
│                      Bodhan API (api.bodhan.ai/v1)                     │
└────────────────────────────────────────────────────────────────────────┘
```

---

## Strict Ground Rules & Constraints

1. **Only Bodhan Models**:
   - Speech-to-Text: `Indic-Transcribe` (Core/Flex)
   - Translation: `Indic-Translate` (22 scheduled Indian languages + English)
   - Speech Synthesis: `Indic-Speak` (Teacher-paced, STEM-aware, code-mixed)
   - Document OCR: `Indic-OCR` (Printed/handwritten multi-script recognition)
   - *Strictly no Whisper, Tesseract, cloud vision/translate, or third-party Indic models.*
2. **LLM Boundaries**:
   - The LLM (configured via `LLM_BASE_URL`, `LLM_MODEL`, `LLM_API_KEY`) is strictly an orchestrator: planning, tool routing, English explanations, and verification judgment.
   - The LLM **never** writes or edits Indian-language text directly, transcribes audio, reads images, or synthesizes speech.
3. **Media & Cost Rules**:
   - Media files are referenced strictly by file paths (never serialized inline as base64 in LLM conversation context).
   - All tool calls are content-addressed and cached locally (`.cache/bodhan`) to prevent duplicate spend.
   - Every synthesized audio file is stamped with AI-generated metadata.
   - Billed costs are computed accurately in **INR (₹)** based on official Bodhan pricing:
     - Transcribe: ₹0.10 / min
     - Translate: ₹0.20 / 10,000 output tokens
     - Speak: ₹6.00 / 10,000 characters
     - OCR: ₹0.20 / page
4. **Untrusted Content & Prompt Injection Defenses**:
   - Transcripts, OCR outputs, and user files are treated strictly as inert data enclosed in `<data_payload>` containers.
   - Text inside payloads is never executed as agent instructions.
5. **Honest Handling of Impossible Tasks**:
   - If an unsupported language is requested (e.g., German, French), a file is missing, or the budget is insufficient, the agent halts cleanly and reports `IMPOSSIBLE` or `BUDGET_EXCEEDED` in `result.md` and `report.json` without fake outputs.

---

## Quickstart

### 1. Installation

```bash
# Clone the cookbook repository
git clone https://github.com/bodhan-ai/bodhan-cookbook.git
cd bodhan-cookbook/examples/bodhan-tool-server-agent

# Create virtual environment and install dependencies
uv venv
source .venv/bin/activate  # On Windows: .venv\Scripts\Activate.ps1
uv pip install -e ".[dev]"
```

### 2. Configure Environment

Copy `.env.example` to `.env` and fill in your keys:

```bash
cp .env.example .env
```

```env
LLM_BASE_URL=https://api.openai.com/v1
LLM_MODEL=gpt-4o-mini
LLM_API_KEY=sk-...

BODHAN_BASE_URL=https://api.bodhan.ai/v1
BODHAN_API_KEY=your_bodhan_api_key
```

---

## MCP Server (`bodhan_mcp`)

The MCP server runs over standard I/O (`stdio`) conforming to the Model Context Protocol.

### Running Standalone

```bash
python -m bodhan_mcp
```

### Registered Tools

| Tool Name | Parameters | Description |
|-----------|------------|-------------|
| `bodhan_transcribe` | `audio_path`, `language`, `model_variant` | Transcribes audio (handles >30s windowing and audio chunk merging) |
| `bodhan_translate` | `text`, `text_path`, `source_lang`, `target_lang` | Translates text across 22 Indian languages preserving Markdown/LaTeX |
| `bodhan_speak` | `text`, `text_path`, `language`, `voice`, `output_path` | Synthesizes speech with short-input chunking & AI disclaimer metadata |
| `bodhan_ocr` | `file_path`, `output_path` | Multi-page PDF and image text extraction in reading-ordered Markdown |
| `bodhan_inspect_media` | `file_path` | Validates file format, audio duration, image dimensions, PDF page count |
| `bodhan_chunk_audio` | `audio_path`, `max_duration_sec`, `output_dir` | Splits audio files into standard <=30s chunks |

---

## Task Agent (`bodhan_agent`)

The CLI agent plans and executes multi-step Indic workflows, enforcing rupee, step, and timeout budgets.

### CLI Syntax

```bash
python -m bodhan_agent \
  --task "Transcribe lecture.wav in Hindi, translate to Kannada, and synthesize speech in Kannada" \
  --files ./lecture.wav \
  --out ./runs/run-01 \
  --max-steps 30 \
  --max-cost-inr 20 \
  --timeout 300
```

### Generated Artifacts

Each run outputs to the `--out` folder:
- `result.md`: Clear, human-readable summary, execution status, costs, and links.
- `report.json`: Structured, machine-readable run report (Pydantic schema).
- `trace.jsonl`: Step-by-step audit log of plans, tool calls, costs, and verifications.
- `artifacts/`: Intermediate and final output files (transcripts, translations, audio, OCR).

---

## Running Tests

```bash
# Run complete test suite
pytest -v tests/

# Run chunking & limit tests
pytest -v tests/test_chunking_and_limits.py

# Run budget & verifier tests
pytest -v tests/test_budget_and_verifier.py

# Run end-to-end multi-step workflow test
pytest -v tests/test_e2e_multi_step.py
```
