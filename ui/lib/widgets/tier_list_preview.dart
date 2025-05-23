import 'package:flutter/material.dart';
import '../models/list_model.dart';
import '../utils/app_theme.dart';

class TierListPreview extends StatelessWidget {
  final TierList tierList;
  final VoidCallback onTap;

  const TierListPreview({
    Key? key,
    required this.tierList,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3.0,
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            Padding(
              padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0),
              child: Text(
                tierList.title,
                style: Theme.of(context).textTheme.titleLarge,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            
            // Item count
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
                ],
              ),
            ),
            
            const SizedBox(height: 16.0),
            
            // Tier rows visualization
            _buildTierPreview(context),
            
            // Bottom padding
            const SizedBox(height: 16.0),
          ],
        ),
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
}