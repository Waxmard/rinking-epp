import { Platform } from 'react-native';

// Create shadow objects directly without Platform.select for now
const createShadow = (
  offset: { width: number; height: number },
  opacity: number,
  radius: number,
  elevation: number
) => {
  if (Platform.OS === 'ios') {
    return {
      shadowColor: '#000',
      shadowOffset: offset,
      shadowOpacity: opacity,
      shadowRadius: radius,
    };
  } else {
    return {
      elevation,
    };
  }
};

export const AppShadows = {
  // Small shadow
  sm: createShadow({ width: 0, height: 1 }, 0.18, 1.0, 1),

  // Medium shadow
  md: createShadow({ width: 0, height: 2 }, 0.2, 2.5, 3),

  // Large shadow
  lg: createShadow({ width: 0, height: 4 }, 0.25, 5, 6),

  // Extra large shadow
  xl: createShadow({ width: 0, height: 8 }, 0.3, 10, 10),
};
