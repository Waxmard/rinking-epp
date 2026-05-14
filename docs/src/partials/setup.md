## First-Time Setup

Tool versions (node, python, uv) are pinned via [mise](https://mise.jdx.dev/) in `mise.toml`. Install mise (`brew install mise`), then:

```bash
mise install     # install pinned node/python/uv versions
make setup       # installs root deps (incl. lefthook git hooks), frontend deps, backend deps
```

Or step-by-step:

1. `mise install` (installs node, python, uv at pinned versions)
2. `npm install` (root, installs lefthook + git hooks via `prepare` script)
3. `cd frontend && npm install`
4. `cd ../fastapi && uv sync --extra dev --group dev`
