import React from 'react';
import {
  View,
  Text,
  StyleSheet,
  ScrollView,
  TouchableOpacity,
} from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';
import { LinearGradient } from 'expo-linear-gradient';
import { Ionicons } from '@expo/vector-icons';
import { AppColors, AppSpacing, AppTypography } from '../design-system/tokens';

interface ListsScreenProps {
  navigation?: any;
}

export const ListsScreen: React.FC<ListsScreenProps> = ({ navigation }) => {
  return (
    <LinearGradient
      colors={[AppColors.primary, AppColors.primaryDark]}
      style={styles.container}
    >
      <SafeAreaView style={styles.safeArea}>
        <View style={styles.header}>
          <TouchableOpacity 
            onPress={() => navigation?.goBack()}
            style={styles.backButton}
          >
            <Ionicons name="arrow-back" size={24} color={AppColors.textOnPrimary} />
          </TouchableOpacity>
          <Text style={styles.title}>All Lists</Text>
          <View style={styles.placeholder} />
        </View>
        
        <ScrollView style={styles.content}>
          <View style={styles.emptyState}>
            <Ionicons 
              name="list-outline" 
              size={64} 
              color={AppColors.textOnPrimary} 
              style={styles.emptyIcon}
            />
            <Text style={styles.emptyTitle}>No Lists Yet</Text>
            <Text style={styles.emptySubtitle}>
              Create your first tier list to get started
            </Text>
            <TouchableOpacity style={styles.createButton}>
              <Ionicons name="add" size={24} color={AppColors.primary} />
              <Text style={styles.createButtonText}>Create List</Text>
            </TouchableOpacity>
          </View>
        </ScrollView>
      </SafeAreaView>
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
  header: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between',
    paddingHorizontal: AppSpacing.md,
    paddingVertical: AppSpacing.md,
  },
  backButton: {
    padding: AppSpacing.sm,
  },
  title: {
    ...AppTypography.headlineSmall,
    color: AppColors.textOnPrimary,
    fontWeight: '600',
  },
  placeholder: {
    width: 40, // Same width as back button for centering
  },
  content: {
    flex: 1,
    paddingHorizontal: AppSpacing.md,
  },
  emptyState: {
    flex: 1,
    alignItems: 'center',
    justifyContent: 'center',
    paddingVertical: AppSpacing.xxxl,
  },
  emptyIcon: {
    opacity: 0.5,
    marginBottom: AppSpacing.lg,
  },
  emptyTitle: {
    ...AppTypography.titleLarge,
    color: AppColors.textOnPrimary,
    fontWeight: '600',
    marginBottom: AppSpacing.sm,
  },
  emptySubtitle: {
    ...AppTypography.bodyLarge,
    color: AppColors.textOnPrimary,
    opacity: 0.7,
    textAlign: 'center',
    marginBottom: AppSpacing.xl,
  },
  createButton: {
    flexDirection: 'row',
    alignItems: 'center',
    backgroundColor: AppColors.surface,
    paddingHorizontal: AppSpacing.lg,
    paddingVertical: AppSpacing.md,
    borderRadius: 8,
  },
  createButtonText: {
    ...AppTypography.labelLarge,
    color: AppColors.primary,
    fontWeight: '600',
    marginLeft: AppSpacing.sm,
  },
});