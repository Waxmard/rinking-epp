import React, { useEffect, useRef } from 'react';
import {
  View,
  Text,
  StyleSheet,
  FlatList,
  TouchableOpacity,
  Image,
  Animated,
  Dimensions,
} from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';
import { Ionicons } from '@expo/vector-icons';
import { useAuth } from '../providers/AuthContext';
import { Card, FAB } from '../design-system/components';
import {
  AppColors,
  AppSpacing,
  AppTypography,
  AppBorders,
} from '../design-system/tokens';
import {
  TierDistributionBar,
  TierDistribution,
} from '../components/TierDistributionBar';

const { width: SCREEN_WIDTH } = Dimensions.get('window');
const COLUMN_GAP = AppSpacing.md;
const HORIZONTAL_PADDING = AppSpacing.lg;
const CARD_WIDTH = (SCREEN_WIDTH - HORIZONTAL_PADDING * 2 - COLUMN_GAP) / 2;

interface TierList {
  id: string;
  title: string;
  itemCount: number;
  updatedAt: Date;
  tierDistribution: TierDistribution;
}

interface HomeScreenProps {
  navigation?: any;
}

// Mock data for tier lists
const MOCK_LISTS: TierList[] = [
  {
    id: '1',
    title: 'Best Programming Languages',
    itemCount: 15,
    updatedAt: new Date(),
    tierDistribution: { S: 2, A: 3, B: 4, C: 3, D: 2, F: 1 },
  },
  {
    id: '2',
    title: 'Marvel Movies',
    itemCount: 32,
    updatedAt: new Date(Date.now() - 86400000),
    tierDistribution: { S: 5, A: 8, B: 10, C: 6, D: 2, F: 1 },
  },
  {
    id: '3',
    title: 'Coffee Shops in NYC',
    itemCount: 8,
    updatedAt: new Date(Date.now() - 172800000),
    tierDistribution: { S: 1, A: 2, B: 3, C: 1, D: 1, F: 0 },
  },
  {
    id: '4',
    title: 'Favorite Albums of 2024',
    itemCount: 20,
    updatedAt: new Date(Date.now() - 259200000),
    tierDistribution: { S: 3, A: 5, B: 5, C: 4, D: 2, F: 1 },
  },
  {
    id: '5',
    title: 'Pizza Toppings',
    itemCount: 12,
    updatedAt: new Date(Date.now() - 604800000),
    tierDistribution: { S: 2, A: 3, B: 2, C: 2, D: 2, F: 1 },
  },
];

