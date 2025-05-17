import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/list_provider.dart';
import '../utils/app_theme.dart';
import '../widgets/list_card.dart';
import '../models/list_model.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Temporary mock data for UI development
  // TODO: Replace with actual data from API
  final _mockRecentList = {
    'id': '123',
    'title': 'Best Anime Series',
    'itemCount': 15,
    'lastModified': DateTime.now().subtract(const Duration(hours: 2)),
    'tierCounts': {
      'S': 2,
      'A': 3,
      'B': 4,
      'C': 3,
      'D': 2,
      'E': 1,
      'F': 0,
    },
  };

  final _mockUserLists = [
    {
      'id': '124',
      'title': 'Top Video Games 2023',
      'itemCount': 20,
      'lastModified': DateTime.now().subtract(const Duration(days: 2)),
    },
    {
      'id': '125',
      'title': 'MCU Movies Ranked',
      'itemCount': 30,
      'lastModified': DateTime.now().subtract(const Duration(days: 5)),
    },
    {
      'id': '126',
      'title': 'Best Restaurants in Town',
      'itemCount': 12,
      'lastModified': DateTime.now().subtract(const Duration(days: 10)),
    },
    {
      'id': '127',
      'title': 'Books to Read',
      'itemCount': 8,
      'lastModified': DateTime.now().subtract(const Duration(days: 15)),
    },
  ];

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
      body: CustomScrollView(
        slivers: [
          // App Bar with user avatar
          SliverAppBar(
            floating: true,
            title: const Text('TierNerd'),
            actions: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: GestureDetector(
                  onTap: () {
                    // TODO: Navigate to profile/settings
                    _showProfileMenu(context);
                  },
                  child: CircleAvatar(
                    backgroundImage: userData?['photoUrl'] != null
                        ? NetworkImage(userData!['photoUrl']!)
                        : null,
                    child: userData?['photoUrl'] == null
                        ? const Icon(Icons.person)
                        : null,
                  ),
                ),
              ),
            ],
          ),

          // Main content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 0.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Greeting
                  Text(
                    'Welcome back,',
                    style: theme.textTheme.bodyLarge,
                  ),
                  Text(
                    userData?['displayName'] ?? 'User',
                    style: theme.textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 24),
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
                  Text(
                    'Recently Modified',
                    style: theme.textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  if (listProvider.isLoading && listProvider.recentList == null)
                    const Center(child: CircularProgressIndicator()),
                  if (listProvider.recentList != null)
                    ListCard(
                      title: listProvider.recentList!.title,
                      itemCount: listProvider.recentList!.itemCount,
                      lastModified: listProvider.recentList!.updatedAt,
                      isRecentCard: true,
                      tierCounts: listProvider.recentList!.tierCounts,
                      onTap: () {
                        // TODO: Navigate to list detail
                      },
                      onEdit: () {
                        // TODO: Navigate to edit list
                      },
                      onDelete: () {
                        // TODO: Confirm and delete list
                        _showDeleteConfirmation(context, listProvider.recentList!.listId);
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
                              style: theme.textTheme.titleMedium,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Create your first tier list to get started',
                              style: theme.textTheme.bodyMedium,
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                  const SizedBox(height: 24),

                  // Create New List Button
                  ElevatedButton.icon(
                    onPressed: () {
                      // TODO: Navigate to create list screen
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('Create New List'),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size.fromHeight(50),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // All Lists Section Title
                  Text(
                    'All Lists',
                    style: theme.textTheme.titleLarge,
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
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Navigate to create list screen (same as the button)
        },
        child: const Icon(Icons.add),
        tooltip: 'Create New List',
      ),
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