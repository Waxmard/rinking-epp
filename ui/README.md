# TierNerd Flutter UI

## Environment Setup

This project uses environment variables for configuration. To get started:

1. Copy the example environment file to create your own:
   ```
   cp .env.example .env
   ```

2. Update the `.env` file with your actual values:
   ```
   # Google OAuth
   GOOGLE_CLIENT_ID=your_google_client_id_here.apps.googleusercontent.com

   # API endpoints
   API_BASE_URL=https://api.tiernerd.com
   API_GOOGLE_AUTH_ENDPOINT=/auth/google

   # Environment (development, staging, production)
   ENV=development
   ```

3. Install dependencies:
   ```
   flutter pub get
   ```

4. Run the app:
   ```
   flutter run
   ```

## Features

TierNerd provides:
- User authentication and account management
- List creation and management
- Item addition with images and descriptions
- Intuitive comparison interface for ranking items
- Beautiful tier-based visualization (S, A, B, C, D, E, F tiers)
- Responsive design for mobile, tablet, and desktop

## Tier Visualization

TierNerd presents rankings in the familiar S-F tier system:
- **S Tier**: Exceptional items (colored in gold/yellow)
- **A Tier**: Excellent items (colored in green)
- **B Tier**: Good items (colored in light blue)
- **C Tier**: Average items (colored in blue)
- **D Tier**: Below average items (colored in purple)
- **E Tier**: Poor items (colored in red)
- **F Tier**: Lowest ranked items (colored in gray)
