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

## Troubleshooting

### iOS Simulator Build Fails
If you see "Unable to find destination" errors:
1. Ensure your Xcode version matches your iOS Simulator version
2. Regenerate the iOS project:
   ```bash
   rm -rf ios && npx expo prebuild --platform ios
   ```

### Expo Go Version Mismatch
If Expo Go shows "Project incompatible with this version":
- The app requires SDK 54 - update Expo Go from the App Store

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

## Type Checking

```bash
npx tsc --noEmit
```
