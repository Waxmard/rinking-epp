import 'dart:async';
import 'dart:math' show sin;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../design_system/design_system.dart';
import '../widgets/tiernerd_logo_text.dart';

class LoginScreenUpdated extends StatefulWidget {
  const LoginScreenUpdated({super.key});

  @override
  State<LoginScreenUpdated> createState() => _LoginScreenUpdatedState();
}

class _LoginScreenUpdatedState extends State<LoginScreenUpdated> with TickerProviderStateMixin {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  bool _passwordVisible = false;

  // Animation controllers for phrase transitions
  late AnimationController _phraseAnimationController;
  late Animation<double> _phraseOpacity;

  // Animation for floating elements
  late AnimationController _floatingElementController;
  late Animation<double> _floatingAnimation;

  // Current phrase to display
  String _currentPhrase = '';

  // Track previous phrase to avoid repeats
  String? _previousPhrase;

  // Timer for phrase changes
  Timer? _phraseTimer;

  // List of login phrases
  final List<String> _loginPhrases = [
    'Time to Create Tiers',
    'Let\'s Make Some Lists',
    'Ready to Rank?',
    'Face Off Your Favorites',
    'What\'s Really Number One?',
    'Your Lists, Perfected',
    'Organize Your Opinions',
    'Reveal Your Rankings',
    'Time For A Tier Check',
    'Let The Ranking Begin',
    'Unleash Your Inner Critic',
    'The Nerdy Way To Rank',
    'Your Tier Journey Awaits',
  ];

  @override
  void initState() {
    super.initState();

    // Screen fade-in animation
    _animationController = AnimationController(
      vsync: this,
      duration: AppAnimations.durationSlow,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: AppAnimations.curveEaseIn,
      ),
    );
    _animationController.forward();

