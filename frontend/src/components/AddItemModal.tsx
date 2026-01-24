import React, { useState } from 'react';
import {
  View,
  Text,
  StyleSheet,
  Modal,
  KeyboardAvoidingView,
  Platform,
  TouchableWithoutFeedback,
  Keyboard,
  TouchableOpacity,
} from 'react-native';
import { Input, Button } from '../design-system/components';
import {
  AppColors,
  AppSpacing,
  AppTypography,
  AppBorders,
} from '../design-system/tokens';
import { useAuth } from '../providers/AuthContext';
import {
  itemsService,
  TierSet,
  Item,
  isComparisonSession,
} from '../services/itemsService';
import { ApiError } from '../services/api';

interface AddItemModalProps {
  visible: boolean;
  onClose: () => void;
  onSuccess: (item: Item) => void;
  listTitle: string;
}

interface TierOption {
  label: string;
  value: TierSet;
}

const TIER_OPTIONS: TierOption[] = [
  { label: 'Top tier (S/A)', value: 'good' },
  { label: 'Middle tier (B/C)', value: 'mid' },
  { label: 'Bottom tier (D/F)', value: 'bad' },
];

const MAX_NAME_LENGTH = 100;

export const AddItemModal: React.FC<AddItemModalProps> = ({
  visible,
  onClose,
  onSuccess,
  listTitle,
}) => {
  const { token } = useAuth();
  const [name, setName] = useState('');
  const [tierSet, setTierSet] = useState<TierSet | null>(null);
  const [description, setDescription] = useState('');
  const [isLoading, setIsLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);

  const resetForm = () => {
    setName('');
    setTierSet(null);
    setDescription('');
    setError(null);
  };

  const handleClose = () => {
    resetForm();
    onClose();
  };

  const handleCreate = async () => {
    const trimmedName = name.trim();

    if (!trimmedName) {
      setError('Name is required');
      return;
    }

    if (trimmedName.length > MAX_NAME_LENGTH) {
      setError(`Name must be ${MAX_NAME_LENGTH} characters or less`);
      return;
    }

    if (!tierSet) {
      setError('Please select a tier');
      return;
    }

    if (!token) {
      setError('Authentication required');
      return;
    }

    try {
      setIsLoading(true);
      setError(null);
      const response = await itemsService.createItem(
        listTitle,
        {
          name: trimmedName,
          tier_set: tierSet,
          description: description.trim() || undefined,
        },
        token
      );

      if (isComparisonSession(response)) {
        // TODO: Handle comparison session flow
        // For now, close the modal - comparison flow will be added later
        resetForm();
        onClose();
      } else {
        resetForm();
        onSuccess(response);
        onClose();
      }
    } catch (err) {
      if (err instanceof ApiError) {
        if (err.status === 409) {
          setError('An item with this name already exists in this list');
        } else if (err.data?.detail) {
          if (Array.isArray(err.data.detail)) {
            const messages = err.data.detail
              .map((e: { msg: string }) => e.msg)
              .join(', ');
            setError(messages || 'Validation error');
          } else if (typeof err.data.detail === 'string') {
            setError(err.data.detail);
          } else {
            setError('Failed to add item. Please try again.');
          }
        } else {
          setError('Failed to add item. Please try again.');
        }
      } else {
        setError('An unexpected error occurred');
      }
    } finally {
      setIsLoading(false);
    }
  };

  return (
    <Modal
      visible={visible}
      transparent
      animationType="fade"
      onRequestClose={handleClose}
    >
      <TouchableWithoutFeedback onPress={Keyboard.dismiss}>
        <View style={styles.overlay}>
          <KeyboardAvoidingView
            behavior={Platform.OS === 'ios' ? 'padding' : 'height'}
            style={styles.keyboardView}
          >
            <TouchableWithoutFeedback>
              <View style={styles.modal}>
                <Text style={styles.title}>Add Item</Text>

                <Input
                  label="Name"
                  placeholder="Enter item name"
                  value={name}
                  onChangeText={(text) => {
                    setName(text);
                    if (error) setError(null);
                  }}
                  maxLength={MAX_NAME_LENGTH}
                  autoFocus
                />

                <View style={styles.tierSection}>
                  <Text style={styles.tierLabel}>Tier</Text>
                  <View style={styles.tierOptions}>
                    {TIER_OPTIONS.map((option) => (
                      <TouchableOpacity
                        key={option.value}
                        style={[
                          styles.tierOption,
                          tierSet === option.value && styles.tierOptionSelected,
                        ]}
                        onPress={() => {
                          setTierSet(option.value);
                          if (error) setError(null);
                        }}
                        activeOpacity={0.7}
                      >
                        <Text
                          style={[
                            styles.tierOptionText,
                            tierSet === option.value &&
                              styles.tierOptionTextSelected,
                          ]}
                        >
                          {option.label}
                        </Text>
                      </TouchableOpacity>
                    ))}
                  </View>
                </View>

                <Input
                  label="Description (optional)"
                  placeholder="Add a description"
                  value={description}
                  onChangeText={setDescription}
                  multiline
                  numberOfLines={3}
                  inputStyle={styles.descriptionInput}
                />

                {error && <Text style={styles.error}>{error}</Text>}

                <View style={styles.buttonRow}>
                  <Button
                    title="Cancel"
                    variant="text"
                    onPress={handleClose}
                    disabled={isLoading}
                    style={styles.cancelButton}
                  />
                  <Button
                    title="Add"
                    onPress={handleCreate}
                    loading={isLoading}
                    disabled={!name.trim() || !tierSet}
                    style={styles.createButton}
                  />
                </View>
              </View>
            </TouchableWithoutFeedback>
          </KeyboardAvoidingView>
        </View>
      </TouchableWithoutFeedback>
    </Modal>
  );
};

