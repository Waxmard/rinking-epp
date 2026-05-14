## Development Notes for AI Agents

- Check for TypeScript errors after frontend changes.
- Frontend uses mock Google OAuth in development (not connected to backend yet).
- Comparison sessions are stored in-memory (not persistent).
- API endpoints are prefixed with `/api/`.
- Do **not** run `npm run ios`, `npm run android`, or `npx expo start` — the user runs these in a separate terminal.
- Do **not** run `git commit`, `git add`, or `git push` — the user handles staging, committing, and pushing.
- Do **not** run `make clean`, `make dev`, `make fresh`, `make restart`, or `make reset` — the user runs these themselves.
- Backend package management: use `uv`, not `pip`.
