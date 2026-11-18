# Contributing to Bodhan AI Cookbook

Thank you for contributing to the **Bodhan AI Cookbook**! This repository serves as the definitive reference for production recipes, agent architectures, and developer tools powered exclusively by **Bodhan AI's sovereign Indic models** (`api.bodhan.ai`).

---

## 1. Recipe Architecture & Structure

Every recipe submitted to the cookbook must be completely self-contained within `examples/<your-recipe-folder>/`:

```text
examples/<your-recipe-folder>/
├── README.md               # Clear setup, architecture, and CLI usage
├── pyproject.toml          # Explicit dependencies and CLI entrypoints
├── .env.example            # Credentials template (NEVER commit .env)
├── Makefile                # Standard targets: install, check, test, clean
├── src/                    # Implementation source code
└── tests/                  # Unit and integration test suite
```

---

## 2. Strict Ground Rules & Constraints

1. **Bodhan Indic Models Only**:
   - Speech-to-Text: `Indic-Transcribe` (Core/Flex)
   - Translation: `Indic-Translate` (22 scheduled Indian languages + English)
   - Speech Synthesis: `Indic-Speak`
   - Document OCR: `Indic-OCR`
   - *Strictly prohibited:* Whisper, Tesseract, cloud vision/translate, IndicTrans2, or non-Bodhan APIs.
2. **LLM Boundary Constraints**:
   - The LLM orchestrates planning, tool routing, English explanations, and verification.
   - The LLM **must never** generate or translate Indian-language text, transcribe audio, read image text, or synthesize speech.
3. **Media & Cost Rules**:
   - Never serialize base64 media inline into LLM conversation context. Always pass media by file paths and disk references.
   - Use content-addressed caching to eliminate duplicate API calls and duplicate spend.
   - All synthesized audio must be tagged with AI-generated metadata.
   - Track and enforce exact INR (₹) costs based on official Bodhan pricing.
4. **Security & Prompt Injection Defenses**:
   - Wrap untrusted data (transcripts, OCR text, document contents) into inert `<data_payload>` tags.
   - Never follow instructions embedded inside data payloads.
5. **Honest Handling of Impossible Tasks**:
   - If a language is unsupported (e.g. French, German), an input file is missing, or the rupee/step budget is insufficient, the system must halt cleanly with status `IMPOSSIBLE` or `BUDGET_EXCEEDED` and document the exact reason. Never fabricate outputs.

---

## 3. Pull Request Submission Checklist

Before submitting a Pull Request:
- [ ] Recipe is located under `examples/<recipe-name>/`.
- [ ] Branch is named `assignment/tool-agent-<github-handle>` (e.g., `assignment/tool-agent-PushpendarSingh23`).
- [ ] PR title follows: `[Agentic Eng Assignment] Tool server and agent — <Your Name>`.
- [ ] All tests pass (`make test` or `pytest -v tests/`).
- [ ] Verification suite passes (`make check`).
- [ ] No `.env`, secrets, or large binary media committed to version control.
- [ ] Demo video link (<= 5 minutes) included in PR description.
