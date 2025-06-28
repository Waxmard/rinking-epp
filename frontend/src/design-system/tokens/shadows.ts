import { Platform } from 'react-native';

export const AppShadows = {
  // Small shadow
  sm: Platform.select({
    ios: {
      shadowColor: '#000',
      shadowOffset: { width: 0, height: 1 },
      shadowOpacity: 0.18,
      shadowRadius: 1.0,
    },
    android: {
      elevation: 1,
    },
  }),
  
  // Medium shadow
  md: Platform.select({
    ios: {
      shadowColor: '#000',
      shadowOffset: { width: 0, height: 2 },
      shadowOpacity: 0.20,
      shadowRadius: 2.5,
    },
    android: {
      elevation: 3,
    },
  }),
  
  // Large shadow
  lg: Platform.select({
    ios: {
      shadowColor: '#000',
      shadowOffset: { width: 0, height: 4 },
      shadowOpacity: 0.25,
      shadowRadius: 5,
    },
    android: {
      elevation: 6,
    },
  }),
  
  // Extra large shadow
  xl: Platform.select({
    ios: {
      shadowColor: '#000',
      shadowOffset: { width: 0, height: 8 },
      shadowOpacity: 0.30,
      shadowRadius: 10,
    },
    android: {
      elevation: 10,
    },
  }),
};