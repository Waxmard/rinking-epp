import React, { useState, useEffect } from 'react';
import {
  View,
  Text,
  StyleSheet,
  FlatList,
  TouchableOpacity,
  ActivityIndicator,
  Image,
} from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';
import { Ionicons } from '@expo/vector-icons';
import { FAB, Card } from '../design-system/components';
import {
  AppColors,
  AppSpacing,
  AppTypography,
  AppBorders,
} from '../design-system/tokens';
import { AddItemModal } from '../components/AddItemModal';
import { Item } from '../services/itemsService';
import { listsService } from '../services/listsService';
import { useAuth } from '../providers/AuthContext';

interface ListDetailScreenProps {
  route: {
    params: {
      listId: string;
      listTitle: string;
      promptAddItem?: boolean;
    };
  };
  navigation: any;
}

export const ListDetailScreen: React.FC<ListDetailScreenProps> = ({
  route,
  navigation,
}) => {
  const { token } = useAuth();
  const { listId, listTitle, promptAddItem } = route.params;
  const [items, setItems] = useState<Item[]>([]);
  const [isLoading, setIsLoading] = useState(true);
  // Initialize modal state from promptAddItem param
  const [showAddModal, setShowAddModal] = useState(promptAddItem ?? false);

  useEffect(() => {
    const fetchItems = async () => {
      if (!token) return;
      try {
        setIsLoading(true);
        const fetchedItems = await listsService.getListItems(listId, token);
        setItems(fetchedItems);
      } catch (err) {
        console.error('Error fetching items:', err);
      } finally {
        setIsLoading(false);
      }
    };
    fetchItems();
  }, [listId, token]);

  const handleBack = () => {
    navigation.goBack();
  };

  const handleAddPress = () => {
    setShowAddModal(true);
  };

  const handleItemCreated = (item: Item) => {
    setItems((prev) => [...prev, item]);
  };

  const renderHeader = () => (
    <View style={styles.header}>
      <TouchableOpacity
        onPress={handleBack}
        style={styles.backButton}
        activeOpacity={0.7}
      >
        <Ionicons
          name="chevron-back"
          size={28}
          color={AppColors.secondary.emphasis}
        />
      </TouchableOpacity>
      <Text style={styles.headerTitle} numberOfLines={1}>
        {listTitle}
      </Text>
      <View style={styles.headerSpacer} />
    </View>
  );

  const renderEmptyState = () => (
    <View style={styles.emptyState}>
      <Image
        source={require('../../assets/logo-transparent.png')}
        style={styles.emptyStateImage}
      />
      <Text style={styles.emptyStateTitle}>No items yet</Text>
      <Text style={styles.emptyStateText}>
        Tap the + button to add your first item
      </Text>
    </View>
  );

  const renderItem = ({ item }: { item: Item }) => (
    <Card style={styles.itemCard}>
      <View style={styles.itemContent}>
        <Text style={styles.itemName}>{item.name}</Text>
        {item.tier && (
          <View style={styles.tierBadge}>
            <Text style={styles.tierBadgeText}>{item.tier}</Text>
          </View>
        )}
      </View>
      {item.description && (
        <Text style={styles.itemDescription} numberOfLines={2}>
          {item.description}
        </Text>
      )}
    </Card>
  );

  const renderContent = () => {
    if (isLoading) {
      return (
        <View style={styles.loadingState}>
          <ActivityIndicator size="large" color={AppColors.accent.primary} />
        </View>
      );
    }

    if (items.length === 0) {
      return renderEmptyState();
    }

    return (
      <FlatList
        data={items}
        renderItem={renderItem}
        keyExtractor={(item) => item.item_id}
        contentContainerStyle={styles.listContent}
        showsVerticalScrollIndicator={false}
      />
    );
  };

  return (
    <View style={styles.container}>
      <SafeAreaView style={styles.safeArea} edges={['top']}>
        {renderHeader()}
        {renderContent()}

        <FAB onPress={handleAddPress} />

        <AddItemModal
          visible={showAddModal}
          onClose={() => setShowAddModal(false)}
          onSuccess={handleItemCreated}
          listTitle={listTitle}
        />
      </SafeAreaView>
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: AppColors.dominant.secondary,
  },
  safeArea: {
    flex: 1,
  },
  header: {
    flexDirection: 'row',
    alignItems: 'center',
    paddingHorizontal: AppSpacing.md,
    paddingVertical: AppSpacing.md,
    borderBottomWidth: 1,
    borderBottomColor: AppColors.neutral[200],
    backgroundColor: AppColors.dominant.primary,
  },
  backButton: {
    width: 40,
    height: 40,
    alignItems: 'center',
    justifyContent: 'center',
    marginLeft: -AppSpacing.sm,
  },
  headerTitle: {
    ...AppTypography.headlineSmall,
    color: AppColors.secondary.emphasis,
    fontWeight: '600',
    flex: 1,
    textAlign: 'center',
    marginHorizontal: AppSpacing.sm,
  },
  headerSpacer: {
    width: 40,
  },
  listContent: {
    padding: AppSpacing.lg,
    paddingBottom: AppSpacing.xxxl + 56,
  },
  itemCard: {
    backgroundColor: AppColors.dominant.primary,
    borderRadius: AppBorders.radiusMd,
    padding: AppSpacing.md,
    marginBottom: AppSpacing.md,
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.08,
    shadowRadius: 4,
    elevation: 3,
  },
  itemContent: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between',
  },
  itemName: {
    ...AppTypography.bodyLarge,
    color: AppColors.secondary.emphasis,
    fontWeight: '600',
    flex: 1,
  },
  tierBadge: {
    backgroundColor: AppColors.accent.light,
    paddingHorizontal: AppSpacing.sm,
    paddingVertical: AppSpacing.xs,
    borderRadius: AppBorders.radiusSm,
    marginLeft: AppSpacing.sm,
  },
  tierBadgeText: {
    ...AppTypography.labelSmall,
    color: AppColors.accent.primary,
    fontWeight: '700',
  },
  itemDescription: {
    ...AppTypography.bodySmall,
    color: AppColors.textSecondary,
    marginTop: AppSpacing.xs,
  },
  emptyState: {
    flex: 1,
    alignItems: 'center',
    justifyContent: 'center',
    paddingHorizontal: AppSpacing.lg,
  },
  emptyStateImage: {
    width: 100,
    height: 100,
    opacity: 0.3,
    marginBottom: AppSpacing.lg,
  },
  emptyStateTitle: {
    ...AppTypography.headlineSmall,
    color: AppColors.secondary.emphasis,
    fontWeight: '600',
    marginBottom: AppSpacing.sm,
  },
  emptyStateText: {
    ...AppTypography.bodyMedium,
    color: AppColors.textSecondary,
    textAlign: 'center',
  },
  loadingState: {
    flex: 1,
    alignItems: 'center',
    justifyContent: 'center',
  },
});
