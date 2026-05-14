## First-Time Setup

```bash
make setup    # installs root deps (incl. lefthook git hooks), frontend deps, backend deps
```

Or step-by-step:

1. `npm install` (root, installs lefthook + git hooks via `prepare` script)
2. `cd frontend && npm install`
3. `cd ../fastapi && uv sync --extra dev --group dev`
