export const AppColors = {
  // Dominant colors (60% of the design)
  dominant: {
    primary: '#FFFFFF', // Pure white - main backgrounds
    secondary: '#FAFAFA', // Off-white - cards, elevated sections
  },

  // Secondary colors (30% of the design)
  secondary: {
    primary: '#2D2D2D', // Dark gray - body text
    emphasis: '#1A1A1A', // Near black - headers, important text
    muted: '#6B7280', // Muted gray - secondary text
    light: '#9CA3AF', // Light gray - disabled states
  },

  // Accent colors (10% of the design)
  accent: {
    primary: '#8B5CF6', // Refined purple - buttons, links
    light: '#A78BFA', // Light purple - hover states
    dark: '#7C3AED', // Dark purple - pressed states
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

  // Tier colors - monochrome purple gradient (dark = best, light = worst)
  tierColors: {
    S: '#4C1D95', // Deep purple - elite/premium feel
    A: '#5B21B6', // Dark purple
    B: '#7C3AED', // Purple - matches accent.dark
    C: '#8B5CF6', // Medium purple - matches accent.primary
    D: '#A78BFA', // Light purple - matches accent.light
    F: '#C4B5FD', // Lavender - washed out for lowest tier
  },

  // Get tier color helper
  getTierColor: (tier: string): string => {
    return (
      AppColors.tierColors[tier as keyof typeof AppColors.tierColors] ||
      AppColors.neutral[500]
    );
  },
};

// Gradient definitions - using subtle gray gradients
export const AppGradients = {
  primary: ['#FFFFFF', '#FAFAFA'],
  accent: ['#8B5CF6', '#7C3AED'],
  subtle: ['#FAFAFA', '#F3F4F6'],
};
