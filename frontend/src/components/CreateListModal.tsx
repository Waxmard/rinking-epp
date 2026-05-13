import React, { useState } from 'react';
import { StyleSheet, Modal } from 'react-native';
import { Input, BaseModalContent } from '../design-system/components';
import { useAuth } from '../providers/AuthContext';
import { listsService } from '../services/listsService';
import { ApiError } from '../services/api';

export interface CreatedList {
  listId: string;
  title: string;
}

interface CreateListContentProps {
  onClose: () => void;
  onSuccess: (list: CreatedList) => void;
}

interface CreateListModalProps extends CreateListContentProps {
  visible: boolean;
}

const MAX_TITLE_LENGTH = 100;

// Content component without Modal wrapper (for use in parent-controlled Modal)
export const CreateListContent: React.FC<CreateListContentProps> = ({
  onClose,
  onSuccess,
}) => {
  const { token } = useAuth();
  const [title, setTitle] = useState('');
  const [description, setDescription] = useState('');
  const [isLoading, setIsLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);

  const resetForm = () => {
    setTitle('');
    setDescription('');
    setError(null);
  };

  const handleClose = () => {
    resetForm();
    onClose();
  };

  const handleCreate = async () => {
    const trimmedTitle = title.trim();

    if (!trimmedTitle) {
      setError('Title is required');
      return;
    }

    if (trimmedTitle.length > MAX_TITLE_LENGTH) {
      setError(`Title must be ${MAX_TITLE_LENGTH} characters or less`);
      return;
    }

    if (!token) {
      setError('Authentication required');
      return;
    }

    try {
      setIsLoading(true);
      setError(null);
      const createdList = await listsService.createList(
        trimmedTitle,
        description.trim(),
        token
      );
      resetForm();
      onSuccess({ listId: createdList.list_id, title: createdList.title });
      // Parent will close the modal when AddItem flow completes
    } catch (err) {
      if (err instanceof ApiError) {
        if (err.status === 409) {
          setError('A list with this title already exists');
        } else if (err.data?.detail) {
          // Handle FastAPI validation errors (array of objects)
          if (Array.isArray(err.data.detail)) {
            const messages = err.data.detail
              .map((e: { msg: string }) => e.msg)
              .join(', ');
            setError(messages || 'Validation error');
          } else if (typeof err.data.detail === 'string') {
            setError(err.data.detail);
          } else {
            setError('Failed to create list. Please try again.');
          }
        } else {
          setError('Failed to create list. Please try again.');
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
      title="Create New List"
      error={error}
      isLoading={isLoading}
      submitText="Create"
      submitDisabled={!title.trim()}
      onClose={handleClose}
      onSubmit={handleCreate}
    >
      <Input
        label="Title"
        placeholder="Enter list title"
        value={title}
        onChangeText={(text) => {
          setTitle(text);
          if (error) setError(null);
        }}
        maxLength={MAX_TITLE_LENGTH}
        autoFocus
      />

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
export const CreateListModal: React.FC<CreateListModalProps> = ({
  visible,
  onClose,
  onSuccess,
}) => (
  <Modal
    visible={visible}
    transparent
    animationType="fade"
    onRequestClose={onClose}
  >
    <CreateListContent onClose={onClose} onSuccess={onSuccess} />
  </Modal>
);

const styles = StyleSheet.create({
  descriptionInput: {
    minHeight: 80,
    textAlignVertical: 'top',
  },
});