export const HomeScreen: React.FC<HomeScreenProps> = ({ navigation }) => {
  const { user } = useAuth();

  // Animation values
  const fadeAnim = useRef(new Animated.Value(0)).current;
  const scaleAnim = useRef(new Animated.Value(0.95)).current;

  useEffect(() => {
    Animated.parallel([
      Animated.timing(fadeAnim, {
        toValue: 1,
        duration: 800,
        useNativeDriver: true,
      }),
      Animated.spring(scaleAnim, {
        toValue: 1,
        friction: 8,
        tension: 40,
        useNativeDriver: true,
      }),
    ]).start();
  }, []);

  const formatDate = (date: Date): string => {
    const now = new Date();
    const difference = Math.floor(
      (now.getTime() - date.getTime()) / (1000 * 60 * 60 * 24)
    );

    if (difference === 0) return 'today';
    if (difference === 1) return 'yesterday';
    if (difference < 7) return `${difference} days ago`;
    return `${date.getMonth() + 1}/${date.getDate()}/${date.getFullYear()}`;
  };

  const handleProfilePress = () => {
    navigation.navigate('Profile');
  };

  const handleCreatePress = () => {
    console.log('Create new tier list');
  };

  const handleListPress = (listId: string) => {
    console.log('Navigate to list', listId);
  };

  const renderListCard = ({
    item,
    index,
  }: {
    item: TierList;
    index: number;
  }) => {
    const isLeftColumn = index % 2 === 0;

    return (
      <TouchableOpacity
        activeOpacity={0.8}
        onPress={() => handleListPress(item.id)}
        style={[
          styles.cardWrapper,
          isLeftColumn ? styles.cardLeft : styles.cardRight,
        ]}
      >
        <Card style={styles.listCard}>
          <Text style={styles.listTitle} numberOfLines={2}>
            {item.title}
          </Text>
          <Text style={styles.itemCount}>{item.itemCount} items</Text>
          <TierDistributionBar
            distribution={item.tierDistribution}
            style={styles.tierBar}
          />
          <Text style={styles.updatedAt}>
            Modified {formatDate(item.updatedAt)}
          </Text>
        </Card>
      </TouchableOpacity>
    );
  };

  const renderHeader = () => (
    <View style={styles.header}>
      <View style={styles.headerRow}>
        <View style={styles.brandSection}>
          <Image
            source={require('../../assets/logo-transparent.png')}
            style={styles.logo}
          />
          <Text style={styles.brandText}>TierNerd</Text>
        </View>

        <TouchableOpacity
          onPress={handleProfilePress}
          style={styles.profileButton}
          activeOpacity={0.7}
        >
          {user?.photoUrl ? (
            <Image
              source={{ uri: user.photoUrl }}
              style={styles.profileImage}
            />
          ) : (
            <View style={styles.profilePlaceholder}>
              <Ionicons
                name="person"
                size={20}
                color={AppColors.neutral[600]}
              />
            </View>
          )}
        </TouchableOpacity>
      </View>
    </View>
  );

  const renderSectionTitle = () => (
    <Text style={styles.sectionTitle}>Your Lists</Text>
  );

  const renderEmptyState = () => (
    <View style={styles.emptyState}>
      <Image
        source={require('../../assets/logo-transparent.png')}
        style={styles.emptyStateImage}
      />
      <Text style={styles.emptyStateTitle}>Welcome to TierNerd!</Text>
      <Text style={styles.emptyStateText}>
        Create your first tier list and start ranking your favorite things
      </Text>
    </View>
  );

  const lists = MOCK_LISTS; // Replace with actual data later

  return (
    <View style={styles.container}>
      <SafeAreaView style={styles.safeArea} edges={['top']}>
        <Animated.View
          style={[
            styles.animatedContainer,
            { opacity: fadeAnim, transform: [{ scale: scaleAnim }] },
          ]}
        >
          {renderHeader()}

          {lists.length > 0 ? (
            <>
              {renderSectionTitle()}
              <FlatList
                data={lists}
                renderItem={renderListCard}
                keyExtractor={(item) => item.id}
                numColumns={2}
                columnWrapperStyle={styles.row}
                contentContainerStyle={styles.listContent}
                showsVerticalScrollIndicator={false}
              />
            </>
          ) : (
            renderEmptyState()
          )}
        </Animated.View>

        <FAB onPress={handleCreatePress} />
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
  animatedContainer: {
    flex: 1,
  },
  header: {
    paddingHorizontal: HORIZONTAL_PADDING,
    paddingTop: AppSpacing.md,
    paddingBottom: AppSpacing.lg,
  },
  headerRow: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
  },
  brandSection: {
    flexDirection: 'row',
    alignItems: 'center',
  },
  logo: {
    width: 36,
    height: 36,
    marginRight: AppSpacing.sm,
  },
  brandText: {
    ...AppTypography.headlineMedium,
    color: AppColors.secondary.emphasis,
    fontWeight: '700',
  },
  profileButton: {
    width: 40,
    height: 40,
    borderRadius: 20,
    overflow: 'hidden',
    backgroundColor: AppColors.surface,
    borderWidth: 1,
    borderColor: AppColors.neutral[300],
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.1,
    shadowRadius: 4,
    elevation: 3,
  },
  profileImage: {
    width: '100%',
    height: '100%',
  },
  profilePlaceholder: {
    width: '100%',
    height: '100%',
    backgroundColor: AppColors.surface,
    alignItems: 'center',
    justifyContent: 'center',
  },
  sectionTitle: {
    ...AppTypography.titleMedium,
    color: AppColors.secondary.emphasis,
    fontWeight: '600',
    paddingHorizontal: HORIZONTAL_PADDING,
    marginBottom: AppSpacing.md,
  },
  listContent: {
    paddingHorizontal: HORIZONTAL_PADDING,
    paddingBottom: AppSpacing.xxxl + 56, // Extra space for FAB
  },
  row: {
    justifyContent: 'space-between',
  },
  cardWrapper: {
    width: CARD_WIDTH,
    marginBottom: COLUMN_GAP,
  },
  cardLeft: {
    marginRight: COLUMN_GAP / 2,
  },
  cardRight: {
    marginLeft: COLUMN_GAP / 2,
  },
  listCard: {
    backgroundColor: AppColors.dominant.primary,
    borderRadius: AppBorders.radiusMd,
    padding: AppSpacing.md,
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.08,
    shadowRadius: 4,
    elevation: 3,
  },
  listTitle: {
    ...AppTypography.bodyLarge,
    color: AppColors.secondary.emphasis,
    fontWeight: '600',
    marginBottom: AppSpacing.xs,
  },
  itemCount: {
    ...AppTypography.bodySmall,
    color: AppColors.textSecondary,
    marginBottom: AppSpacing.sm,
  },
  tierBar: {
    marginBottom: AppSpacing.sm,
  },
  updatedAt: {
    ...AppTypography.labelSmall,
    color: AppColors.neutral[400],
  },
  emptyState: {
    flex: 1,
    alignItems: 'center',
    justifyContent: 'center',
    paddingHorizontal: HORIZONTAL_PADDING,
  },
  emptyStateImage: {
    width: 120,
    height: 120,
    opacity: 0.3,
    marginBottom: AppSpacing.xl,
  },
  emptyStateTitle: {
    ...AppTypography.headlineMedium,
    color: AppColors.secondary.emphasis,
    fontWeight: '600',
    marginBottom: AppSpacing.sm,
  },
  emptyStateText: {
    ...AppTypography.bodyMedium,
    color: AppColors.textSecondary,
    textAlign: 'center',
    marginBottom: AppSpacing.xl,
  },
});
