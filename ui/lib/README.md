# TierNerd Flutter UI

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

## TierNerd Features
- The TierNerd UI provides:
  - User authentication and account management
  - List creation and management
  - Item addition with images and descriptions
  - Intuitive comparison interface for ranking items
  - Beautiful tier-based visualization (S, A, B, C, D, F tiers)
  - Responsive design for mobile, tablet, and desktop

## Tier Visualization
TierNerd presents rankings in the familiar S-F tier system:
- **S Tier**: Exceptional items (colored in gold/yellow)
- **A Tier**: Excellent items (colored in green)
- **B Tier**: Good items (colored in light blue)
- **C Tier**: Average items (colored in blue)
- **D Tier**: Below average items (colored in purple)
- **F Tier**: Lowest ranked items (colored in gray)

## Getting Started
1. Install dependencies: `flutter pub get`
2. Run the app: `flutter run`

## Best Practices
- Use ResponsiveHelper for consistent responsive behavior
- Follow Provider pattern for state management
- Leverage GetWidget components for rapid UI development
