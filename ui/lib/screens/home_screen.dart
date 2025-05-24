import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/list_provider.dart';
import '../design_system/design_system.dart';
import '../widgets/list_card.dart';
import '../widgets/tier_list_preview.dart';
import '../models/list_model.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // No need for mock data as we're using the ListProvider

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
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.primaryGradient,
        ),
        child: SafeArea(
          child: Stack(
            children: [
              // Add decorative background elements
              Positioned(
                top: -50,
                right: -50,
                child: Opacity(
                  opacity: 0.1,
                  child: Container(
                    height: 200,
                    width: 200,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: -80,
                left: -80,
                child: Opacity(
                  opacity: 0.08,
                  child: Container(
                    height: 250,
                    width: 250,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              CustomScrollView(
        slivers: [
          // Main content
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.xxl, AppSpacing.md, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header row with logo, add button, and profile
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // TierNerd logo
                      GestureDetector(
                        onTap: () {
                          // Navigate home (refresh)
                          Navigator.of(context).pushReplacementNamed('/');
                        },
                        child: Row(
                          children: [
                            // Just use the logo image without text
                            Image.asset(
                              'assets/images/logo-transparent.png',
                              height: 60,
                              width: 60,
                              fit: BoxFit.contain,
                            ),
                          ],
                        ),
                      ),

                      // Action buttons
                      Row(
                        children: [
                          // Add new list button
                          Container(
                            margin: EdgeInsets.only(right: AppSpacing.lg),
                            child: AppButton(
                              label: 'Create',
                              onPressed: () {
                                // TODO: Navigate to create list screen
                              },
                              variant: AppButtonVariant.secondary,
                              size: AppButtonSize.small,
                              icon: Icons.add,
                            ),
                          ),

                          // Profile avatar
                          GestureDetector(
                            onTap: () {
                              _showProfileMenu(context);
                            },
                            child: CircleAvatar(
                              radius: 20,
                              backgroundImage: userData?['photoUrl'] != null
                                ? userData!['photoUrl']!.startsWith('http')
                                    ? NetworkImage(userData['photoUrl']!)
                                    : AssetImage(userData['photoUrl']!) as ImageProvider
                                : null,
                              child: userData?['photoUrl'] == null
                                ? const Icon(Icons.person)
                                : null,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  SizedBox(height: AppSpacing.lg),
                  // No greeting or username needed
                  SizedBox(height: AppSpacing.sm),
                ],
              ),
            ),
          ),

          // Most Recent List
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // No header text needed
                  SizedBox(height: AppSpacing.sm),
                  if (listProvider.isLoading && listProvider.recentList == null)
                    Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(AppColors.textOnPrimary),
                      ),
                    ),
                  if (listProvider.recentList != null)
                    TierListPreview(
                      tierList: listProvider.recentList!,
                      onTap: () {
                        // TODO: Navigate to list detail
                      },
                    ),
                  if (listProvider.recentList == null && !listProvider.isLoading)
                    AppCard(
                      variant: AppCardVariant.outlined,
                      child: Column(
                        children: [
                          Icon(
                            Icons.list_alt,
                            size: 48,
                            color: AppColors.textOnPrimary.withOpacity(0.5),
                          ),
                          SizedBox(height: AppSpacing.md),
                          Text(
                            'No lists yet',
                            style: AppTypography.titleMedium.copyWith(
                              color: AppColors.textOnPrimary.withOpacity(0.9),
                            ),
                          ),
                          SizedBox(height: AppSpacing.sm),
                          Text(
                            'Create your first tier list to get started',
                            style: AppTypography.bodyMedium.copyWith(
                              color: AppColors.textOnPrimary.withOpacity(0.7),
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  SizedBox(height: AppSpacing.lg),

                  // No Create New List button needed here anymore
                  SizedBox(height: AppSpacing.lg),

                  // All Lists Section Title
                  Text(
                    'All Lists',
                    style: AppTypography.headlineSmall.copyWith(
                      color: AppColors.textOnPrimary,
                    ),
                  ),
                  SizedBox(height: AppSpacing.sm),
                ],
              ),
            ),
          ),

          // User Lists
          if (listProvider.lists.isEmpty && listProvider.isLoading)
            SliverToBoxAdapter(
              child: Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.textOnPrimary),
                ),
              ),
            )
          else if (listProvider.lists.isEmpty)
            const SliverToBoxAdapter(
              child: SizedBox(), // No need to show anything here if there are no lists
            )
          else
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final list = listProvider.lists[index];
                  // Skip the most recent list if it's already shown above
                  if (listProvider.recentList != null &&
                      list.listId == listProvider.recentList!.listId) {
                    return const SizedBox.shrink();
                  }

                  return ListCard(
                    title: list.title,
                    itemCount: list.itemCount,
                    lastModified: list.updatedAt,
                    onTap: () {
                      // TODO: Navigate to list detail
                    },
                    onEdit: () {
                      // TODO: Navigate to edit list
                    },
                    onDelete: () {
                      // TODO: Confirm and delete list
                      _showDeleteConfirmation(context, list.listId);
                    },
                  );
                },
                childCount: listProvider.lists.length,
              ),
            ),

          // Bottom padding
          SliverToBoxAdapter(
            child: SizedBox(height: AppSpacing.xxxl),
          ),
        ],
      ),
            ],
          ),
        ),
      ),
      // No floating action button needed as we have the + button in header
    );
  }

  void _showProfileMenu(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context, listen: false);

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surfaceLight,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppBorders.radiusMd)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                margin: EdgeInsets.only(top: AppSpacing.sm),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.neutral[300],
                  borderRadius: AppBorders.sm,
                ),
              ),
              SizedBox(height: AppSpacing.md),
              ListTile(
                leading: Icon(Icons.person, color: AppColors.textPrimary),
                title: Text(
                  'Profile',
                  style: AppTypography.bodyLarge,
                ),
                onTap: () {
                  // TODO: Navigate to profile screen
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: Icon(Icons.settings, color: AppColors.textPrimary),
                title: Text(
                  'Settings',
                  style: AppTypography.bodyLarge,
                ),
                onTap: () {
                  // TODO: Navigate to settings screen
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: Icon(Icons.logout, color: AppColors.error),
                title: Text(
                  'Sign Out',
                  style: AppTypography.bodyLarge.copyWith(
                    color: AppColors.error,
                  ),
                ),
                onTap: () async {
                  Navigator.pop(context);
                  await auth.signOut();
                  if (context.mounted) {
                    Navigator.of(context).pushReplacementNamed('/login');
                  }
                },
              ),
              SizedBox(height: AppSpacing.md),
            ],
          ),
        );
      },
    );
  }

  void _showDeleteConfirmation(BuildContext context, String listId) {
    final listProvider = Provider.of<ListProvider>(context, listen: false);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.surfaceLight,
          shape: RoundedRectangleBorder(
            borderRadius: AppBorders.lg,
          ),
          title: Text(
            'Delete List',
            style: AppTypography.headlineSmall,
          ),
          content: Text(
            'Are you sure you want to delete this list? This action cannot be undone.',
            style: AppTypography.bodyMedium,
          ),
          actions: [
            AppButton(
              label: 'Cancel',
              onPressed: () => Navigator.pop(context),
              variant: AppButtonVariant.text,
              size: AppButtonSize.small,
            ),
            AppButton(
              label: 'Delete',
              onPressed: () async {
                Navigator.pop(context);

                // Show loading indicator
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Deleting list...')),
                );

                final success = await listProvider.deleteList(listId);

                if (context.mounted) {
                  if (success) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('List deleted successfully')),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Failed to delete list: ${listProvider.error ?? "Unknown error"}')),
                    );
                  }
                }
              },
              variant: AppButtonVariant.text,
              size: AppButtonSize.small,
            ),
          ],
        );
      },
    );
  }
}
