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
    { padding: AppSpacing[padding] },
    style,
  ];

  return <View style={cardStyles}>{children}</View>;
};

const styles = StyleSheet.create({
  base: {
    borderRadius: AppBorders.radiusMd,
    backgroundColor: AppColors.surface,
  },
  elevated: {
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.1,
    shadowRadius: 4,
    elevation: 3,
  },
  outlined: {
    borderWidth: 1,
    borderColor: AppColors.neutral[300],
  },
  filled: {
    backgroundColor: AppColors.surfaceLight,
  },
});