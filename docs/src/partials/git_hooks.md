### Git Hooks

[Lefthook](https://lefthook.dev/) manages all pre-commit hooks via `lefthook.yml` at repo root. Hooks run in parallel and only on staged files matching each glob:

- **biome** — `frontend/src/**/*.{ts,tsx,js,jsx,json}` → `biome check --write`
- **ruff-lint** — `fastapi/**/*.py` → `ruff check --fix`
- **ruff-format** — `fastapi/**/*.py` → `ruff format`
- **tach** — `fastapi/app/**/*.py` or `fastapi/tach.toml` → `tach check` (module-boundary enforcement)

Autofixed files are re-staged automatically (`stage_fixed: true`). Hooks install via the root `prepare` script when you run `npm install`.
