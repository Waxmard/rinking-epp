### Frontend (frontend/)

```bash
cd frontend
npm install                       # Install dependencies
npm run ios                       # Run on iOS simulator
npm run android                   # Run on Android emulator
npm run web                       # Run web version

# Code quality (Biome — single tool for lint + format)
npm run lint                      # Lint with Biome
npm run lint:fix                  # Fix lint errors
npm run format                    # Format with Biome
npm run format:check              # Check formatting
npm run check                     # Lint + format + import sort (combined)
npm run check:fix                 # Apply all safe fixes
npm run typecheck                 # TypeScript check
```
