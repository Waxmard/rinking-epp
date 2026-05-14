## Documentation Automation

`README.md`, `CLAUDE.md`, `AGENTS.md`, `fastapi/README.md`, and `frontend/README.md` are **generated** from templates in `docs/src/` by `scripts/build_docs.py`. Do not edit the generated files directly — edit the template or partial and re-render.

```bash
make docs-build    # render templates → generated files
make docs-check    # CI check: fail if generated docs are stale
```

Partials live in `docs/src/partials/` and are included with double-brace `include:partials/<name>.md` directives. `CLAUDE.md` and `AGENTS.md` share a single template (`docs/src/CLAUDE.md`) and are rendered to both paths.
