## Repo Layout

- `fastapi/` — Python backend (uv, pyproject.toml, Dockerfile, Makefile)
- `frontend/` — React Native/Expo app (package.json, biome)
- `docs/src/` — documentation templates and partials (rendered by `scripts/build_docs.py`)
- `scripts/` — repo-wide tooling (e.g. `build_docs.py`)
- `/package.json` — root dev-tooling only (lefthook). Not a JS project.
- `lefthook.yml` — git hooks (biome for frontend, ruff for backend)
