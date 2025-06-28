import React, { useState } from 'react';
import {
  View,
  Text,
  StyleSheet,
  ScrollView,
  TouchableOpacity,
  Image,
  Modal,
  FlatList,
} from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';
import { LinearGradient } from 'expo-linear-gradient';
import { Ionicons } from '@expo/vector-icons';
import { useNavigation } from '@react-navigation/native';
import { useAuth } from '../providers/AuthContext';
import { Card, Button } from '../design-system/components';
import { AppColors, AppSpacing, AppTypography, AppBorders, AppGradients } from '../design-system/tokens';

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

interface TierCount {
  S: number;
  A: number;
  B: number;
  C: number;
  D: number;
  F: number;
}

interface RecentList {
  id: string;
  title: string;
  itemCount: number;
  updatedAt: Date;
  tierCounts: TierCount;
}

export const HomeScreen: React.FC = () => {
  const navigation = useNavigation<any>();
  const { user, userData, signOut } = useAuth();
  const [showProfileMenu, setShowProfileMenu] = useState(false);
  
  // Mock data for recent list
  const [recentList] = useState<RecentList | null>({
    id: '1',
    title: 'Best Programming Languages',
    itemCount: 15,
    updatedAt: new Date(),
    tierCounts: {
      S: 2,
      A: 4,
      B: 5,
      C: 3,
      D: 1,
      F: 0,
    },
  });

  const formatDate = (date: Date): string => {
    const now = new Date();
    const difference = Math.floor((now.getTime() - date.getTime()) / (1000 * 60 * 60 * 24));
    
    if (difference === 0) return 'today';
    if (difference === 1) return 'yesterday';
    if (difference < 7) return `${difference} days ago`;
    return `${date.getMonth() + 1}/${date.getDate()}/${date.getFullYear()}`;
  };

  const handleSignOut = async () => {
    await signOut();
    navigation.replace('Login');
  };

  const renderTierDistribution = (tierCounts: TierCount) => {
    const tiers = ['S', 'A', 'B', 'C', 'D', 'F'] as const;
    
    return (
      <View style={styles.tierDistribution}>
        {tiers.map((tier) => {
          const count = tierCounts[tier];
          const hasItems = count > 0;
          const color = AppColors.tierColors[tier];
          
          return (
            <View key={tier} style={styles.tierItem}>
              <View
                style={[
                  styles.tierBox,
                  { 
                    backgroundColor: hasItems ? `${color}20` : AppColors.neutral[100],
                    borderColor: hasItems ? color : AppColors.neutral[300],
                  },
                ]}
              >
                <Text
                  style={[
                    styles.tierLabel,
                    { color: hasItems ? color : AppColors.textSecondary },
                  ]}
                >
                  {tier}
                </Text>
                <Text
                  style={[
                    styles.tierCount,
                    { color: hasItems ? AppColors.textPrimary : AppColors.textSecondary },
                  ]}
                >
                  {count}
                </Text>
              </View>
            </View>
          );
        })}
      </View>
    );
  };

  const profileMenuItems = [
    { id: 'profile', label: 'Profile', icon: 'person-outline' },
    { id: 'settings', label: 'Settings', icon: 'settings-outline' },
    { id: 'signout', label: 'Sign Out', icon: 'log-out-outline', danger: true },
  ];

  return (
    <LinearGradient
      colors={AppGradients.primary}
      style={styles.container}
    >
      <SafeAreaView style={styles.safeArea}>
        <ScrollView
          contentContainerStyle={styles.scrollContent}
          showsVerticalScrollIndicator={false}
        >
          {/* Header */}
          <View style={styles.header}>
            <Text style={styles.tierNerdText}>TierNerd</Text>
            <View style={styles.headerRow}>
              <TouchableOpacity onPress={() => navigation.replace('Home')}>
                <Image
                  source={require('../../assets/icon.png')}
                  style={styles.logo}
                />
              </TouchableOpacity>
              
              <TouchableOpacity
                onPress={() => setShowProfileMenu(true)}
                style={styles.profileButton}
              >
                {userData?.photoUrl ? (
                  <Image
                    source={{ uri: userData.photoUrl }}
                    style={styles.profileImage}
                  />
                ) : (
                  <View style={styles.profilePlaceholder}>
                    <Ionicons name="person" size={32} color={AppColors.neutral[600]} />
                  </View>
                )}
              </TouchableOpacity>
            </View>
          </View>

          {/* Create Button */}
          <TouchableOpacity style={styles.createButton} activeOpacity={0.8}>
            <View style={styles.createButtonContent}>
              <Ionicons name="add-circle-outline" size={24} color={AppColors.primary} />
              <Text style={styles.createButtonText}>Create New Tier List</Text>
            </View>
          </TouchableOpacity>

          {/* Recent List */}
          {recentList && (
            <View style={styles.recentSection}>
              <Text style={styles.sectionTitle}>Recent List</Text>
              <TouchableOpacity activeOpacity={0.9}>
                <Card style={styles.listCard}>
                  <View style={styles.listHeader}>
                    <Text style={styles.listTitle} numberOfLines={1}>
                      {recentList.title}
                    </Text>
                    <View style={styles.itemCountBadge}>
                      <Text style={styles.itemCountText}>{recentList.itemCount} items</Text>
                    </View>
                  </View>
                  
                  <View style={styles.listMeta}>
                    <Ionicons name="time-outline" size={16} color={AppColors.textSecondary} />
                    <Text style={styles.listMetaText}>
                      Modified {formatDate(recentList.updatedAt)}
                    </Text>
                  </View>
                  
                  <View style={styles.tierSection}>
                    <Text style={styles.tierSectionTitle}>Tier Distribution</Text>
                    {renderTierDistribution(recentList.tierCounts)}
                  </View>
                </Card>
              </TouchableOpacity>
            </View>
          )}

          {/* All Lists Button */}
          <TouchableOpacity
            style={styles.allListsButton}
            activeOpacity={0.8}
            onPress={() => navigation.navigate('Lists')}
          >
            <View style={styles.allListsButtonContent}>
              <Ionicons name="list" size={24} color={AppColors.primary} />
              <Text style={styles.allListsButtonText}>View All Lists</Text>
            </View>
          </TouchableOpacity>
        </ScrollView>
      </SafeAreaView>

      {/* Profile Menu Modal */}
      <Modal
        visible={showProfileMenu}
        transparent
        animationType="slide"
        onRequestClose={() => setShowProfileMenu(false)}
      >
        <TouchableOpacity
          style={styles.modalOverlay}
          activeOpacity={1}
          onPress={() => setShowProfileMenu(false)}
        >
          <View style={styles.profileMenu}>
            <View style={styles.profileMenuHandle} />
            <FlatList
              data={profileMenuItems}
              keyExtractor={(item) => item.id}
              renderItem={({ item }) => (
                <TouchableOpacity
                  style={styles.profileMenuItem}
                  onPress={() => {
                    setShowProfileMenu(false);
                    if (item.id === 'signout') {
                      handleSignOut();
                    }
                  }}
                >
                  <Ionicons
                    name={item.icon as any}
                    size={24}
                    color={item.danger ? AppColors.error : AppColors.textPrimary}
                  />
                  <Text
                    style={[
                      styles.profileMenuItemText,
                      item.danger && { color: AppColors.error },
                    ]}
                  >
                    {item.label}
                  </Text>
                </TouchableOpacity>
              )}
            />
          </View>
        </TouchableOpacity>
      </Modal>
    </LinearGradient>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
  },
  safeArea: {
    flex: 1,
  },
  scrollContent: {
    paddingHorizontal: AppSpacing.md,
    paddingBottom: AppSpacing.xxxl,
  },
  header: {
    marginBottom: AppSpacing.lg,
  },
  tierNerdText: {
    ...AppTypography.titleMedium,
    color: AppColors.textOnPrimary,
    marginBottom: AppSpacing.sm,
  },
  headerRow: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
  },
  logo: {
    width: 60,
    height: 60,
  },
  profileButton: {
    width: 56,
    height: 56,
    borderRadius: 28,
    overflow: 'hidden',
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
  createButton: {
    backgroundColor: AppColors.surface,
    borderRadius: AppBorders.radiusMd,
    marginBottom: AppSpacing.lg,
    ...AppShadows.md,
  },
  createButtonContent: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'center',
    paddingVertical: AppSpacing.md,
    paddingHorizontal: AppSpacing.md,
  },
  createButtonText: {
    ...AppTypography.titleMedium,
    color: AppColors.primary,
    fontWeight: '600',
    marginLeft: AppSpacing.sm,
  },
  recentSection: {
    marginBottom: AppSpacing.lg,
  },
  sectionTitle: {
    ...AppTypography.headlineSmall,
    color: AppColors.textOnPrimary,
    fontWeight: '600',
    marginBottom: AppSpacing.sm,
  },
  listCard: {
    backgroundColor: 'rgba(255, 255, 255, 0.95)',
    borderRadius: AppBorders.radiusLg,
    padding: AppSpacing.lg,
  },
  listHeader: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    marginBottom: AppSpacing.sm,
  },
  listTitle: {
    ...AppTypography.headlineSmall,
    color: AppColors.textPrimary,
    fontWeight: '600',
    flex: 1,
  },
  itemCountBadge: {
    backgroundColor: `${AppColors.primary}20`,
    paddingHorizontal: AppSpacing.sm,
    paddingVertical: AppSpacing.xs,
    borderRadius: AppBorders.radiusSm,
  },
  itemCountText: {
    ...AppTypography.labelSmall,
    color: AppColors.primary,
    fontWeight: '600',
  },
  listMeta: {
    flexDirection: 'row',
    alignItems: 'center',
    marginBottom: AppSpacing.md,
  },
  listMetaText: {
    ...AppTypography.bodySmall,
    color: AppColors.textSecondary,
    marginLeft: AppSpacing.xs,
  },
  tierSection: {
    marginTop: AppSpacing.sm,
  },
  tierSectionTitle: {
    ...AppTypography.labelMedium,
    color: AppColors.textPrimary,
    fontWeight: '600',
    marginBottom: AppSpacing.sm,
  },
  tierDistribution: {
    flexDirection: 'row',
    justifyContent: 'space-between',
  },
  tierItem: {
    flex: 1,
    marginRight: AppSpacing.xs,
  },
  tierBox: {
    padding: AppSpacing.xs,
    borderRadius: AppBorders.radiusSm,
    borderWidth: 1,
    alignItems: 'center',
  },
  tierLabel: {
    ...AppTypography.labelSmall,
    fontWeight: 'bold',
  },
  tierCount: {
    ...AppTypography.bodySmall,
    fontWeight: '600',
    marginTop: AppSpacing.xxs,
  },
  allListsButton: {
    backgroundColor: AppColors.surface,
    borderRadius: AppBorders.radiusMd,
    ...AppShadows.md,
  },
  allListsButtonContent: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'center',
    paddingVertical: AppSpacing.md,
    paddingHorizontal: AppSpacing.md,
  },
  allListsButtonText: {
    ...AppTypography.titleMedium,
    color: AppColors.primary,
    fontWeight: '600',
    marginLeft: AppSpacing.sm,
  },
  modalOverlay: {
    flex: 1,
    backgroundColor: 'rgba(0, 0, 0, 0.5)',
    justifyContent: 'flex-end',
  },
  profileMenu: {
    backgroundColor: AppColors.surface,
    borderTopLeftRadius: AppBorders.radiusLg,
    borderTopRightRadius: AppBorders.radiusLg,
    paddingBottom: AppSpacing.xl,
  },
  profileMenuHandle: {
    width: 40,
    height: 4,
    backgroundColor: AppColors.neutral[300],
    borderRadius: 2,
    alignSelf: 'center',
    marginTop: AppSpacing.sm,
    marginBottom: AppSpacing.md,
  },
  profileMenuItem: {
    flexDirection: 'row',
    alignItems: 'center',
    paddingVertical: AppSpacing.md,
    paddingHorizontal: AppSpacing.lg,
  },
  profileMenuItemText: {
    ...AppTypography.bodyLarge,
    color: AppColors.textPrimary,
    marginLeft: AppSpacing.md,
  },
});