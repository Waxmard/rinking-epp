import 'package:flutter/material.dart';
import '../design_system/design_system.dart';
import '../widgets/tiernerd_logo_text.dart';

class DesignSystemDemo extends StatefulWidget {
  const DesignSystemDemo({Key? key}) : super(key: key);

  @override
  State<DesignSystemDemo> createState() => _DesignSystemDemoState();
}

class _DesignSystemDemoState extends State<DesignSystemDemo> {
  bool _switchValue = false;
  bool _checkboxValue = false;
  String? _dropdownValue;
  final _textController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Design System Demo'),
        actions: [
          AppIconButton(
            icon: Icons.dark_mode,
            onPressed: () {
              // Toggle theme in a real app
            },
            tooltip: 'Toggle Theme',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: AppSpacing.screenHorizontal,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppSpacing.lg.vertical,
            
            // Typography Section
            _buildSection(
              'Typography',
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Display Large', style: AppTypography.displayLarge),
                  Text('Display Medium', style: AppTypography.displayMedium),
                  Text('Display Small', style: AppTypography.displaySmall),
                  AppSpacing.md.vertical,
                  Text('Headline Large', style: AppTypography.headlineLarge),
                  Text('Headline Medium', style: AppTypography.headlineMedium),
                  Text('Headline Small', style: AppTypography.headlineSmall),
                  AppSpacing.md.vertical,
                  Text('Title Large', style: AppTypography.titleLarge),
                  Text('Title Medium', style: AppTypography.titleMedium),
                  Text('Title Small', style: AppTypography.titleSmall),
                  AppSpacing.md.vertical,
                  Text('Body Large - Lorem ipsum dolor sit amet', style: AppTypography.bodyLarge),
                  Text('Body Medium - Lorem ipsum dolor sit amet', style: AppTypography.bodyMedium),
                  Text('Body Small - Lorem ipsum dolor sit amet', style: AppTypography.bodySmall),
                  AppSpacing.md.vertical,
                  Text('LABEL LARGE', style: AppTypography.labelLarge),
                  Text('LABEL MEDIUM', style: AppTypography.labelMedium),
                  Text('LABEL SMALL', style: AppTypography.labelSmall),
                ],
              ),
            ),
            
