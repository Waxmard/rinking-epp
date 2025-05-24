import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/list_provider.dart';
import '../design_system/design_system.dart';
import '../widgets/tier_list_preview.dart';

/// Example of HomeScreen updated to use the new design system
class HomeScreenUpdated extends StatefulWidget {
  const HomeScreenUpdated({super.key});

  @override
  State<HomeScreenUpdated> createState() => _HomeScreenUpdatedState();
}

class _HomeScreenUpdatedState extends State<HomeScreenUpdated> {
  @override
  void initState() {
    super.initState();
    // Initialize list data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      final listProvider = Provider.of<ListProvider>(context, listen: false);

      // Set auth token for list service
      listProvider.initialize();
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final listProvider = Provider.of<ListProvider>(context);
    final userData = auth.userData;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: AppColors.primaryGradient,
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header with consistent spacing
              Padding(
                padding: AppSpacing.screenHorizontal,
                child: Column(
                  children: [
                    SizedBox(height: AppSpacing.lg),
                    // User info row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // User greeting
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Welcome back,',
                              style: AppTypography.bodyMedium.copyWith(
                                color: AppColors.textOnPrimary.withOpacity(0.8),
                              ),
                            ),
                            SizedBox(height: AppSpacing.xxs),
                            Text(
                              userData?['name'] ?? 'Tier Nerd',
                              style: AppTypography.headlineMedium.copyWith(
                                color: AppColors.textOnPrimary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        // User avatar with proper styling
                        Container(
                          padding: EdgeInsets.all(AppSpacing.xs),
                          decoration: BoxDecoration(
                            color: AppColors.textOnPrimary.withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: CircleAvatar(
                            radius: 24,
                            backgroundColor: AppColors.accent,
                            child: Text(
                              (userData?['name'] ?? 'TN')[0].toUpperCase(),
                              style: AppTypography.titleLarge.copyWith(
                                color: AppColors.textOnAccent,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: AppSpacing.xl),
                  ],
                ),
              ),
              
              // Main content area with rounded corners
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(AppBorders.radiusXxl),
                      topRight: Radius.circular(AppBorders.radiusXxl),
                    ),
                    boxShadow: [AppShadows.xl],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Section header
                      Padding(
                        padding: EdgeInsets.all(AppSpacing.lg),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Recent Lists',
                              style: AppTypography.headlineSmall,
                            ),
                            AppButton(
                              label: 'View All',
                              onPressed: () => Navigator.pushNamed(context, '/lists'),
                              variant: AppButtonVariant.text,
                              size: AppButtonSize.small,
                              icon: Icons.arrow_forward,
                            ),
                          ],
                        ),
                      ),
                      
                      // Lists content
                      Expanded(
                        child: listProvider.isLoading
                            ? _buildLoadingState()
                            : listProvider.userLists.isEmpty
                                ? _buildEmptyState(context)
                                : _buildListContent(listProvider),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      
      // Floating Action Button with design system styling
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // Create new list action
          Navigator.pushNamed(context, '/lists');
        },
        label: Text('Create List'),
        icon: Icon(Icons.add),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            color: AppColors.accent,
          ),
          SizedBox(height: AppSpacing.md),
          Text(
            'Loading your lists...',
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.list_alt_outlined,
              size: 80,
              color: AppColors.neutral[400],
            ),
            SizedBox(height: AppSpacing.lg),
            Text(
              'No tier lists yet',
              style: AppTypography.headlineSmall,
            ),
            SizedBox(height: AppSpacing.sm),
            Text(
              'Create your first tier list to start ranking!',
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: AppSpacing.xl),
            AppButton(
              label: 'Create Your First List',
              onPressed: () => Navigator.pushNamed(context, '/lists'),
              variant: AppButtonVariant.primary,
              icon: Icons.add,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildListContent(ListProvider listProvider) {
    return ListView.builder(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      itemCount: listProvider.userLists.length > 3 ? 3 : listProvider.userLists.length,
      itemBuilder: (context, index) {
        final list = listProvider.userLists[index];
        return Padding(
          padding: EdgeInsets.only(bottom: AppSpacing.md),
          child: AppCard(
            variant: AppCardVariant.elevated,
            onTap: () {
              // Navigate to list detail
              Navigator.pushNamed(context, '/lists');
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // List header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            list['name'] ?? 'Untitled List',
                            style: AppTypography.titleMedium.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: AppSpacing.xxs),
                          Text(
                            '${list['items']?.length ?? 0} items',
                            style: AppTypography.bodySmall.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    AppIconButton(
                      icon: Icons.arrow_forward_ios,
                      onPressed: () => Navigator.pushNamed(context, '/lists'),
                      size: AppIconButtonSize.small,
                    ),
                  ],
                ),
                SizedBox(height: AppSpacing.md),
                // Tier preview using the actual TierListPreview widget
                SizedBox(
                  height: 40,
                  child: TierListPreview(
                    items: list['items'] ?? [],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Example of custom navigation drawer using design system
class AppNavigationDrawer extends StatelessWidget {
  const AppNavigationDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final userData = auth.userData;

    return Drawer(
      child: Column(
        children: [
          // Drawer header
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
            ),
            child: SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: AppColors.accent,
                    child: Text(
                      (userData?['name'] ?? 'TN')[0].toUpperCase(),
                      style: AppTypography.headlineLarge.copyWith(
                        color: AppColors.textOnAccent,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  SizedBox(height: AppSpacing.md),
                  Text(
                    userData?['name'] ?? 'Tier Nerd',
                    style: AppTypography.titleLarge.copyWith(
                      color: AppColors.textOnPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    userData?['email'] ?? '',
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.textOnPrimary.withOpacity(0.8),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Menu items
          Expanded(
            child: ListView(
              padding: EdgeInsets.all(AppSpacing.sm),
              children: [
                AppListCard(
                  leading: Icon(Icons.home, color: AppColors.primary),
                  title: 'Home',
                  onTap: () => Navigator.pop(context),
                ),
                AppListCard(
                  leading: Icon(Icons.list, color: AppColors.primary),
                  title: 'My Lists',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/lists');
                  },
                ),
                AppListCard(
                  leading: Icon(Icons.palette, color: AppColors.primary),
                  title: 'Design System Demo',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/design-system');
                  },
                ),
                Divider(height: AppSpacing.xl),
                AppListCard(
                  leading: Icon(Icons.settings, color: AppColors.primary),
                  title: 'Settings',
                  onTap: () {
                    // Navigate to settings
                  },
                ),
                AppListCard(
                  leading: Icon(Icons.logout, color: AppColors.error),
                  title: 'Sign Out',
                  onTap: () async {
                    await auth.signOut();
                    Navigator.pushReplacementNamed(context, '/login');
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}