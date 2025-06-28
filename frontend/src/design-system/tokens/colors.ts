export const AppColors = {
  // Dominant colors (60% of the design)
  dominant: {
    primary: '#FFFFFF',    // Pure white - main backgrounds
    secondary: '#FAFAFA',  // Off-white - cards, elevated sections
  },
  
  // Secondary colors (30% of the design)
  secondary: {
    primary: '#2D2D2D',    // Dark gray - body text
    emphasis: '#1A1A1A',   // Near black - headers, important text
    muted: '#6B7280',      // Muted gray - secondary text
    light: '#9CA3AF',      // Light gray - disabled states
  },
  
  // Accent colors (10% of the design)
  accent: {
    primary: '#8B5CF6',    // Refined purple - buttons, links
    light: '#A78BFA',      // Light purple - hover states
    dark: '#7C3AED',       // Dark purple - pressed states
  },
  
  // Legacy mappings for compatibility
  primary: '#8B5CF6',
  primaryLight: '#A78BFA',
  primaryDark: '#7C3AED',
  
  // Text colors
  textPrimary: '#2D2D2D',
  textSecondary: '#6B7280',
  textOnPrimary: '#FFFFFF',
  
  // Surface colors
  surface: '#FFFFFF',
  surfaceLight: '#FAFAFA',
  surfaceDark: '#F3F4F6',
  
  // Semantic colors
  error: '#EF4444',
  success: '#10B981',
  warning: '#F59E0B',
  info: '#3B82F6',
  
  // Neutral colors
  neutral: {
    50: '#FAFAFA',
    100: '#F5F5F5',
    200: '#E5E7EB',
    300: '#D1D5DB',
    400: '#9CA3AF',
    500: '#6B7280',
    600: '#4B5563',
    700: '#374151',
    800: '#1F2937',
    900: '#111827',
  },
  
  // Tier colors - keeping these vibrant for ranking system
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

// Gradient definitions - using subtle gray gradients
export const AppGradients = {
  primary: ['#FFFFFF', '#FAFAFA'],
  accent: ['#8B5CF6', '#7C3AED'],
  subtle: ['#FAFAFA', '#F3F4F6'],
};