import 'package:flutter/material.dart';
import '../models/list_model.dart';
import '../design_system/design_system.dart';

class TierListPreview extends StatelessWidget {
  final TierList tierList;
  final VoidCallback onTap;

  const TierListPreview({
    super.key,
    required this.tierList,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      variant: AppCardVariant.elevated,
      onTap: onTap,
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            Text(
              tierList.title,
              style: AppTypography.headlineSmall,
              overflow: TextOverflow.ellipsis,
            ),

            // Item count
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
                  '${tierList.itemCount} items',
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),

            SizedBox(height: AppSpacing.md),

            // Tier rows visualization
            _buildTierPreview(context),
          ],
        ),
    );
  }

  Widget _buildTierPreview(BuildContext context) {
    // The tiers in order
    final tiers = ['S', 'A', 'B', 'C', 'D', 'F'];

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
    final color = AppColors.getTierColor(tier);

    return Padding(
      padding: EdgeInsets.only(bottom: AppSpacing.xs),
      child: Row(
        children: [
          // Tier label
          Container(
            width: 40,
            height: 40,
            margin: EdgeInsets.only(left: AppSpacing.md, right: AppSpacing.sm),
            decoration: BoxDecoration(
              color: color,
              borderRadius: AppBorders.sm,
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
                    margin: EdgeInsets.only(right: AppSpacing.xs + 2),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.7),
                      borderRadius: AppBorders.sm,
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
            margin: EdgeInsets.symmetric(horizontal: AppSpacing.md),
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
}
