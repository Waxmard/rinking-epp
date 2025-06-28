import React from 'react';
import {
  TouchableOpacity,
  Text,
  StyleSheet,
  ViewStyle,
  TextStyle,
  ActivityIndicator,
  View,
} from 'react-native';
import { AppColors, AppSpacing, AppTypography, AppBorders } from '../tokens';

interface ButtonProps {
  title: string;
  onPress: () => void;
  variant?: 'primary' | 'secondary' | 'text';
  size?: 'small' | 'medium' | 'large';
  fullWidth?: boolean;
  disabled?: boolean;
  loading?: boolean;
  icon?: React.ReactNode;
  style?: ViewStyle;
  textStyle?: TextStyle;
}

export const Button: React.FC<ButtonProps> = ({
  title,
  onPress,
  variant = 'primary',
  size = 'medium',
  fullWidth = false,
  disabled = false,
  loading = false,
  icon,
  style,
  textStyle,
}) => {
  const buttonStyles = [
    styles.base,
    styles[variant],
    styles[size],
    fullWidth && styles.fullWidth,
    disabled && styles.disabled,
    style,
  ];

  const textStyles = [
    styles.text,
    styles[`${variant}Text`],
    styles[`${size}Text`],
    disabled && styles.disabledText,
    textStyle,
  ];

  return (
    <TouchableOpacity
      style={buttonStyles}
      onPress={onPress}
      disabled={disabled || loading}
      activeOpacity={0.8}
      hitSlop={{ top: 8, bottom: 8, left: 8, right: 8 }}
    >
      {loading ? (
        <ActivityIndicator
          color={variant === 'primary' ? AppColors.textOnPrimary : AppColors.primary}
          size="small"
        />
      ) : (
        <View style={styles.content}>
          {icon && <View style={styles.icon}>{icon}</View>}
          <Text style={textStyles}>{title}</Text>
        </View>
      )}
    </TouchableOpacity>
  );
};

const styles = StyleSheet.create({
  base: {
    borderRadius: AppBorders.radiusMd,
    alignItems: 'center',
    justifyContent: 'center',
    flexDirection: 'row',
  },
  content: {
    flexDirection: 'row',
    alignItems: 'center',
  },
  icon: {
    marginRight: AppSpacing.sm,
  },
  
  // Variants
  primary: {
    backgroundColor: AppColors.primary,
  },
  secondary: {
    backgroundColor: 'transparent',
    borderWidth: 1,
    borderColor: AppColors.primary,
  },
  text: {
    backgroundColor: 'transparent',
  },
  
  // Sizes
  small: {
    paddingHorizontal: AppSpacing.md,
    paddingVertical: AppSpacing.sm,
    minHeight: 36,
  },
  medium: {
    paddingHorizontal: AppSpacing.lg,
    paddingVertical: AppSpacing.md,
    minHeight: 48,
  },
  large: {
    paddingHorizontal: AppSpacing.xl,
    paddingVertical: AppSpacing.lg,
    minHeight: 56,
  },
  
  // States
  fullWidth: {
    width: '100%',
  },
  disabled: {
    opacity: 0.5,
  },
  
  // Text styles
  text: {
    ...AppTypography.labelLarge,
    fontWeight: '600',
  },
  primaryText: {
    color: AppColors.textOnPrimary,
  },
  secondaryText: {
    color: AppColors.primary,
  },
  textText: {
    color: AppColors.primary,
  },
  
  // Text sizes
  smallText: {
    fontSize: 14,
  },
  mediumText: {
    fontSize: 16,
  },
  largeText: {
    fontSize: 18,
  },
  
  disabledText: {
    opacity: 0.7,
  },
});