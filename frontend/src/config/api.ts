// API Configuration

// Base URL for the backend API
// In development, points to local Docker container
// In production, should point to deployed backend
export const API_BASE_URL = __DEV__
  ? 'http://localhost:8000'
  : 'https://your-production-url.com';

// Set EXPO_PUBLIC_USE_MOCK_AUTH=true to use mock auth instead of real backend
// Useful for frontend development without running the backend
export const USE_MOCK_AUTH = process.env.EXPO_PUBLIC_USE_MOCK_AUTH === 'true';
