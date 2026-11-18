.PHONY: install test lint run-mcp run-agent clean help

PYTHON ?= python
UV ?= uv

help:
	@echo "Available commands:"
	@echo "  make install    - Install package and dev dependencies"
	@echo "  make test       - Run test suite"
	@echo "  make run-mcp    - Start Bodhan MCP server over stdio"
	@echo "  make run-agent  - Display CLI help for bodhan_agent"
	@echo "  make clean      - Clean build artifacts and temporary files"

install:
	$(UV) pip install -e ".[dev]"

test:
	pytest -v tests/

run-mcp:
	$(PYTHON) -m bodhan_mcp

run-agent:
	$(PYTHON) -m bodhan_agent --help

clean:
	rm -rf build dist *.egg-info .pytest_cache .cache htmlcov .coverage
