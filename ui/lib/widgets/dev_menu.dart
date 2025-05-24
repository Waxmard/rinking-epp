import 'package:flutter/material.dart';
import '../design_system/design_system.dart';

class DevMenu extends StatelessWidget {
  const DevMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Developer Menu'),
        backgroundColor: AppColors.primary,
      ),
      body: ListView(
        padding: EdgeInsets.all(AppSpacing.md),
        children: [
          _buildMenuCard(
            context,
            title: 'Design System Demo',
            description: 'View all design system components',
            icon: Icons.palette,
            route: '/design-system',
          ),
          _buildMenuCard(
            context,
            title: 'Logo Options',
            description: 'Try different logo display styles',
            icon: Icons.image,
            route: '/logo-options',
          ),
          _buildMenuCard(
            context,
            title: 'Login Screen (Old)',
            description: 'Original login screen for comparison',
            icon: Icons.login,
            route: '/login-old',
          ),
          _buildMenuCard(
            context,
            title: 'Updated Home Screen',
            description: 'Home screen with design system',
            icon: Icons.home,
            route: '/home',
          ),
          const Divider(height: AppSpacing.xl),
          _buildMenuCard(
            context,
            title: 'Clear Auth & Restart',
            description: 'Sign out and return to login',
            icon: Icons.logout,
            onTap: () async {
              // Sign out logic
              Navigator.of(context).pushNamedAndRemoveUntil(
                '/login',
                (route) => false,
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMenuCard(
    BuildContext context, {
    required String title,
    required String description,
    required IconData icon,
    String? route,
    VoidCallback? onTap,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: AppSpacing.sm),
      child: AppCard(
        variant: AppCardVariant.elevated,
        onTap: onTap ?? () => Navigator.pushNamed(context, route!),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: AppBorders.md,
              ),
              child: Icon(
                icon,
                color: AppColors.primary,
                size: 32,
              ),
            ),
            SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTypography.titleMedium.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: AppSpacing.xxs),
                  Text(
                    description,
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: AppColors.textSecondary,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}