import 'dart:async';
import 'dart:math' show sin;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../utils/responsive_helper.dart';
import '../utils/app_theme.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with TickerProviderStateMixin {
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
      duration: const Duration(milliseconds: 1000),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeIn,
      ),
    );
    _animationController.forward();

    // Phrase animation setup
    _phraseAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _phraseOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _phraseAnimationController,
        curve: Curves.easeInOut,
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
        curve: Curves.easeInOut,
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
    final isSmallScreen = ResponsiveHelper.isMobile(context);

    return Scaffold(
      backgroundColor: AppTheme.primaryColor, // Use the theme color
      body: Container(
        color: AppTheme.primaryColor, // Use theme color
        child: isSmallScreen
            ? _buildMobileLayout(context)
            : _buildDesktopLayout(context),
      ),
    );
  }

  Widget _buildMobileLayout(BuildContext context) {
    return SafeArea(
      child: Container(
        decoration: BoxDecoration(
          // Add subtle gradient background
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppTheme.primaryColor,
              AppTheme.primaryColor.withOpacity(0.8),
            ],
          ),
        ),
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
                  decoration: BoxDecoration(
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
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            // Add animated floating elements
            _buildAnimatedFloatingElements(),
            // Main content
            SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 60),
                      _buildLogo(size: 180), // Slightly smaller logo
                      const SizedBox(height: 40),
                      _buildTitle(),
                      const SizedBox(height: 50),
                      _buildLoginButton(),
                      const SizedBox(height: 30),
                      _buildSignUpText(),
                      const SizedBox(height: 40),
                      _buildAppVersion(), // Add version number
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDesktopLayout(BuildContext context) {
    return SafeArea(
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [
              AppTheme.primaryColor.withOpacity(0.9),
              AppTheme.primaryColor,
            ],
          ),
        ),
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
                  decoration: BoxDecoration(
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
                  decoration: BoxDecoration(
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
                  child: Container(
                    child: Center(
                      child: FadeTransition(
                        opacity: _fadeAnimation,
                        child: _buildLogo(size: 240),
                      ),
                    ),
                  ),
                ),
                // Right side with login form (60% width)
                Expanded(
                  flex: 6,
                  child: SingleChildScrollView(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 80),
                      constraints: const BoxConstraints(maxWidth: 600),
                      child: FadeTransition(
                        opacity: _fadeAnimation,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const SizedBox(height: 80),
                            _buildTitle(isLarge: true),
                            const SizedBox(height: 60),
                            _buildLoginButton(),
                            const SizedBox(height: 40),
                            _buildSignUpText(),
                            const SizedBox(height: 40),
                            _buildAppVersion(),
                            const SizedBox(height: 60),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildAppVersion() {
    return Align(
      alignment: Alignment.center,
      child: Text(
        'v1.0.0 • Tier Nerd',
        style: TextStyle(
          color: Colors.white.withOpacity(0.5),
          fontSize: 12,
        ),
      ),
    );
  }
  
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
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: AppTheme.primaryColor,
                size: size * 0.6,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildLogo({double size = 200}) {
    return Hero(
      tag: 'app_logo',
      child: Image.asset(
        'assets/images/tier-nerd-logo-0.png',
        width: size,
        height: size,
        fit: BoxFit.contain,
      ),
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
                width: isLarge ? 500 : double.infinity, // Control width based on screen size
                height: isLarge ? 40 : 30, // Fixed height for consistent spacing
                child: FittedBox(
                  fit: BoxFit.scaleDown, // Scale down to fit the space
                  alignment: Alignment.centerLeft, // Align left
                  child: Text(
                    _currentPhrase,
                    style: GoogleFonts.montserrat(
                      fontSize: isLarge ? 28 : 22, // Starting font size (will scale down if needed)
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
        // SizedBox(height: isLarge ? 12 : 8),
      ],
    );
  }

  Widget _buildEmailField() {
    return TextField(
      controller: _emailController,
      keyboardType: TextInputType.emailAddress,
      style: TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: 'Email',
        labelStyle: TextStyle(color: Colors.white.withOpacity(0.8)),
        hintText: 'name@example.com',
        hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
        prefixIcon: const Icon(Icons.email_outlined, color: Colors.white),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.4)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.white, width: 2),
        ),
        filled: true,
        fillColor: Colors.white.withOpacity(0.1),
      ),
    );
  }

  Widget _buildPasswordField() {
    return TextField(
      controller: _passwordController,
      obscureText: !_passwordVisible,
      style: TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: 'Password',
        labelStyle: TextStyle(color: Colors.white.withOpacity(0.8)),
        hintText: '••••••••',
        hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
        prefixIcon: const Icon(Icons.lock_outline, color: Colors.white),
        suffixIcon: IconButton(
          icon: Icon(
            _passwordVisible ? Icons.visibility : Icons.visibility_off,
            color: Colors.white,
          ),
          onPressed: () {
            setState(() {
              _passwordVisible = !_passwordVisible;
            });
          },
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.4)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.white, width: 2),
        ),
        filled: true,
        fillColor: Colors.white.withOpacity(0.1),
      ),
    );
  }

  Widget _buildForgotPassword() {
    return Align(
      alignment: Alignment.centerRight,
      child: TextButton(
        onPressed: () {
          // Handle forgot password
        },
        style: TextButton.styleFrom(
          foregroundColor: Colors.white,
          padding: EdgeInsets.zero,
          minimumSize: const Size(0, 36),
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
        child: const Text('Forgot Password?'),
      ),
    );
  }

  Widget _buildLoginButton() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Email field
        _buildEmailField(),
        const SizedBox(height: 16),
        // Password field
        _buildPasswordField(),
        const SizedBox(height: 8),
        // Forgot password link
        _buildForgotPassword(),
        const SizedBox(height: 20),
        // Email login button
        _buildEmailLoginButton(),
        const SizedBox(height: 20),
        // OR divider
        _buildOrDivider(),
        const SizedBox(height: 20),
        // Google sign-in button
        _buildGoogleSignInButton(),
      ],
    );
  }
  
  Widget _buildEmailLoginButton() {
    return Consumer<AuthProvider>(
      builder: (context, auth, child) {
        return SizedBox(
          width: double.infinity,
          height: 54,
          child: ElevatedButton(
            onPressed: auth.isLoading
                ? null
                : () async {
                    // Handle email login using the same mock setup
                    print("Email login button pressed");
                    
                    // Check if the email fields have some text
                    if (_emailController.text.isNotEmpty && _passwordController.text.isNotEmpty) {
                      try {
                        // Use Google auth as mock for now
                        final success = await auth.signInWithGoogle();
                        if (success) {
                          // Navigate to home screen
                          Navigator.of(context).pushReplacementNamed('/home');
                        } else if (auth.error != null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Error: ${auth.error}')),
                          );
                        }
                      } catch (e) {
                        print("Error during sign in: $e");
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Error: $e')),
                        );
                      }
                    } else {
                      // Show error if fields are empty
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Please fill in both email and password')),
                      );
                    }
                  },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: AppTheme.primaryColor,
              elevation: 1,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: auth.isLoading
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.grey),
                    ),
                  )
                : const Text(
                    'Log In',
                    style: TextStyle(
                      fontSize: 18,
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
            color: Colors.white.withOpacity(0.3),
            thickness: 1,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'OR',
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          child: Divider(
            color: Colors.white.withOpacity(0.3),
            thickness: 1,
          ),
        ),
      ],
    );
  }

  Widget _buildGoogleSignInButton() {
    return Consumer<AuthProvider>(
      builder: (context, auth, child) {
        return SizedBox(
          width: double.infinity, // Full width
          height: 60, // Increased from 50 to 60
          child: ElevatedButton.icon(
            onPressed: auth.isLoading
                ? null
                : () async {
                    print("Google sign-in button pressed");
                    try {
                      final success = await auth.signInWithGoogle();
                      if (success) {
                        // Navigate to home screen
                        Navigator.of(context).pushReplacementNamed('/home');
                      } else if (auth.error != null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Error: ${auth.error}')),
                        );
                      }
                    } catch (e) {
                      print("Error during sign in: $e");
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error: $e')),
                      );
                    }
                  },
            icon: auth.isLoading
                ? const SizedBox(
                    width: 28, // Slightly larger
                    height: 28, // Slightly larger
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.grey),
                    ),
                  )
                : Image.asset(
                    'assets/images/google_logo-removebg-preview.png',
                    width: 28, // Larger from 24 to 28
                    height: 28, // Larger from 24 to 28
                  ),
            label: Text(
              auth.isLoading ? 'Signing in...' : 'Sign in with Google',
              style: const TextStyle(
                color: Colors.black87,
                fontSize: 18, // Larger from 16 to 18
                fontWeight: FontWeight.w500,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.black87,
              elevation: 1, // Slight elevation for better visibility
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: const BorderSide(color: Colors.black12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15), // Increased padding
            ),
          ),
        );
      },
    );
  }

  Widget _buildSignUpText() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: Colors.white.withOpacity(0.1), width: 1),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "Don't have an account? ",
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 14,
            ),
          ),
          GestureDetector(
            onTap: () {
              // Handle sign up
            },
            child: Text(
              'Sign Up',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
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
