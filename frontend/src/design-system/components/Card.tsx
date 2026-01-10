import React from 'react';
import { View, StyleSheet, ViewStyle } from 'react-native';
import { AppColors, AppSpacing, AppBorders } from '../tokens';

interface CardProps {
  children: React.ReactNode;
  variant?: 'elevated' | 'outlined' | 'filled';
  padding?: keyof typeof AppSpacing;
  style?: ViewStyle;
}

export const Card: React.FC<CardProps> = ({
  children,
  variant = 'elevated',
  padding = 'md',
  style,
}) => {
  const cardStyles = [
    styles.base,
    styles[variant],
    { padding: AppSpacing[padding] as number },
    style,
  ];

  return <View style={cardStyles}>{children}</View>;
};

const styles = StyleSheet.create({
  base: {
    borderRadius: AppBorders.radiusMd,
    backgroundColor: AppColors.dominant.secondary,
  },
  elevated: {
    backgroundColor: AppColors.dominant.secondary,
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.05,
    shadowRadius: 4,
    elevation: 2,
  },
  outlined: {
    backgroundColor: AppColors.dominant.primary,
    borderWidth: 1,
    borderColor: AppColors.neutral[200],
  },
  filled: {
    backgroundColor: AppColors.dominant.secondary,
  },
});
