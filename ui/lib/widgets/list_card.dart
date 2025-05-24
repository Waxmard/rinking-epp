import 'package:flutter/material.dart';
import '../design_system/design_system.dart';

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
    super.key,
    required this.title,
    required this.itemCount,
    required this.lastModified,
    this.isRecentCard = false,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
    this.tierCounts,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      child: AppCard(
        variant: isRecentCard ? AppCardVariant.elevated : AppCardVariant.outlined,
        onTap: onTap,
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
                          ? AppTypography.headlineSmall
                          : AppTypography.titleMedium,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: Icon(
                          Icons.edit,
                          size: 20,
                          color: AppColors.textSecondary,
                        ),
                        onPressed: onEdit,
                        tooltip: 'Edit',
                        splashRadius: 20,
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.delete,
                          size: 20,
                          color: AppColors.textSecondary,
                        ),
                        onPressed: onDelete,
                        tooltip: 'Delete',
                        splashRadius: 20,
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: AppSpacing.sm),
              Row(
                children: [
                  Icon(
                    Icons.list,
                    size: 16,
                    color: AppColors.textSecondary,
                  ),
                  SizedBox(width: AppSpacing.xs),
                  Text(
                    '$itemCount items',
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  SizedBox(width: AppSpacing.md),
                  Icon(
                    Icons.calendar_today,
                    size: 16,
                    color: AppColors.textSecondary,
                  ),
                  SizedBox(width: AppSpacing.xs),
                  Text(
                    _formatDate(lastModified),
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              if (isRecentCard && tierCounts != null) ...[
                SizedBox(height: AppSpacing.md),
                _buildTierDistribution(context),
              ],
            ],
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
          style: AppTypography.labelLarge,
        ),
        SizedBox(height: AppSpacing.sm),
        SizedBox(
          height: 24,
          child: Row(
            children: [
              _buildTierIndicator('S', AppColors.tierS),
              _buildTierIndicator('A', AppColors.tierA),
              _buildTierIndicator('B', AppColors.tierB),
              _buildTierIndicator('C', AppColors.tierC),
              _buildTierIndicator('D', AppColors.tierD),
              _buildTierIndicator('F', AppColors.tierF),
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
          SizedBox(width: AppSpacing.xxs),
          Text(
            count.toString(),
            style: TextStyle(
              fontSize: 10,
              color: hasItems ? AppColors.textPrimary : AppColors.textSecondary,
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
