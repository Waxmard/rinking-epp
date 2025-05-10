import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/responsive_helper.dart';

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

    // Initialize the current phrase and make it visible immediately
    _updatePhrase();
    _phraseAnimationController.value = 1.0; // Start with first phrase fully visible

    // Set up timer to change phrases every 3 seconds
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

  // Method to get a random phrase that's different from the last one
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
    _phraseTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isSmallScreen = ResponsiveHelper.isMobile(context);

    return Scaffold(
      body: Container(
        color: Color(0xFF5B4B89), // Exact logo background color
        child: isSmallScreen
            ? _buildMobileLayout(context)
            : _buildDesktopLayout(context),
      ),
    );
  }

  Widget _buildMobileLayout(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 50),
                _buildLogo(),
                const SizedBox(height: 40),
                _buildTitle(),
                const SizedBox(height: 32),
                _buildEmailField(),
                const SizedBox(height: 16),
                _buildPasswordField(),
                const SizedBox(height: 8),
                _buildForgotPassword(),
                const SizedBox(height: 32),
                _buildLoginButton(),
                const SizedBox(height: 24),
                _buildSignUpText(),
                const SizedBox(height: 60),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDesktopLayout(BuildContext context) {
    return SafeArea(
      child: Row(
        children: [
          // Left side with image or pattern (30% width)
          Expanded(
            flex: 3,
            child: Container(
              // Already using logo background color
              child: Center(
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: _buildLogo(size: 260),
                ),
              ),
            ),
          ),
          // Right side with login form (70% width)
          Expanded(
            flex: 7,
            child: SingleChildScrollView(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 80),
                constraints: const BoxConstraints(maxWidth: 800),
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 100),
                      _buildTitle(isLarge: true),
                      const SizedBox(height: 48),
                      _buildEmailField(),
                      const SizedBox(height: 24),
                      _buildPasswordField(),
                      const SizedBox(height: 12),
                      _buildForgotPassword(),
                      const SizedBox(height: 48),
                      _buildLoginButton(),
                      const SizedBox(height: 32),
                      _buildSignUpText(),
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogo({double size = 300}) {
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
              child: Container(
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
    return ElevatedButton(
      onPressed: () {
        // Handle login
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: Color(0xFF5B4B89),
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        elevation: 0,
      ),
      child: Text(
        'SIGN IN',
        style: GoogleFonts.montserrat(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildSignUpText() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "Don't have an account? ",
          style: TextStyle(
            color: Colors.white.withOpacity(0.8),
          ),
        ),
        GestureDetector(
          onTap: () {
            // Handle sign up
          },
          child: Text(
            'Sign Up',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}