    // Phrase animation setup
    _phraseAnimationController = AnimationController(
      vsync: this,
      duration: AppAnimations.durationVerySlow,
    );
    _phraseOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _phraseAnimationController,
        curve: AppAnimations.curveEaseInOut,
      ),
    );

    // Floating elements animation setup
    _floatingElementController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );
    _floatingAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _floatingElementController,
        curve: AppAnimations.curveEaseInOut,
      ),
    );
    _floatingElementController.repeat(reverse: true);

    // Initialize the current phrase and make it visible immediately
    _updatePhrase();
    _phraseAnimationController.value = 1.0; // Start with first phrase fully visible

    // Set up timer to change phrases every 5 seconds
    _phraseTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      _changePhrase();
    });
  }

  // Method to handle the phrase transition
  void _changePhrase() {
    // Start fade out
    _phraseAnimationController.reverse().then((_) {
      // When fade out is complete, update the phrase
      _updatePhrase();
      // Start fade in
      _phraseAnimationController.forward();
    });
  }

  // Update the current phrase
  void _updatePhrase() {
    setState(() {
      _currentPhrase = _getRandomPhrase();
      _previousPhrase = _currentPhrase; // Store for next time
    });
  }

  // Update title text shown on login screen
  String _getRandomPhrase() {
    // If we only have one phrase, just return it
    if (_loginPhrases.length <= 1) {
      return _loginPhrases[0];
    }

    // Create a copy of the phrases list
    final availablePhrases = List<String>.from(_loginPhrases);

    // Remove previous phrase to avoid repetition
    if (_previousPhrase != null) {
      availablePhrases.remove(_previousPhrase);
    }

    // Pick a random phrase from the remaining ones
    final random = DateTime.now().millisecondsSinceEpoch % availablePhrases.length;
    return availablePhrases[random];
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _animationController.dispose();
    _phraseAnimationController.dispose();
    _floatingElementController.dispose();
    _phraseTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isSmallScreen = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.primaryGradient,
        ),
        child: isSmallScreen
            ? _buildMobileLayout(context)
            : _buildDesktopLayout(context),
      ),
    );
  }

  Widget _buildMobileLayout(BuildContext context) {
    return SafeArea(
      child: Stack(
        children: [
          // Add decorative background elements
          Positioned(
            top: -50,
            right: -50,
            child: Opacity(
              opacity: 0.1,
              child: Container(
                height: 200,
                width: 200,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          Positioned(
            bottom: -80,
            left: -80,
            child: Opacity(
              opacity: 0.08,
              child: Container(
                height: 250,
                width: 250,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          // Add animated floating elements
          _buildAnimatedFloatingElements(),
          // Main content - adaptive scrolling
          LayoutBuilder(
            builder: (context, constraints) {
              final content = Padding(
                padding: AppSpacing.screenHorizontal,
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildLogo(size: 200),
                      SizedBox(height: AppSpacing.xs),
                      _buildTitle(),
                      SizedBox(height: AppSpacing.md),
                      _buildLoginForm(),
                      SizedBox(height: AppSpacing.sm),
                      _buildSignUpText(),
                      SizedBox(height: AppSpacing.xs),
                      _buildAppVersion(),
                    ],
                  ),
                ),
              );
              
              // If content is too tall, make it scrollable
              // Otherwise keep it centered and non-scrollable
              return constraints.maxHeight < 800
                  ? SingleChildScrollView(
                      child: SizedBox(
                        height: constraints.maxHeight,
                        child: content,
                      ),
                    )
                  : content;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopLayout(BuildContext context) {
    return SafeArea(
      child: Stack(
        children: [
          // Decorative elements
          Positioned(
            top: -100,
            left: -100,
            child: Opacity(
              opacity: 0.05,
              child: Container(
                height: 300,
                width: 300,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          Positioned(
            bottom: -150,
            right: -150,
            child: Opacity(
              opacity: 0.08,
              child: Container(
                height: 400,
                width: 400,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          // Add animated floating elements
          _buildAnimatedFloatingElements(isDesktop: true),
          // Main content
          Row(
            children: [
              // Left side with logo (40% width)
              Expanded(
                flex: 4,
                child: Center(
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: _buildLogo(size: 100), // Smaller for desktop too
                  ),
                ),
              ),
              // Right side with login form (60% width)
              Expanded(
                flex: 6,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: AppSpacing.responsive(
                    context,
                    mobile: AppSpacing.xl,
                    tablet: AppSpacing.xxxl,
                    desktop: 80,
                  )),
                  constraints: const BoxConstraints(maxWidth: 600),
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildTitle(isLarge: true),
                        SizedBox(height: AppSpacing.xxxl),
                        _buildLoginForm(),
                        SizedBox(height: AppSpacing.xl),
                        _buildSignUpText(),
                        SizedBox(height: AppSpacing.md),
                        _buildAppVersion(),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAppVersion() {
    return GestureDetector(
      onTap: () {
        // Triple tap to access dev menu
        _devTapCount++;
        if (_devTapCount >= 3) {
          _devTapCount = 0;
          Navigator.pushNamed(context, '/dev-menu');
        }
        // Reset tap count after 2 seconds
        Future.delayed(const Duration(seconds: 2), () {
          _devTapCount = 0;
        });
      },
      child: Container(
        padding: EdgeInsets.all(AppSpacing.md),
        color: Colors.transparent,
        child: Text(
          'v1.0.0 • Tier Nerd',
          style: AppTypography.caption.copyWith(
            color: AppColors.textOnPrimary.withOpacity(0.5),
          ),
        ),
      ),
    );
  }

  int _devTapCount = 0;

  Widget _buildAnimatedFloatingElements({bool isDesktop = false}) {
    // Adjust positions based on layout
    final positions = isDesktop
        ? [
            Positioned(top: 80, right: 100, child: _buildFloatingElement(0.06, 30, Icons.star)),
            Positioned(top: 200, left: 80, child: _buildFloatingElement(0.08, 20, Icons.filter_list)),
            Positioned(bottom: 120, right: 180, child: _buildFloatingElement(0.07, 25, Icons.format_list_numbered)),
            Positioned(bottom: 240, left: 200, child: _buildFloatingElement(0.05, 35, Icons.leaderboard)),
            Positioned(top: 350, right: 240, child: _buildFloatingElement(0.06, 20, Icons.sort)),
          ]
        : [
            Positioned(top: 40, right: 30, child: _buildFloatingElement(0.06, 25, Icons.star)),
            Positioned(bottom: 180, left: 20, child: _buildFloatingElement(0.08, 20, Icons.filter_list)),
            Positioned(bottom: 100, right: 50, child: _buildFloatingElement(0.07, 22, Icons.format_list_numbered)),
            Positioned(top: 300, left: 40, child: _buildFloatingElement(0.05, 30, Icons.leaderboard)),
          ];

    return Stack(children: positions);
  }

  Widget _buildFloatingElement(double opacity, double size, IconData icon) {
    return AnimatedBuilder(
      animation: _floatingAnimation,
      builder: (context, child) {
        // Create subtle floating movement
        final offset = 5.0 * _floatingAnimation.value;

        return Transform.translate(
          offset: Offset(0, sin(_floatingAnimation.value * 2 * 3.14159) * offset),
          child: Opacity(
            opacity: opacity,
            child: Container(
              width: size,
              height: size,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: AppColors.primary,
                size: size * 0.6,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildLogo({double size = 200}) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // TierNerd text with minimal style
        TierNerdLogoText.minimal(fontSize: 36),
        SizedBox(height: AppSpacing.sm),
        // Animated logo - fixed small size
        Hero(
          tag: 'app_logo',
          child: Image.asset(
            'assets/images/logo-transparent.png',
            width: 300,
            height: 180,
            fit: BoxFit.contain,
          ),
        ),
      ],
    );
  }

  Widget _buildTitle({bool isLarge = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Animate the phrase with fade in/out
        AnimatedBuilder(
          animation: _phraseOpacity,
          builder: (context, child) {
            return Opacity(
              opacity: _phraseOpacity.value,
              child: SizedBox(
                width: isLarge ? 500 : double.infinity,
                height: isLarge ? 40 : 30,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    _currentPhrase,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildLoginForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Email field with custom theming for login
        _ThemedTextField(
          controller: _emailController,
          label: 'Email',
          hint: 'name@example.com',
          prefixIcon: Icons.email_outlined,
          keyboardType: TextInputType.emailAddress,
        ),
        SizedBox(height: AppSpacing.md),

        // Password field with custom theming for login
        _ThemedTextField(
          controller: _passwordController,
          label: 'Password',
          hint: '••••••••',
          prefixIcon: Icons.lock_outline,
          obscureText: !_passwordVisible,
          suffix: IconButton(
            icon: Icon(
              _passwordVisible ? Icons.visibility : Icons.visibility_off,
              color: AppColors.textOnPrimary,
            ),
            onPressed: () {
              setState(() {
                _passwordVisible = !_passwordVisible;
              });
            },
          ),
        ),
        SizedBox(height: AppSpacing.xs),

        // Forgot password link
        _buildForgotPassword(),
        SizedBox(height: AppSpacing.sm),

        // Email login button with design system
        _buildEmailLoginButton(),
        SizedBox(height: AppSpacing.lg),

        // OR divider
        _buildOrDivider(),
        SizedBox(height: AppSpacing.lg),

        // Google sign-in button
        _buildGoogleSignInButton(),
      ],
    );
  }

  Widget _buildForgotPassword() {
    return Align(
      alignment: Alignment.centerRight,
      child: AppButton(
        label: 'Forgot Password?',
        onPressed: () {
          // Handle forgot password
        },
        variant: AppButtonVariant.text,
        size: AppButtonSize.small,
      ),
    );
  }

  Widget _buildEmailLoginButton() {
    return Consumer<AuthProvider>(
      builder: (context, auth, child) {
        return SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton(
            onPressed: auth.isLoading
                ? null
                : () async {
                    // Handle email login
                    if (_emailController.text.isNotEmpty && _passwordController.text.isNotEmpty) {
                      try {
                        // Use Google auth as mock for now
                        final success = await auth.signInWithGoogle();
                        if (success) {
                          // Navigate to home screen
                          Navigator.of(context).pushReplacementNamed('/home');
                        } else if (auth.error != null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Error: ${auth.error}'),
                              backgroundColor: AppColors.error,
                            ),
                          );
                        }
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Error: $e'),
                            backgroundColor: AppColors.error,
                          ),
                        );
                      }
                    } else {
                      // Show error if fields are empty
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Please fill in both email and password'),
                          backgroundColor: AppColors.warning,
                        ),
                      );
                    }
                  },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: AppColors.primary,
              disabledBackgroundColor: Colors.white.withOpacity(0.5),
              disabledForegroundColor: AppColors.primary.withOpacity(0.5),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: AppBorders.md,
              ),
              padding: EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.md,
              ),
            ),
            child: auth.isLoading
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                    ),
                  )
                : Text(
                    'Log In',
                    style: AppTypography.button.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
        );
      },
    );
  }

  Widget _buildOrDivider() {
    return Row(
      children: [
        Expanded(
          child: Divider(
            color: AppColors.textOnPrimary.withOpacity(0.3),
            thickness: AppBorders.widthThin,
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
          child: Text(
            'OR',
            style: AppTypography.labelMedium.copyWith(
              color: AppColors.textOnPrimary.withOpacity(0.8),
            ),
          ),
        ),
        Expanded(
          child: Divider(
            color: AppColors.textOnPrimary.withOpacity(0.3),
            thickness: AppBorders.widthThin,
          ),
        ),
      ],
    );
  }

  Widget _buildGoogleSignInButton() {
    return Consumer<AuthProvider>(
      builder: (context, auth, child) {
        return SizedBox(
          width: double.infinity,
          height: 54,
          child: ElevatedButton.icon(
            onPressed: auth.isLoading
                ? null
                : () async {
                    try {
                      final success = await auth.signInWithGoogle();
                      if (success) {
                        // Navigate to home screen
                        Navigator.of(context).pushReplacementNamed('/home');
                      } else if (auth.error != null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Error: ${auth.error}'),
                            backgroundColor: AppColors.error,
                          ),
                        );
                      }
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Error: $e'),
                          backgroundColor: AppColors.error,
                        ),
                      );
                    }
                  },
            icon: auth.isLoading
                ? SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(AppColors.neutral),
                    ),
                  )
                : Image.asset(
                    'assets/images/google_logo-removebg-preview.png',
                    width: 24,
                    height: 24,
                  ),
            label: Text(
              auth.isLoading ? 'Signing in...' : 'Sign in with Google',
              style: AppTypography.button.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.surfaceLight,
              foregroundColor: AppColors.textPrimary,
              elevation: AppShadows.elevationXs,
              shape: RoundedRectangleBorder(
                borderRadius: AppBorders.md,
                side: BorderSide(color: AppColors.neutral[300]!),
              ),
              padding: EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.md,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSignUpText() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: AppColors.textOnPrimary.withOpacity(0.1),
            width: AppBorders.widthThin,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "Don't have an account? ",
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textOnPrimary.withOpacity(0.8),
            ),
          ),
          GestureDetector(
            onTap: () {
              // Handle sign up
            },
            child: Text(
              'Sign Up',
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textOnPrimary,
                fontWeight: FontWeight.bold,
                decoration: TextDecoration.underline,
                decorationThickness: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

}

// Custom themed text field for login screen
class _ThemedTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData prefixIcon;
  final Widget? suffix;
  final bool obscureText;
  final TextInputType? keyboardType;

  const _ThemedTextField({
    required this.controller,
    required this.label,
    required this.hint,
    required this.prefixIcon,
    this.suffix,
    this.obscureText = false,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      style: AppTypography.bodyMedium.copyWith(color: AppColors.textOnPrimary),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: AppTypography.bodyMedium.copyWith(
          color: AppColors.textOnPrimary.withOpacity(0.8),
        ),
        hintText: hint,
        hintStyle: AppTypography.bodyMedium.copyWith(
          color: AppColors.textOnPrimary.withOpacity(0.5),
        ),
        prefixIcon: Icon(prefixIcon, color: AppColors.textOnPrimary),
        suffixIcon: suffix,
        enabledBorder: OutlineInputBorder(
          borderRadius: AppBorders.md,
          borderSide: BorderSide(
            color: AppColors.textOnPrimary.withOpacity(0.4),
            width: AppBorders.widthThin,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppBorders.md,
          borderSide: BorderSide(
            color: AppColors.textOnPrimary,
            width: AppBorders.widthMedium,
          ),
        ),
        filled: true,
        fillColor: AppColors.textOnPrimary.withOpacity(0.1),
        contentPadding: EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.md,
        ),
      ),
    );
  }
}
