### Git Hooks

Husky runs `lint-staged` on staged frontend files (`eslint --fix` + `prettier --write` on `*.{ts,tsx}`; prettier on `*.{js,jsx,json}`). Config in `frontend/package.json` under `lint-staged`. Hook script in `.husky/pre-commit`.

Python files use the `pre-commit` framework (`.pre-commit-config.yaml`, ruff hooks) — independent of husky.
