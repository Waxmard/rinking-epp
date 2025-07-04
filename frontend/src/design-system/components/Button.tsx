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
    variant === 'text' ? styles.textVariant : styles[variant],
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
      onPress={() => {
        console.log('Button pressed:', title); // Debug log
        onPress();
      }}
      disabled={disabled || loading}
      activeOpacity={0.8}
      hitSlop={{ top: 10, bottom: 10, left: 10, right: 10 }}
      delayPressIn={0}
      delayPressOut={0}
    >
      {loading ? (
        <ActivityIndicator
          color={variant === 'primary' ? AppColors.textOnPrimary : AppColors.accent.primary}
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
    backgroundColor: AppColors.accent.primary,
  },
  secondary: {
    backgroundColor: 'transparent',
    borderWidth: 1,
    borderColor: AppColors.accent.primary,
  },
  textVariant: {
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
    color: AppColors.accent.primary,
  },
  textText: {
    color: AppColors.accent.primary,
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