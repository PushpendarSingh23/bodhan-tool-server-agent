# Bodhan AI Cookbook

> **Practical recipes, agent workflows, and developer tools for building sovereign Indian-language AI applications with Bodhan AI (`api.bodhan.ai`).**

[![Python 3.10+](https://img.shields.io/badge/python-3.10+-blue.svg)](https://www.python.org/downloads/)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![Bodhan AI](https://img.shields.io/badge/Powered%20By-Bodhan%20AI-orange.svg)](https://bodhan.ai)

---

## Featured Recipes & Examples

### 1. [Bodhan Tool Server and Task Agent](examples/bodhan-tool-server-agent/README.md)
* **Directory:** `examples/bodhan-tool-server-agent/`
* **Description:** Production-ready Model Context Protocol (MCP) server over `stdio` and CLI Task Agent for multi-step Indic language workflows (Speech-to-Text, Machine Translation, Text-to-Speech, Document OCR) with strict LLM boundaries, INR cost and step budgets, output verification, and prompt-injection safety.
* **Models Utilized:** `Indic-Transcribe` (Core/Flex), `Indic-Translate`, `Indic-Speak`, `Indic-OCR`.

---

## Quickstart

```bash
git clone https://github.com/bodhan-ai/bodhan-cookbook.git
cd bodhan-cookbook/examples/bodhan-tool-server-agent

# Install with dev dependencies
uv venv
source .venv/bin/activate  # On Windows: .venv\Scripts\Activate.ps1
uv pip install -e ".[dev]"

# Run test suite
pytest -v tests/
```

---

## Repository Conventions

- **Clean Decoupling:** Tool servers (`bodhan_mcp`) run standalone over stdio for any MCP client, while agents (`bodhan_agent`) manage planning, budgets, and reporting.
- **Strict Ground Rules:** Only sovereign Bodhan Indic models are used. Media files are referenced via disk paths (never base64 in LLM context).
- **Security & Safety:** Untrusted content (transcripts, OCR) is isolated in `<data_payload>` tags. Impossible tasks are handled cleanly without fake outputs.