const styles = StyleSheet.create({
  overlay: {
    flex: 1,
    backgroundColor: 'rgba(0, 0, 0, 0.5)',
    justifyContent: 'center',
    alignItems: 'center',
  },
  keyboardView: {
    width: '100%',
    alignItems: 'center',
    paddingHorizontal: AppSpacing.lg,
  },
  modal: {
    width: '100%',
    maxWidth: 400,
    backgroundColor: AppColors.dominant.primary,
    borderRadius: AppBorders.radiusLg,
    padding: AppSpacing.xl,
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 4 },
    shadowOpacity: 0.15,
    shadowRadius: 12,
    elevation: 8,
  },
  title: {
    ...AppTypography.headlineSmall,
    color: AppColors.secondary.emphasis,
    fontWeight: '600',
    marginBottom: AppSpacing.lg,
    textAlign: 'center',
  },
  tierSection: {
    marginBottom: AppSpacing.md,
  },
  tierLabel: {
    ...AppTypography.bodySmall,
    color: AppColors.secondary.emphasis,
    fontWeight: '500',
    marginBottom: AppSpacing.sm,
  },
  tierOptions: {
    gap: AppSpacing.xs,
  },
  tierOption: {
    paddingVertical: AppSpacing.sm,
    paddingHorizontal: AppSpacing.md,
    borderRadius: AppBorders.radiusSm,
    borderWidth: 1,
    borderColor: AppColors.neutral[300],
    backgroundColor: AppColors.surface,
  },
  tierOptionSelected: {
    borderColor: AppColors.accent.primary,
    backgroundColor: AppColors.accent.light,
  },
  tierOptionText: {
    ...AppTypography.bodyMedium,
    color: AppColors.textSecondary,
    textAlign: 'center',
  },
  tierOptionTextSelected: {
    color: AppColors.accent.primary,
    fontWeight: '600',
  },
  descriptionInput: {
    minHeight: 80,
    textAlignVertical: 'top',
  },
  error: {
    ...AppTypography.bodySmall,
    color: AppColors.error,
    marginBottom: AppSpacing.md,
  },
  buttonRow: {
    flexDirection: 'row',
    justifyContent: 'flex-end',
    gap: AppSpacing.sm,
    marginTop: AppSpacing.sm,
  },
  cancelButton: {
    minWidth: 80,
  },
  createButton: {
    minWidth: 100,
  },
});
