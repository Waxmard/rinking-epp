<!-- Generated from docs/src. Run `make docs-build` to update. Do not edit directly. -->

# TierNerd Frontend

React Native mobile app built with Expo SDK 54.

## Prerequisites

- Node.js 18+
- npm
- Xcode (for iOS Simulator)
- Expo Go app (for physical device testing)

## Setup

```bash
npm install --legacy-peer-deps
```

Note: `--legacy-peer-deps` is required due to React 19 peer dependency conflicts.

## Running the App

### Option 1: Expo Go (Physical Device)

```bash
npx expo start
```

Scan the QR code with Expo Go on your iPhone/Android.

### Option 2: iOS Simulator

```bash
npm run ios
```

### Option 3: Android Emulator

```bash
npm run android
```

### Option 4: Web

```bash
npm run web
```

### Frontend (frontend/)

```bash
cd frontend
npm install                       # Install dependencies
npm run ios                       # Run on iOS simulator
npm run android                   # Run on Android emulator
npm run web                       # Run web version

# Code quality
npm run lint                      # Run ESLint
npm run lint:fix                  # Fix ESLint errors
npm run format                    # Format with Prettier
npm run format:check              # Check formatting
npm run typecheck                 # TypeScript check
```

## Troubleshooting

### iOS Simulator Build Fails

If you see "Unable to find destination" errors:

1. Ensure your Xcode version matches your iOS Simulator version
2. Regenerate the iOS project:

   ```bash
   rm -rf ios && npx expo prebuild --platform ios
   ```

### Expo Go Version Mismatch

If Expo Go shows "Project incompatible with this version" — the app requires SDK 54. Update Expo Go from the App Store.

### CocoaPods / Reanimated Errors

If `pod install` fails with reanimated worklets errors:

```bash
npx expo install react-native-worklets -- --legacy-peer-deps
rm -rf ios && npx expo prebuild --platform ios
```

## Project Structure

```
src/
├── screens/          # Screen components
├── navigation/       # React Navigation setup
├── providers/        # Context providers (Auth)
└── design-system/    # Reusable components and tokens
```

## Documentation Automation

`README.md`, `CLAUDE.md`, `AGENTS.md`, `fastapi/README.md`, and `frontend/README.md` are **generated** from templates in `docs/src/` by `scripts/build_docs.py`. Do not edit the generated files directly — edit the template or partial and re-render.

```bash
make docs-build    # render templates → generated files
make docs-check    # CI check: fail if generated docs are stale
```

Partials live in `docs/src/partials/` and are included with double-brace `include:partials/<name>.md` directives. `CLAUDE.md` and `AGENTS.md` share a single template (`docs/src/CLAUDE.md`) and are rendered to both paths.
