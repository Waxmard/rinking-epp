import React, { useState, useEffect } from 'react';
import { View, Text, StyleSheet, Modal, TouchableOpacity } from 'react-native';
import { Input, BaseModalContent } from '../design-system/components';
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

interface AddItemContentProps {
  onClose: () => void;
  onSuccess: (item: Item) => void;
  listTitle: string;
  editingItem?: Item;
}

interface AddItemModalProps extends AddItemContentProps {
  visible: boolean;
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

// Content component without Modal wrapper (for use in parent-controlled Modal)
export const AddItemContent: React.FC<AddItemContentProps> = ({
  onClose,
  onSuccess,
  listTitle,
  editingItem,
}) => {
  const { token } = useAuth();
  const [name, setName] = useState('');
  const [tierSet, setTierSet] = useState<TierSet | null>(null);
  const [description, setDescription] = useState('');
  const [isLoading, setIsLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);

  const isEditMode = !!editingItem;

  // Pre-fill form when editing
  useEffect(() => {
    if (editingItem) {
      setName(editingItem.name);
      setDescription(editingItem.description ?? '');
    }
  }, [editingItem]);

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

  const handleSubmit = async () => {
    const trimmedName = name.trim();

    if (!trimmedName) {
      setError('Name is required');
      return;
    }

    if (trimmedName.length > MAX_NAME_LENGTH) {
      setError(`Name must be ${MAX_NAME_LENGTH} characters or less`);
      return;
    }

    if (!isEditMode && !tierSet) {
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

      if (isEditMode && editingItem) {
        const updatedItem = await itemsService.updateItem(
          editingItem.item_id,
          {
            name: trimmedName,
            description: description.trim() || undefined,
          },
          token
        );
        resetForm();
        onSuccess(updatedItem);
      } else {
        const response = await itemsService.createItem(
          listTitle,
          {
            name: trimmedName,
            tier_set: tierSet!,
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
        }
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
            setError(
              isEditMode
                ? 'Failed to update item. Please try again.'
                : 'Failed to add item. Please try again.'
            );
          }
        } else {
          setError(
            isEditMode
              ? 'Failed to update item. Please try again.'
              : 'Failed to add item. Please try again.'
          );
        }
      } else {
        setError('An unexpected error occurred');
      }
    } finally {
      setIsLoading(false);
    }
  };

  return (
    <BaseModalContent
      title={isEditMode ? 'Edit Item' : 'Add Item'}
      error={error}
      isLoading={isLoading}
      submitText={isEditMode ? 'Save' : 'Add'}
      submitDisabled={!name.trim() || (!isEditMode && !tierSet)}
      onClose={handleClose}
      onSubmit={handleSubmit}
    >
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

      {!isEditMode && (
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
                    tierSet === option.value && styles.tierOptionTextSelected,
                  ]}
                >
                  {option.label}
                </Text>
              </TouchableOpacity>
            ))}
          </View>
        </View>
      )}

      <Input
        label="Description (optional)"
        placeholder="Add a description"
        value={description}
        onChangeText={setDescription}
        multiline
        numberOfLines={3}
        inputStyle={styles.descriptionInput}
      />
    </BaseModalContent>
  );
};

// Full modal component (wraps content in Modal for backward compatibility)
export const AddItemModal: React.FC<AddItemModalProps> = ({
  visible,
  onClose,
  onSuccess,
  listTitle,
  editingItem,
}) => (
  <Modal
    visible={visible}
    transparent
    animationType="fade"
    onRequestClose={onClose}
  >
    <AddItemContent
      onClose={onClose}
      onSuccess={onSuccess}
      listTitle={listTitle}
      editingItem={editingItem}
    />
  </Modal>
);

const styles = StyleSheet.create({
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
});
