import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/list_provider.dart';
import '../utils/app_theme.dart';
import '../widgets/list_card.dart';

class ListsScreen extends StatefulWidget {
  const ListsScreen({super.key});

  @override
  State<ListsScreen> createState() => _ListsScreenState();
}

class _ListsScreenState extends State<ListsScreen> {
  @override
  void initState() {
    super.initState();
    // Refresh lists when screen is opened
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final listProvider = Provider.of<ListProvider>(context, listen: false);
      listProvider.fetchLists(refresh: true);
    });
  }

  @override
  Widget build(BuildContext context) {
    final listProvider = Provider.of<ListProvider>(context);
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: Text('My Lists', style: theme.textTheme.titleLarge?.copyWith(color: Colors.white)),
        backgroundColor: AppTheme.primaryColor,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await listProvider.fetchLists(refresh: true);
        },
        child: listProvider.isLoading && listProvider.lists.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : listProvider.lists.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.list_alt,
                          size: 64,
                          color: AppTheme.textColorSecondary,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No lists yet',
                          style: theme.textTheme.titleLarge,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Create your first tier list to get started',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: AppTheme.textColorSecondary,
                          ),
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton.icon(
                          onPressed: () {
                            // TODO: Navigate to create list screen
                          },
                          icon: const Icon(Icons.add),
                          label: const Text('Create List'),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: listProvider.lists.length,
                    itemBuilder: (context, index) {
                      final list = listProvider.lists[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: ListCard(
                          title: list.title,
                          itemCount: list.itemCount,
                          lastModified: list.updatedAt,
                          tierCounts: list.tierCounts,
                          onTap: () {
                            // TODO: Navigate to list detail
                          },
                          onEdit: () {
                            // TODO: Navigate to edit list
                          },
                          onDelete: () {
                            _showDeleteConfirmation(context, list.listId);
                          },
                        ),
                      );
                    },
                  ),
      ),
      floatingActionButton: listProvider.lists.isNotEmpty
          ? FloatingActionButton(
              onPressed: () {
                // TODO: Navigate to create list screen
              },
              backgroundColor: AppTheme.accentColor,
              child: const Icon(Icons.add, color: Colors.black),
            )
          : null,
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