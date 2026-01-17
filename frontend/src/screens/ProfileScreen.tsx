import React, { useEffect, useRef } from 'react';
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
import { Card } from '../design-system/components';
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
};

interface ProfileScreenProps {
  navigation?: any;
}

export const ProfileScreen: React.FC<ProfileScreenProps> = ({ navigation }) => {
  const { user, signOut } = useAuth();

  // Animation values
  const fadeAnim = useRef(new Animated.Value(0)).current;

  useEffect(() => {
    // Start fade in animation
    Animated.timing(fadeAnim, {
      toValue: 1,
      duration: 600,
      useNativeDriver: true,
    }).start();
  }, []);

  const handleSignOut = async () => {
    console.log('Signing out...');
    await signOut();
    // Navigation happens automatically when user state changes
  };

  const handleBack = () => {
    navigation.goBack();
  };

  const settingsItems = [
    { id: 'account', label: 'Account Settings', icon: 'person-outline' },
    { id: 'preferences', label: 'App Preferences', icon: 'settings-outline' },
    { id: 'about', label: 'About', icon: 'information-circle-outline' },
  ];

  return (
    <View style={styles.container}>
      <SafeAreaView style={styles.safeArea}>
        <ScrollView
          contentContainerStyle={styles.scrollContent}
          showsVerticalScrollIndicator={false}
        >
          <Animated.View style={{ opacity: fadeAnim }}>
            {/* Header with back button */}
            <View style={styles.header}>
              <TouchableOpacity
                onPress={handleBack}
                style={styles.backButton}
                activeOpacity={0.7}
                hitSlop={{ top: 10, bottom: 10, left: 10, right: 10 }}
              >
                <Ionicons
                  name="arrow-back"
                  size={24}
                  color={AppColors.secondary.primary}
                />
              </TouchableOpacity>
              <Text style={styles.headerTitle}>Profile</Text>
              <View style={styles.backButton} />
            </View>

            {/* User Info Card */}
            <Card style={styles.userCard}>
              <View style={styles.userInfo}>
                {user?.photoUrl ? (
                  <Image
                    source={{ uri: user.photoUrl }}
                    style={styles.profileImage}
                  />
                ) : (
                  <View style={styles.profilePlaceholder}>
                    <Ionicons
                      name="person"
                      size={40}
                      color={AppColors.neutral[600]}
                    />
                  </View>
                )}
                <Text style={styles.userName}>
                  {user?.displayName || user?.email?.split('@')[0] || 'User'}
                </Text>
                <Text style={styles.userEmail}>
                  {user?.email || 'No email'}
                </Text>
              </View>
            </Card>

            {/* Settings Options */}
            <View style={styles.settingsSection}>
              <Text style={styles.sectionTitle}>Settings</Text>
              <Card style={styles.settingsCard}>
                {settingsItems.map((item, index) => (
                  <TouchableOpacity
                    key={item.id}
                    style={[
                      styles.settingsItem,
                      index < settingsItems.length - 1 &&
                        styles.settingsItemBorder,
                    ]}
                    activeOpacity={0.7}
                  >
                    <View style={styles.settingsItemContent}>
                      <Ionicons
                        name={item.icon as any}
                        size={22}
                        color={AppColors.secondary.primary}
                        style={styles.settingsIcon}
                      />
                      <Text style={styles.settingsLabel}>{item.label}</Text>
                    </View>
                    <Ionicons
                      name="chevron-forward"
                      size={20}
                      color={AppColors.neutral[400]}
                    />
                  </TouchableOpacity>
                ))}
              </Card>
            </View>

            {/* Sign Out Button */}
            <View style={styles.signOutSection}>
              <TouchableOpacity
                style={styles.signOutButton}
                onPress={handleSignOut}
                activeOpacity={0.8}
              >
                <Ionicons name="log-out-outline" size={20} color="#DC2626" />
                <Text style={styles.signOutButtonText}>Sign Out</Text>
              </TouchableOpacity>
            </View>

            {/* Version Info */}
            <View style={styles.versionContainer}>
              <Image
                source={require('../../assets/logo-transparent.png')}
                style={styles.versionLogo}
                resizeMode="contain"
              />
              <Text style={styles.versionText}>v1.0.0 • Tier Nerd</Text>
            </View>
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
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between',
    paddingVertical: AppSpacing.md,
    marginBottom: AppSpacing.lg,
  },
  backButton: {
    width: 40,
    height: 40,
    justifyContent: 'center',
    alignItems: 'center',
  },
  headerTitle: {
    ...AppTypography.headlineMedium,
    color: AppColors.secondary.emphasis,
    fontWeight: '600',
  },
  userCard: {
    backgroundColor: AppColors.dominant.primary,
    borderRadius: AppBorders.radiusLg,
    padding: AppSpacing.xl,
    marginBottom: AppSpacing.xl,
    ...AppShadows.md,
  },
  userInfo: {
    alignItems: 'center',
  },
  profileImage: {
    width: 80,
    height: 80,
    borderRadius: 40,
    marginBottom: AppSpacing.md,
  },
  profilePlaceholder: {
    width: 80,
    height: 80,
    borderRadius: 40,
    backgroundColor: AppColors.surface,
    alignItems: 'center',
    justifyContent: 'center',
    borderWidth: 1,
    borderColor: AppColors.neutral[300],
    marginBottom: AppSpacing.md,
  },
  userName: {
    ...AppTypography.headlineSmall,
    color: AppColors.secondary.emphasis,
    fontWeight: '600',
    marginBottom: AppSpacing.xs,
  },
  userEmail: {
    ...AppTypography.bodyMedium,
    color: AppColors.textSecondary,
  },
  settingsSection: {
    marginBottom: AppSpacing.xl,
  },
  sectionTitle: {
    ...AppTypography.titleMedium,
    color: AppColors.secondary.emphasis,
    fontWeight: '600',
    marginBottom: AppSpacing.md,
  },
  settingsCard: {
    backgroundColor: AppColors.dominant.primary,
    borderRadius: AppBorders.radiusLg,
    ...AppShadows.md,
  },
  settingsItem: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between',
    paddingVertical: AppSpacing.md,
    paddingHorizontal: AppSpacing.lg,
  },
  settingsItemBorder: {
    borderBottomWidth: 1,
    borderBottomColor: AppColors.neutral[200],
  },
  settingsItemContent: {
    flexDirection: 'row',
    alignItems: 'center',
  },
  settingsIcon: {
    marginRight: AppSpacing.md,
  },
  settingsLabel: {
    ...AppTypography.bodyLarge,
    color: AppColors.secondary.primary,
    fontWeight: '500',
  },
  signOutSection: {
    marginBottom: AppSpacing.xl,
  },
  signOutButton: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'center',
    backgroundColor: AppColors.surface,
    borderWidth: 1,
    borderColor: '#DC2626',
    borderRadius: AppBorders.radiusMd,
    paddingVertical: AppSpacing.md,
    paddingHorizontal: AppSpacing.lg,
  },
  signOutButtonText: {
    ...AppTypography.labelLarge,
    color: '#DC2626',
    fontWeight: '600',
    marginLeft: AppSpacing.sm,
  },
  versionContainer: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'center',
    marginTop: AppSpacing.md,
  },
  versionLogo: {
    width: 16,
    height: 16,
    marginRight: AppSpacing.xs,
    opacity: 0.3,
  },
  versionText: {
    ...AppTypography.labelSmall,
    color: AppColors.textSecondary,
    opacity: 0.5,
  },
});
