export const AppColors = {
  // Primary colors - matching Flutter's primary color
  primary: '#6C63FF',
  primaryLight: '#9A93FF',
  primaryDark: '#3F37C9',
  
  // Text colors
  textPrimary: '#212121',
  textSecondary: '#757575',
  textOnPrimary: '#FFFFFF',
  
  // Surface colors
  surface: '#FFFFFF',
  surfaceLight: '#F5F5F5',
  surfaceDark: '#E0E0E0',
  
  // Semantic colors
  error: '#F44336',
  success: '#4CAF50',
  warning: '#FF9800',
  info: '#2196F3',
  
  // Neutral colors
  neutral: {
    50: '#FAFAFA',
    100: '#F5F5F5',
    200: '#EEEEEE',
    300: '#E0E0E0',
    400: '#BDBDBD',
    500: '#9E9E9E',
    600: '#757575',
    700: '#616161',
    800: '#424242',
    900: '#212121',
  },
  
  // Tier colors - matching your Flutter tier system
  tierColors: {
    S: '#FFD700', // Gold
    A: '#4CAF50', // Green
    B: '#2196F3', // Blue
    C: '#9C27B0', // Purple
    D: '#FF9800', // Orange
    F: '#9E9E9E', // Gray
  },
  
  // Get tier color helper
  getTierColor: (tier: string): string => {
    return AppColors.tierColors[tier as keyof typeof AppColors.tierColors] || AppColors.neutral[500];
  }
};

// Gradient definitions
export const AppGradients = {
  primary: ['#6C63FF', '#5A52E0'],
};