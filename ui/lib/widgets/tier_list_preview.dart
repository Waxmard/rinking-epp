import 'package:flutter/material.dart';
import '../models/list_model.dart';
import '../utils/app_theme.dart';

class TierListPreview extends StatelessWidget {
  final TierList tierList;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const TierListPreview({
    Key? key,
    required this.tierList,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3.0,
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title and actions bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16.0, 16.0, 8.0, 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    tierList.title,
                    style: Theme.of(context).textTheme.titleLarge,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, size: 20),
                      onPressed: onEdit,
                      tooltip: 'Edit',
                      splashRadius: 20,
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, size: 20),
                      onPressed: onDelete,
                      tooltip: 'Delete',
                      splashRadius: 20,
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // List info
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                const Icon(Icons.list, size: 16, color: AppTheme.textColorSecondary),
                const SizedBox(width: 4),
                Text(
                  '${tierList.itemCount} items',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppTheme.textColorSecondary,
                      ),
                ),
                const SizedBox(width: 16),
                const Icon(Icons.calendar_today, size: 16, color: AppTheme.textColorSecondary),
                const SizedBox(width: 4),
                Text(
                  _formatDate(tierList.updatedAt),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppTheme.textColorSecondary,
                      ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 16.0),
          
          // Tier rows visualization
          _buildTierPreview(context),
          
          // "View full list" button
          InkWell(
            onTap: onTap,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12.0),
              decoration: BoxDecoration(
                color: AppTheme.primaryColorLight.withOpacity(0.1),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(12.0),
                  bottomRight: Radius.circular(12.0),
                ),
              ),
              alignment: Alignment.center,
              child: Text(
                'View Full List',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryColor,
                    ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTierPreview(BuildContext context) {
    // The tiers in order
    final tiers = ['S', 'A', 'B', 'C', 'D', 'E', 'F'];
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final tier in tiers) 
          if (tierList.tierCounts[tier] != null && tierList.tierCounts[tier]! > 0)
            _buildTierRow(context, tier, tierList.tierCounts[tier] ?? 0),
      ],
    );
  }

  Widget _buildTierRow(BuildContext context, String tier, int count) {
    final color = AppTheme.getTierColor(tier);
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 4.0),
      child: Row(
        children: [
          // Tier label
          Container(
            width: 40,
            height: 40,
            margin: const EdgeInsets.only(left: 16, right: 12),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(4),
            ),
            alignment: Alignment.center,
            child: Text(
              tier,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),
          
          // Item indicators (placeholder blocks representing items)
          Expanded(
            child: SizedBox(
              height: 36,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: count > 10 ? 10 : count, // Limit to 10 visible blocks
                itemBuilder: (context, index) {
                  return Container(
                    width: 32,
                    height: 32,
                    margin: const EdgeInsets.only(right: 6),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: Colors.black26, width: 1),
                    ),
                    alignment: Alignment.center,
                    child: index < 9 || count <= 10 
                        ? null
                        : Text(
                            "+${count - 9}",
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                  );
                },
              ),
            ),
          ),
          
          // Count label
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              count.toString(),
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    if (date.year == now.year && date.month == now.month && date.day == now.day) {
      return 'Today';
    } else if (date.year == now.year && date.month == now.month && date.day == now.day - 1) {
      return 'Yesterday';
    } else {
      return '${date.month}/${date.day}/${date.year}';
    }
  }
}