## Repo Layout

- `fastapi/` — Python backend (uv, pyproject.toml, Dockerfile, Makefile)
- `frontend/` — React Native/Expo app (package.json, biome)
- `docs/src/` — documentation templates and partials (rendered by `scripts/build_docs.py`)
- `scripts/` — repo-wide tooling (e.g. `build_docs.py`)
- `/package.json` — root dev-tooling only (husky). Not a JS project.
- `.husky/` — git hooks (pre-commit → `cd frontend && npx lint-staged`)
- `.pre-commit-config.yaml` — Python hooks (ruff) for `fastapi/`
