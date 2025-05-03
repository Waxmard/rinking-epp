# Flutter Project Setup

This Flutter project is set up with the following libraries and frameworks:

## UI Components
- **GetWidget (GF)**: Pre-built UI components library (v6.0.0)
  - Includes GFButton, GFCard, and other components

## State Management
- **Provider**: Lightweight state management solution (v6.1.1)
  - Set up with CounterProvider for demo purposes

## Responsive Design
- **Responsive Framework**: Handles adaptive UI across different screen sizes (v1.1.1)
  - Configured with breakpoints for MOBILE, TABLET, DESKTOP, and 4K
  - Includes ResponsiveHelper utility class for consistent responsive behavior

## Directory Structure
- `lib/`
  - `providers/`: State management providers
  - `utils/`: Utility classes including ResponsiveHelper
  - `main.dart`: Entry point with responsive configuration

## Usage Examples
- Counter app example demonstrates:
  - Provider state management
  - GetWidget components
  - Responsive layout with different designs for mobile/tablet/desktop

## Getting Started
1. Install dependencies: `flutter pub get`
2. Run the app: `flutter run`

## Best Practices
- Use ResponsiveHelper for consistent responsive behavior
- Follow Provider pattern for state management
- Leverage GetWidget components for rapid UI development