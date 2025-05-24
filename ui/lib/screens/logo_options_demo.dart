import 'package:flutter/material.dart';
import '../design_system/design_system.dart';
import 'login_screen_logo_options.dart';

class LogoOptionsDemo extends StatefulWidget {
  const LogoOptionsDemo({super.key});

  @override
  State<LogoOptionsDemo> createState() => _LogoOptionsDemoState();
}

class _LogoOptionsDemoState extends State<LogoOptionsDemo> with SingleTickerProviderStateMixin {
  int _selectedOption = 1;
  late AnimationController _animationController;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    _glowAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
    _animationController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Logo Display Options',
          style: AppTypography.titleLarge.copyWith(
            color: AppColors.textOnPrimary,
          ),
        ),
        iconTheme: const IconThemeData(color: AppColors.textOnPrimary),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.primaryGradient,
        ),
        child: Column(
          children: [
            // Logo display area
            Expanded(
              flex: 3,
              child: Center(
                child: _buildSelectedLogo(),
              ),
            ),
            
            // Option selector
            Container(
              decoration: BoxDecoration(
                color: AppColors.surfaceLight,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(AppBorders.radiusXxl),
                  topRight: Radius.circular(AppBorders.radiusXxl),
                ),
                boxShadow: [AppShadows.xl],
              ),
              child: Column(
                children: [
                  Padding(
                    padding: EdgeInsets.all(AppSpacing.lg),
                    child: Text(
                      'Select Logo Style',
                      style: AppTypography.headlineSmall,
                    ),
                  ),
                  SizedBox(
                    height: 120,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
                      children: [
                        _buildOptionCard(1, 'Circular\nBackground', Icons.circle),
                        _buildOptionCard(2, 'Gradient\nFade', Icons.gradient),
                        _buildOptionCard(3, 'Glass\nMorphism', Icons.blur_on),
                        _buildOptionCard(4, 'Hexagon\nShape', Icons.hexagon_outlined),
                        _buildOptionCard(5, 'Blend\nMode', Icons.layers),
                        _buildOptionCard(6, 'Animated\nGlow', Icons.flare),
                      ],
                    ),
                  ),
                  SizedBox(height: AppSpacing.lg),
                  // Description
                  Padding(
                    padding: EdgeInsets.all(AppSpacing.lg),
                    child: Text(
                      _getDescription(),
                      style: AppTypography.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  // Try it button
                  Padding(
                    padding: EdgeInsets.all(AppSpacing.lg),
                    child: AppButton(
                      label: 'Apply to Login Screen',
                      onPressed: () {
                        Navigator.pushReplacementNamed(context, '/login');
                      },
                      variant: AppButtonVariant.primary,
                      fullWidth: true,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectedLogo() {
    const size = 200.0;
    
    switch (_selectedOption) {
      case 1:
        return LogoDisplayOptions.circularBackground(size: size);
      case 2:
        return LogoDisplayOptions.gradientFade(size: size);
      case 3:
        return LogoDisplayOptions.glassMorphism(size: size);
      case 4:
        return LogoDisplayOptions.hexagonShape(size: size);
      case 5:
        return LogoDisplayOptions.blendMode(size: size);
      case 6:
        return LogoDisplayOptions.animatedGlow(
          size: size,
          animation: _glowAnimation,
        );
      default:
        return LogoDisplayOptions.circularBackground(size: size);
    }
  }

  Widget _buildOptionCard(int option, String label, IconData icon) {
    final isSelected = _selectedOption == option;
    
    return Padding(
      padding: EdgeInsets.only(right: AppSpacing.sm),
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedOption = option;
          });
        },
        borderRadius: AppBorders.md,
        child: AnimatedContainer(
          duration: AppAnimations.durationFast,
          width: 100,
          padding: EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : AppColors.surfaceLight,
            borderRadius: AppBorders.md,
            border: Border.all(
              color: isSelected ? AppColors.primary : AppColors.divider,
              width: AppBorders.widthMedium,
            ),
            boxShadow: isSelected ? [AppShadows.sm] : [],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: isSelected ? AppColors.textOnPrimary : AppColors.textPrimary,
                size: 32,
              ),
              SizedBox(height: AppSpacing.sm),
              Text(
                label,
                style: AppTypography.labelSmall.copyWith(
                  color: isSelected ? AppColors.textOnPrimary : AppColors.textPrimary,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getDescription() {
    switch (_selectedOption) {
      case 1:
        return 'Clean white circle with subtle shadow. Professional and minimalist.';
      case 2:
        return 'Gradient overlay that blends the logo edges into the background.';
      case 3:
        return 'Modern frosted glass effect with translucent background.';
      case 4:
        return 'Unique hexagonal frame for a modern, tech-focused look.';
      case 5:
        return 'Color blending mode that can help merge logo with background.';
      case 6:
        return 'Animated pulsating glow effect for dynamic visual interest.';
      default:
        return '';
    }
  }
}