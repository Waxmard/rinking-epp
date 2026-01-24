import React from 'react';
import { TouchableOpacity, StyleSheet, ViewStyle } from 'react-native';
import { Ionicons } from '@expo/vector-icons';
import { AppColors, AppSpacing } from '../tokens';

interface FABProps {
  onPress: () => void;
  icon?: keyof typeof Ionicons.glyphMap;
  style?: ViewStyle;
  disabled?: boolean;
}

export const FAB: React.FC<FABProps> = ({
  onPress,
  icon = 'add',
  style,
  disabled = false,
}) => {
  return (
    <TouchableOpacity
      style={[styles.fab, disabled && styles.disabled, style]}
      onPress={onPress}
      disabled={disabled}
      activeOpacity={0.8}
    >
      <Ionicons name={icon} size={28} color={AppColors.textOnPrimary} />
    </TouchableOpacity>
  );
};

const styles = StyleSheet.create({
  fab: {
    position: 'absolute',
    bottom: AppSpacing.xl,
    right: AppSpacing.lg,
    width: 56,
    height: 56,
    borderRadius: 28,
    backgroundColor: AppColors.accent.primary,
    alignItems: 'center',
    justifyContent: 'center',
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 4 },
    shadowOpacity: 0.2,
    shadowRadius: 8,
    elevation: 8,
  },
  disabled: {
    opacity: 0.5,
  },
});
