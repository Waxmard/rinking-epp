#!/bin/bash

echo "🔍 Checking TypeScript compilation..."
npx tsc --noEmit

echo ""
echo "🔍 Checking for Expo compatibility..."
npx expo doctor

echo ""
echo "✅ All checks complete!"
