.PHONY: setup run test lint format

setup:
	uv venv
	. .venv/bin/activate && uv pip install -e ".[dev]"

run:
	source .venv/bin/activate && uv pip install -e . && uvicorn app.main:app --reload

test:
	pytest

lint:
	ruff app/
	mypy app/

format:
	isort app/
	black app/
