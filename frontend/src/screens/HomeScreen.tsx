import React, { useState, useEffect, useRef } from 'react';
import {
  View,
  Text,
  StyleSheet,
  ScrollView,
  TouchableOpacity,
  Image,
  Animated,
} from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';
import { Ionicons } from '@expo/vector-icons';
import { useAuth } from '../providers/AuthContext';
import { Card, Button } from '../design-system/components';
import {
  AppColors,
  AppSpacing,
  AppTypography,
  AppBorders,
} from '../design-system/tokens';

// Temporary inline shadows to fix import issue
const AppShadows = {
  md: {
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.1,
    shadowRadius: 4,
    elevation: 3,
  },
  lg: {
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 4 },
    shadowOpacity: 0.1,
    shadowRadius: 8,
    elevation: 6,
  },
};

interface RecentList {
  id: string;
  title: string;
  itemCount: number;
  updatedAt: Date;
}

interface UserStats {
  totalLists: number;
  totalItems: number;
  mostUsedTier: string;
}

interface HomeScreenProps {
  navigation?: any;
}

export const HomeScreen: React.FC<HomeScreenProps> = ({ navigation }) => {
  const { user } = useAuth();

  // Animation values
  const fadeAnim = useRef(new Animated.Value(0)).current;
  const scaleAnim = useRef(new Animated.Value(0.95)).current;

  // Mock data for recent lists (showing up to 3)
  const [recentLists] = useState<RecentList[]>([
    {
      id: '1',
      title: 'Best Programming Languages',
      itemCount: 15,
      updatedAt: new Date(),
    },
  ]);

  // Mock user stats
  const [userStats] = useState<UserStats>({
    totalLists: 1,
    totalItems: 15,
    mostUsedTier: 'A',
  });

  useEffect(() => {
    // Start animations
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

  return (
    <View style={styles.container}>
      <SafeAreaView style={styles.safeArea}>
        <ScrollView
          contentContainerStyle={styles.scrollContent}
          showsVerticalScrollIndicator={false}
        >
          <Animated.View
            style={{ opacity: fadeAnim, transform: [{ scale: scaleAnim }] }}
          >
            {/* Header */}
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

            {/* Hero Section */}
            <View style={styles.heroSection}>
              <Button
                title="Create New Tier List"
                onPress={handleCreatePress}
                fullWidth
                style={styles.createButton}
                icon={
                  <Ionicons
                    name="add-circle-outline"
                    size={24}
                    color={AppColors.textOnPrimary}
                  />
                }
              />
            </View>

            {recentLists.length > 0 ? (
              <>
                {/* Quick Stats */}
                <Card style={styles.statsCard}>
                  <View style={styles.statsRow}>
                    <View style={styles.statItem}>
                      <Text style={styles.statValue}>
                        {userStats.totalLists}
                      </Text>
                      <Text style={styles.statLabel}>Lists</Text>
                    </View>
                    <View style={styles.statDivider} />
                    <View style={styles.statItem}>
                      <Text style={styles.statValue}>
                        {userStats.totalItems}
                      </Text>
                      <Text style={styles.statLabel}>Items</Text>
                    </View>
                    <View style={styles.statDivider} />
                    <View style={styles.statItem}>
                      <View
                        style={[
                          styles.tierBadge,
                          {
                            backgroundColor:
                              AppColors.tierColors[
                                userStats.mostUsedTier as keyof typeof AppColors.tierColors
                              ],
                          },
                        ]}
                      >
                        <Text style={styles.tierBadgeText}>
                          {userStats.mostUsedTier}
                        </Text>
                      </View>
                      <Text style={styles.statLabel}>Top Tier</Text>
                    </View>
                  </View>
                </Card>

                {/* Recent Lists */}
                <View style={styles.recentSection}>
                  <Text style={styles.sectionTitle}>Recent Lists</Text>
                  {recentLists.map((list) => (
                    <TouchableOpacity
                      key={list.id}
                      activeOpacity={0.8}
                      onPress={() => handleListPress(list.id)}
                    >
                      <Card style={styles.listCard}>
                        <View style={styles.listHeader}>
                          <View style={styles.listInfo}>
                            <Text style={styles.listTitle} numberOfLines={1}>
                              {list.title}
                            </Text>
                            <View style={styles.listMeta}>
                              <Text style={styles.listMetaText}>
                                {list.itemCount} items • Modified{' '}
                                {formatDate(list.updatedAt)}
                              </Text>
                            </View>
                          </View>
                          <Ionicons
                            name="chevron-forward"
                            size={20}
                            color={AppColors.neutral[400]}
                          />
                        </View>
                      </Card>
                    </TouchableOpacity>
                  ))}
                </View>

                {/* Secondary Actions */}
                <View style={styles.secondaryActions}>
                  <TouchableOpacity
                    style={styles.secondaryButton}
                    activeOpacity={0.8}
                    onPress={() => navigation.navigate('Lists')}
                  >
                    <Ionicons
                      name="list-outline"
                      size={20}
                      color={AppColors.primary}
                    />
                    <Text style={styles.secondaryButtonText}>
                      View All Lists
                    </Text>
                  </TouchableOpacity>
                </View>
              </>
            ) : (
              /* Empty State */
              <View style={styles.emptyState}>
                <Image
                  source={require('../../assets/logo-transparent.png')}
                  style={styles.emptyStateImage}
                />
                <Text style={styles.emptyStateTitle}>Welcome to TierNerd!</Text>
                <Text style={styles.emptyStateText}>
                  Create your first tier list and start ranking your favorite
                  things
                </Text>
                <Button
                  title="Create Your First List"
                  onPress={handleCreatePress}
                  style={styles.emptyStateButton}
                />
              </View>
            )}
          </Animated.View>
        </ScrollView>
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
  scrollContent: {
    paddingHorizontal: AppSpacing.lg,
    paddingBottom: AppSpacing.xxxl,
  },
  header: {
    marginBottom: AppSpacing.xl,
    paddingTop: AppSpacing.md,
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
    ...AppShadows.md,
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
  heroSection: {
    marginBottom: AppSpacing.xl,
  },
  createButton: {
    backgroundColor: AppColors.primary,
    paddingVertical: AppSpacing.lg,
    ...AppShadows.lg,
  },
  statsCard: {
    backgroundColor: AppColors.dominant.primary,
    borderRadius: AppBorders.radiusLg,
    padding: AppSpacing.lg,
    marginBottom: AppSpacing.xl,
    ...AppShadows.md,
  },
  statsRow: {
    flexDirection: 'row',
    justifyContent: 'space-around',
    alignItems: 'center',
  },
  statItem: {
    flex: 1,
    alignItems: 'center',
  },
  statValue: {
    ...AppTypography.headlineMedium,
    color: AppColors.secondary.emphasis,
    fontWeight: '700',
  },
  statLabel: {
    ...AppTypography.labelSmall,
    color: AppColors.textSecondary,
    marginTop: AppSpacing.xs,
  },
  statDivider: {
    width: 1,
    height: 40,
    backgroundColor: AppColors.neutral[200],
  },
  tierBadge: {
    width: 32,
    height: 32,
    borderRadius: 16,
    alignItems: 'center',
    justifyContent: 'center',
    marginBottom: AppSpacing.xxs,
  },
  tierBadgeText: {
    ...AppTypography.labelMedium,
    color: AppColors.textOnPrimary,
    fontWeight: 'bold',
  },
  recentSection: {
    marginBottom: AppSpacing.xl,
  },
  sectionTitle: {
    ...AppTypography.titleMedium,
    color: AppColors.secondary.emphasis,
    fontWeight: '600',
    marginBottom: AppSpacing.md,
  },
  listCard: {
    backgroundColor: AppColors.dominant.primary,
    borderRadius: AppBorders.radiusMd,
    padding: AppSpacing.md,
    marginBottom: AppSpacing.sm,
    ...AppShadows.md,
  },
  listHeader: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
  },
  listInfo: {
    flex: 1,
  },
  listTitle: {
    ...AppTypography.bodyLarge,
    color: AppColors.secondary.emphasis,
    fontWeight: '600',
    marginBottom: AppSpacing.xxs,
  },
  listMeta: {
    flexDirection: 'row',
    alignItems: 'center',
  },
  listMetaText: {
    ...AppTypography.bodySmall,
    color: AppColors.textSecondary,
  },
  secondaryActions: {
    marginTop: AppSpacing.lg,
  },
  secondaryButton: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'center',
    backgroundColor: AppColors.surface,
    borderWidth: 1,
    borderColor: AppColors.primary,
    borderRadius: AppBorders.radiusMd,
    paddingVertical: AppSpacing.md,
    paddingHorizontal: AppSpacing.lg,
  },
  secondaryButtonText: {
    ...AppTypography.labelLarge,
    color: AppColors.primary,
    fontWeight: '500',
    marginLeft: AppSpacing.sm,
  },
  emptyState: {
    alignItems: 'center',
    paddingTop: AppSpacing.xxxl,
    paddingHorizontal: AppSpacing.lg,
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
  emptyStateButton: {
    backgroundColor: AppColors.primary,
  },
});