            // TierNerd Logo Text Styles Section
            _buildSection(
              'TierNerd Logo Text Styles',
              Container(
                padding: EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: AppBorders.lg,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'Style 1: Gradient Glow',
                      style: AppTypography.titleSmall.copyWith(
                        color: AppColors.textOnPrimary,
                      ),
                    ),
                    SizedBox(height: AppSpacing.md),
                    TierNerdLogoText.gradientGlow(fontSize: 36),
                    SizedBox(height: AppSpacing.xl),
                    
                    Text(
                      'Style 2: Split Style',
                      style: AppTypography.titleSmall.copyWith(
                        color: AppColors.textOnPrimary,
                      ),
                    ),
                    SizedBox(height: AppSpacing.md),
                    TierNerdLogoText.splitStyle(fontSize: 36),
                    SizedBox(height: AppSpacing.xl),
                    
                    Text(
                      'Style 3: Outlined',
                      style: AppTypography.titleSmall.copyWith(
                        color: AppColors.textOnPrimary,
                      ),
                    ),
                    SizedBox(height: AppSpacing.md),
                    TierNerdLogoText.outlined(fontSize: 36),
                    SizedBox(height: AppSpacing.xl),
                    
                    Text(
                      'Style 4: Tier Blocks',
                      style: AppTypography.titleSmall.copyWith(
                        color: AppColors.textOnPrimary,
                      ),
                    ),
                    SizedBox(height: AppSpacing.md),
                    TierNerdLogoText.tierBlocks(fontSize: 36),
                    SizedBox(height: AppSpacing.xl),
                    
                    Text(
                      'Style 5: Neon Glow',
                      style: AppTypography.titleSmall.copyWith(
                        color: AppColors.textOnPrimary,
                      ),
                    ),
                    SizedBox(height: AppSpacing.md),
                    TierNerdLogoText.neonGlow(fontSize: 36),
                    SizedBox(height: AppSpacing.xl),
                    
                    Text(
                      'Style 6: Retro Arcade',
                      style: AppTypography.titleSmall.copyWith(
                        color: AppColors.textOnPrimary,
                      ),
                    ),
                    SizedBox(height: AppSpacing.md),
                    TierNerdLogoText.retroArcade(fontSize: 36),
                    SizedBox(height: AppSpacing.xl),
                    
                    Text(
                      'Style 7: Minimal',
                      style: AppTypography.titleSmall.copyWith(
                        color: AppColors.textOnPrimary,
                      ),
                    ),
                    SizedBox(height: AppSpacing.md),
                    TierNerdLogoText.minimal(fontSize: 36),
                    SizedBox(height: AppSpacing.xl),
                    
                    Text(
                      'Style 8: Badge',
                      style: AppTypography.titleSmall.copyWith(
                        color: AppColors.textOnPrimary,
                      ),
                    ),
                    SizedBox(height: AppSpacing.md),
                    TierNerdLogoText.badge(fontSize: 36),
                  ],
                ),
              ),
            ),
            
            // Colors Section
            _buildSection(
              'Colors',
              Column(
                children: [
                  _buildColorRow('Primary', AppColors.primary),
                  _buildColorRow('Accent', AppColors.accent),
                  _buildColorRow('Success', AppColors.success),
                  _buildColorRow('Warning', AppColors.warning),
                  _buildColorRow('Error', AppColors.error),
                  AppSpacing.md.vertical,
                  Text('Tier Colors', style: AppTypography.titleMedium),
                  AppSpacing.sm.vertical,
                  Wrap(
                    spacing: AppSpacing.sm,
                    runSpacing: AppSpacing.sm,
                    children: ['S', 'A', 'B', 'C', 'D', 'F'].map((tier) {
                      final color = AppColors.getTierColor(tier);
                      return Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: color,
                          borderRadius: AppBorders.md,
                          boxShadow: [AppShadows.colored(color)],
                        ),
                        child: Center(
                          child: Text(
                            tier,
                            style: AppTypography.headlineMedium.copyWith(
                              color: AppColors.getContrastText(color),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            
            // Buttons Section
            _buildSection(
              'Buttons',
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Variants', style: AppTypography.titleSmall),
                  AppSpacing.sm.vertical,
                  Wrap(
                    spacing: AppSpacing.sm,
                    runSpacing: AppSpacing.sm,
                    children: [
                      AppButton(
                        label: 'Primary',
                        onPressed: () {},
                        variant: AppButtonVariant.primary,
                      ),
                      AppButton(
                        label: 'Secondary',
                        onPressed: () {},
                        variant: AppButtonVariant.secondary,
                      ),
                      AppButton(
                        label: 'Outline',
                        onPressed: () {},
                        variant: AppButtonVariant.outline,
                      ),
                      AppButton(
                        label: 'Text',
                        onPressed: () {},
                        variant: AppButtonVariant.text,
                      ),
                      AppButton(
                        label: 'Danger',
                        onPressed: () {},
                        variant: AppButtonVariant.danger,
                      ),
                    ],
                  ),
                  AppSpacing.lg.vertical,
                  Text('Sizes', style: AppTypography.titleSmall),
                  AppSpacing.sm.vertical,
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppButton(
                        label: 'Small Button',
                        onPressed: () {},
                        size: AppButtonSize.small,
                      ),
                      AppSpacing.sm.vertical,
                      AppButton(
                        label: 'Medium Button',
                        onPressed: () {},
                        size: AppButtonSize.medium,
                      ),
                      AppSpacing.sm.vertical,
                      AppButton(
                        label: 'Large Button',
                        onPressed: () {},
                        size: AppButtonSize.large,
                      ),
                    ],
                  ),
                  AppSpacing.lg.vertical,
                  Text('States', style: AppTypography.titleSmall),
                  AppSpacing.sm.vertical,
                  Wrap(
                    spacing: AppSpacing.sm,
                    runSpacing: AppSpacing.sm,
                    children: [
                      AppButton(
                        label: 'Enabled',
                        onPressed: () {},
                      ),
                      const AppButton(
                        label: 'Disabled',
                        onPressed: null,
                      ),
                      AppButton(
                        label: 'Loading',
                        onPressed: () {},
                        isLoading: true,
                      ),
                      AppButton(
                        label: 'With Icon',
                        onPressed: () {},
                        icon: Icons.add,
                      ),
                    ],
                  ),
                  AppSpacing.lg.vertical,
                  Text('Full Width', style: AppTypography.titleSmall),
                  AppSpacing.sm.vertical,
                  AppButton(
                    label: 'Full Width Button',
                    onPressed: () {},
                    fullWidth: true,
                  ),
                ],
              ),
            ),
            
            // Cards Section
            _buildSection(
              'Cards',
              Column(
                children: [
                  AppCard(
                    variant: AppCardVariant.elevated,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Elevated Card', style: AppTypography.titleMedium),
                        AppSpacing.sm.vertical,
                        Text(
                          'This is an elevated card with shadow effects.',
                          style: AppTypography.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                  AppCard(
                    variant: AppCardVariant.filled,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Filled Card', style: AppTypography.titleMedium),
                        AppSpacing.sm.vertical,
                        Text(
                          'This is a filled card without shadow.',
                          style: AppTypography.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                  AppCard(
                    variant: AppCardVariant.outlined,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Outlined Card', style: AppTypography.titleMedium),
                        AppSpacing.sm.vertical,
                        Text(
                          'This is an outlined card with border.',
                          style: AppTypography.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                  AppListCard(
                    leading: const CircleAvatar(
                      child: Icon(Icons.person),
                    ),
                    title: 'List Card Title',
                    subtitle: 'Supporting text that provides more detail',
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () {},
                  ),
                  AppTierCard(
                    tier: 'S',
                    label: 'Top',
                    children: [
                      Chip(label: Text('Item 1')),
                      Chip(label: Text('Item 2')),
                      Chip(label: Text('Item 3')),
                    ],
                  ),
                ],
              ),
            ),
            
            // Inputs Section
            _buildSection(
              'Inputs',
              Column(
                children: [
                  AppTextField(
                    label: 'Text Field',
                    hint: 'Enter some text',
                    controller: _textController,
                  ),
                  AppSpacing.md.vertical,
                  AppTextField(
                    label: 'Password Field',
                    hint: 'Enter password',
                    obscureText: true,
                    suffix: Icon(Icons.visibility_off),
                  ),
                  AppSpacing.md.vertical,
                  AppTextField(
                    label: 'Error Field',
                    hint: 'This field has an error',
                    errorText: 'This is an error message',
                  ),
                  AppSpacing.md.vertical,
                  AppDropdown<String>(
                    label: 'Dropdown',
                    hint: 'Select an option',
                    value: _dropdownValue,
                    onChanged: (value) {
                      setState(() {
                        _dropdownValue = value;
                      });
                    },
                    items: ['Option 1', 'Option 2', 'Option 3']
                        .map((e) => DropdownMenuItem(
                              value: e,
                              child: Text(e),
                            ))
                        .toList(),
                  ),
                  AppSpacing.md.vertical,
                  AppSwitch(
                    label: 'Switch Option',
                    value: _switchValue,
                    onChanged: (value) {
                      setState(() {
                        _switchValue = value;
                      });
                    },
                  ),
                  AppSpacing.md.vertical,
                  AppCheckbox(
                    label: 'Checkbox Option',
                    value: _checkboxValue,
                    onChanged: (value) {
                      setState(() {
                        _checkboxValue = value ?? false;
                      });
                    },
                  ),
                ],
              ),
            ),
            
            // Spacing Section
            _buildSection(
              'Spacing',
              Row(
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        _buildSpacingExample('xxs', AppSpacing.xxs),
                        _buildSpacingExample('xs', AppSpacing.xs),
                        _buildSpacingExample('sm', AppSpacing.sm),
                        _buildSpacingExample('md', AppSpacing.md),
                        _buildSpacingExample('lg', AppSpacing.lg),
                        _buildSpacingExample('xl', AppSpacing.xl),
                        _buildSpacingExample('xxl', AppSpacing.xxl),
                        _buildSpacingExample('xxxl', AppSpacing.xxxl),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            AppSpacing.xxxl.vertical,
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {},
        label: const Text('Action'),
        icon: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildSection(String title, Widget content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: AppTypography.headlineMedium),
        AppSpacing.md.vertical,
        content,
        AppSpacing.xl.vertical,
        const Divider(),
        AppSpacing.xl.vertical,
      ],
    );
  }

  Widget _buildColorRow(String name, Color color) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 40,
            decoration: BoxDecoration(
              color: color,
              borderRadius: AppBorders.sm,
              boxShadow: [AppShadows.sm],
            ),
          ),
          AppSpacing.md.horizontal,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: AppTypography.titleSmall),
                Text(
                  '#${color.value.toRadixString(16).substring(2).toUpperCase()}',
                  style: AppTypography.caption.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSpacingExample(String name, double spacing) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        children: [
          SizedBox(
            width: 60,
            child: Text(name, style: AppTypography.labelSmall),
          ),
          Container(
            width: spacing,
            height: 20,
            color: AppColors.primary,
          ),
          AppSpacing.sm.horizontal,
          Text('${spacing.toInt()}px', style: AppTypography.caption),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }
}