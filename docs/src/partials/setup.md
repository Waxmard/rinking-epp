## First-Time Setup

```bash
make setup    # installs root deps, frontend deps, backend deps + pre-commit hooks
```

Or step-by-step:

1. `npm install` (root, activates husky)
2. `cd frontend && npm install`
3. `cd ../fastapi && uv sync --extra dev --group dev`
4. `uv run pre-commit install`
