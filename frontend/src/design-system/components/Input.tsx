import React, { useState } from 'react';
import {
  View,
  TextInput,
  Text,
  StyleSheet,
  ViewStyle,
  TextInputProps,
  TouchableOpacity,
} from 'react-native';
import { AppColors, AppSpacing, AppTypography, AppBorders } from '../tokens';

interface InputProps extends TextInputProps {
  label?: string;
  error?: string;
  leftIcon?: React.ReactNode;
  rightIcon?: React.ReactNode;
  containerStyle?: ViewStyle;
  inputStyle?: ViewStyle;
  onRightIconPress?: () => void;
}

export const Input: React.FC<InputProps> = ({
  label,
  error,
  leftIcon,
  rightIcon,
  containerStyle,
  inputStyle,
  onRightIconPress,
  onFocus,
  onBlur,
  ...textInputProps
}) => {
  const [isFocused, setIsFocused] = useState(false);

  const handleFocus = (e: any) => {
    console.log('Input focused'); // Debug log
    setIsFocused(true);
    onFocus?.(e);
  };

  const handleBlur = (e: any) => {
    console.log('Input blurred'); // Debug log
    setIsFocused(false);
    onBlur?.(e);
  };

  return (
    <View style={[styles.container, containerStyle]}>
      {label && <Text style={styles.label}>{label}</Text>}
      <View
        style={[
          styles.inputContainer,
          isFocused && styles.inputContainerFocused,
          error && styles.inputContainerError,
        ]}
        collapsable={false}
      >
        {leftIcon && <View style={styles.leftIcon}>{leftIcon}</View>}
        <TextInput
          style={[styles.input, inputStyle]}
          placeholderTextColor={AppColors.secondary.light}
          onFocus={handleFocus}
          onBlur={handleBlur}
          {...textInputProps}
        />
        {rightIcon && (
          <TouchableOpacity
            onPress={onRightIconPress}
            style={styles.rightIcon}
            disabled={!onRightIconPress}
          >
            {rightIcon}
          </TouchableOpacity>
        )}
      </View>
      {error && <Text style={styles.error}>{error}</Text>}
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    marginBottom: AppSpacing.md,
  },
  label: {
    ...AppTypography.labelMedium,
    color: AppColors.secondary.primary,
    marginBottom: AppSpacing.xs,
  },
  inputContainer: {
    flexDirection: 'row',
    alignItems: 'flex-start',
    borderWidth: 1,
    borderColor: AppColors.neutral[200],
    borderRadius: AppBorders.radiusMd,
    backgroundColor: AppColors.dominant.primary,
    paddingHorizontal: AppSpacing.md,
    paddingVertical: AppSpacing.md,
  },
  inputContainerFocused: {
    borderColor: AppColors.accent.primary,
    borderWidth: 2,
  },
  inputContainerError: {
    borderColor: AppColors.error,
  },
  input: {
    flex: 1,
    ...AppTypography.bodyLarge,
    color: AppColors.secondary.primary,
    padding: 0,
    margin: 0,
    marginTop: -2, // Shift text up to align with icon visual center
    includeFontPadding: false,
    textAlignVertical: 'top',
  },
  leftIcon: {
    marginRight: AppSpacing.sm,
    height: 24, // Match line height of bodyLarge
    justifyContent: 'center',
  },
  rightIcon: {
    marginLeft: AppSpacing.sm,
    height: 24, // Match line height of bodyLarge
    justifyContent: 'center',
  },
  error: {
    ...AppTypography.bodySmall,
    color: AppColors.error,
    marginTop: AppSpacing.xs,
  },
});