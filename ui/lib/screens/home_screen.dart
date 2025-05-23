import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/list_provider.dart';
import '../utils/app_theme.dart';
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
      backgroundColor: AppTheme.primaryColor, // Same purple as login screen
      body: SafeArea(
        child: Container(
          decoration: BoxDecoration(
            // Add subtle gradient background like login screen
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AppTheme.primaryColor,
                AppTheme.primaryColor.withOpacity(0.8),
              ],
            ),
          ),
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
                    decoration: BoxDecoration(
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
                    decoration: BoxDecoration(
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
              padding: const EdgeInsets.fromLTRB(16.0, 48.0, 16.0, 0.0),
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
                              'assets/images/tier-nerd-logo-0.png',
                              height: 60,
                              width: 60,
                            ),
                          ],
                        ),
                      ),
                      
                      // Action buttons
                      Row(
                        children: [
                          // Add new list button
                          Container(
                            margin: const EdgeInsets.only(right: 24),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF5F5F5), // Softer off-white
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(20),
                                onTap: () {
                                  // TODO: Navigate to create list screen
                                },
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                  child: Row(
                                    children: [
                                      Icon(Icons.add, color: AppTheme.primaryColor, size: 18),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Create',
                                        style: TextStyle(
                                          color: AppTheme.primaryColor,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
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
                  
                  const SizedBox(height: 24),
                  // No greeting or username needed
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),

          // Most Recent List
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // No header text needed
                  const SizedBox(height: 8),
                  if (listProvider.isLoading && listProvider.recentList == null)
                    const Center(child: CircularProgressIndicator()),
                  if (listProvider.recentList != null)
                    TierListPreview(
                      tierList: listProvider.recentList!,
                      onTap: () {
                        // TODO: Navigate to list detail
                      },
                    ),
                  if (listProvider.recentList == null && !listProvider.isLoading)
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            const Icon(Icons.list_alt, size: 48, color: AppTheme.textColorSecondary),
                            const SizedBox(height: 16),
                            Text(
                              'No lists yet',
                              style: theme.textTheme.titleMedium?.copyWith(color: Colors.white70),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Create your first tier list to get started',
                              style: theme.textTheme.bodyMedium?.copyWith(color: Colors.white70),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                  const SizedBox(height: 24),

                  // No Create New List button needed here anymore
                  const SizedBox(height: 24),

                  // All Lists Section Title
                  Text(
                    'All Lists',
                    style: theme.textTheme.titleLarge?.copyWith(color: Colors.white),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),

          // User Lists
          if (listProvider.lists.isEmpty && listProvider.isLoading)
            const SliverToBoxAdapter(
              child: Center(child: CircularProgressIndicator()),
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
          const SliverToBoxAdapter(
            child: SizedBox(height: 80),
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
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.person),
                title: const Text('Profile'),
                onTap: () {
                  // TODO: Navigate to profile screen
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.settings),
                title: const Text('Settings'),
                onTap: () {
                  // TODO: Navigate to settings screen
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.logout),
                title: const Text('Sign Out'),
                onTap: () async {
                  Navigator.pop(context);
                  await auth.signOut();
                  if (context.mounted) {
                    Navigator.of(context).pushReplacementNamed('/login');
                  }
                },
              ),
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
          title: const Text('Delete List'),
          content: const Text('Are you sure you want to delete this list? This action cannot be undone.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
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
              child: const Text('Delete', style: TextStyle(color: AppTheme.errorColor)),
            ),
          ],
        );
      },
    );
  }
}
