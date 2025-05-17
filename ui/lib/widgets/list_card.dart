import 'package:flutter/material.dart';
import '../utils/app_theme.dart';

class ListCard extends StatelessWidget {
  final String title;
  final int itemCount;
  final DateTime lastModified;
  final bool isRecentCard;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final Map<String, int>? tierCounts;

  const ListCard({
    Key? key,
    required this.title,
    required this.itemCount,
    required this.lastModified,
    this.isRecentCard = false,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
    this.tierCounts,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: isRecentCard ? 3.0 : 1.0,
      margin: EdgeInsets.all(isRecentCard ? 16.0 : 8.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12.0),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: isRecentCard
                          ? Theme.of(context).textTheme.titleLarge
                          : Theme.of(context).textTheme.titleMedium,
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
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.list, size: 16, color: AppTheme.textColorSecondary),
                  const SizedBox(width: 4),
                  Text(
                    '$itemCount items',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppTheme.textColorSecondary,
                        ),
                  ),
                  const SizedBox(width: 16),
                  const Icon(Icons.calendar_today, size: 16, color: AppTheme.textColorSecondary),
                  const SizedBox(width: 4),
                  Text(
                    _formatDate(lastModified),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppTheme.textColorSecondary,
                        ),
                  ),
                ],
              ),
              if (isRecentCard && tierCounts != null) ...[
                const SizedBox(height: 16),
                _buildTierDistribution(context),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTierDistribution(BuildContext context) {
    if (tierCounts == null) return const SizedBox.shrink();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tier Distribution',
          style: Theme.of(context).textTheme.titleSmall,
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 24,
          child: Row(
            children: [
              _buildTierIndicator('S', AppTheme.sTierColor),
              _buildTierIndicator('A', AppTheme.aTierColor),
              _buildTierIndicator('B', AppTheme.bTierColor),
              _buildTierIndicator('C', AppTheme.cTierColor),
              _buildTierIndicator('D', AppTheme.dTierColor),
              _buildTierIndicator('E', AppTheme.eTierColor),
              _buildTierIndicator('F', AppTheme.fTierColor),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTierIndicator(String tier, Color color) {
    final count = tierCounts?[tier] ?? 0;
    final hasItems = count > 0;
    
    return Expanded(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 16,
            height: 16,
            decoration: BoxDecoration(
              color: hasItems ? color : color.withOpacity(0.3),
              borderRadius: BorderRadius.circular(2),
            ),
            alignment: Alignment.center,
            child: Text(
              tier,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),
          const SizedBox(width: 2),
          Text(
            count.toString(),
            style: TextStyle(
              fontSize: 10,
              color: hasItems ? AppTheme.textColorPrimary : AppTheme.textColorSecondary,
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