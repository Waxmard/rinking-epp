### Root (cross-project)

```bash
make help          # list all targets
make lint          # backend + frontend lint
make fix           # autofix both
make typecheck     # mypy + tsc
make test          # backend pytest w/ coverage
make ci            # lint + typecheck + boundaries + test + docs-check
make docs-build    # render docs/src → README.md, CLAUDE.md, AGENTS.md, sub-READMEs
make docs-check    # fail if generated docs are stale
make backend-<X>   # delegates to fastapi/Makefile target X (e.g. backend-logs, backend-health, backend-lint)
```

Backend quality targets (lint/fix/format/typecheck/test/ci) live in `fastapi/Makefile` and are reachable from root via the `backend-` prefix or directly when in `fastapi/`.
