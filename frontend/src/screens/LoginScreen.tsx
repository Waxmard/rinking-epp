import React, { useEffect, useRef, useState } from 'react';
import {
  View,
  Text,
  StyleSheet,
  Animated,
  Dimensions,
  Image,
  TouchableOpacity,
  ScrollView,
  KeyboardAvoidingView,
  Platform,
  ActivityIndicator,
} from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';
import { LinearGradient } from 'expo-linear-gradient';
import { Ionicons } from '@expo/vector-icons';
import { useNavigation } from '@react-navigation/native';
import { useAuth } from '../providers/AuthContext';
import { Button, Input } from '../design-system/components';
import { AppColors, AppSpacing, AppTypography, AppBorders } from '../design-system/tokens';

const { width: screenWidth } = Dimensions.get('window');

const loginPhrases = [
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

interface LoginScreenProps {
  navigation?: any;
}

export const LoginScreen: React.FC<LoginScreenProps> = ({ navigation }) => {
  const { signInWithGoogle, isLoading, error } = useAuth();
  
  // Form state
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [passwordVisible, setPasswordVisible] = useState(false);
  
  // Animation values
  const fadeAnim = useRef(new Animated.Value(0)).current;
  const phraseOpacity = useRef(new Animated.Value(1)).current;
  const floatingAnim = useRef(new Animated.Value(0)).current;
  
  // Phrase state
  const [currentPhrase, setCurrentPhrase] = useState(loginPhrases[0]);
  const [phraseIndex, setPhraseIndex] = useState(0);

  const changePhrase = () => {
    Animated.timing(phraseOpacity, {
      toValue: 0,
      duration: 400,
      useNativeDriver: true,
    }).start(() => {
      setPhraseIndex((prevIndex) => (prevIndex + 1) % loginPhrases.length);
      setCurrentPhrase(loginPhrases[(phraseIndex + 1) % loginPhrases.length]);
      
      Animated.timing(phraseOpacity, {
        toValue: 1,
        duration: 400,
        useNativeDriver: true,
      }).start();
    });
  };

  useEffect(() => {
    // Start fade in animation
    Animated.timing(fadeAnim, {
      toValue: 1,
      duration: 1000,
      useNativeDriver: true,
    }).start();

    // Start floating animation
    Animated.loop(
      Animated.sequence([
        Animated.timing(floatingAnim, {
          toValue: 1,
          duration: 2000,
          useNativeDriver: true,
        }),
        Animated.timing(floatingAnim, {
          toValue: 0,
          duration: 2000,
          useNativeDriver: true,
        }),
      ])
    ).start();

    // Phrase rotation timer
    const phraseTimer = setInterval(() => {
      changePhrase();
    }, 5000);

    return () => clearInterval(phraseTimer);
  }, []);

  const handleGoogleSignIn = async () => {
    console.log('Google sign in initiated'); // Debug log
    const success = await signInWithGoogle();
    if (success) {
      console.log('Sign in successful'); // Debug log
      navigation?.replace('Main');
    }
  };

  const handleEmailSignIn = async () => {
    console.log('Email sign in initiated'); // Debug log
    if (email && password) {
      // For now, use the same mock auth as Google
      const success = await signInWithGoogle();
      if (success) {
        console.log('Email sign in successful'); // Debug log
        navigation?.replace('Main');
      }
    }
  };

  const renderFloatingElement = (icon: string, size: number, opacity: number) => {
    const translateY = floatingAnim.interpolate({
      inputRange: [0, 1],
      outputRange: [0, -10],
    });

    return (
      <Animated.View
        style={[
          styles.floatingElement,
          {
            opacity: opacity,
            transform: [{ translateY }],
          },
        ]}
      >
        <View style={[styles.floatingIcon, { width: size, height: size }]}>
          <Ionicons name={icon as any} size={size * 0.6} color={AppColors.primary} />
        </View>
      </Animated.View>
    );
  };

  return (
    <LinearGradient
      colors={[AppColors.primary, AppColors.primaryDark]}
      style={styles.container}
    >
      <SafeAreaView style={styles.safeArea}>
        {/* Floating elements */}
        <View style={styles.floatingContainer} pointerEvents="none">
          <View style={[styles.floatingPosition, { top: 40, right: 30 }]}>
            {renderFloatingElement('star', 25, 0.06)}
          </View>
          <View style={[styles.floatingPosition, { bottom: 180, left: 20 }]}>
            {renderFloatingElement('list', 20, 0.08)}
          </View>
          <View style={[styles.floatingPosition, { bottom: 100, right: 50 }]}>
            {renderFloatingElement('trophy', 22, 0.07)}
          </View>
          <View style={[styles.floatingPosition, { top: 300, left: 40 }]}>
            {renderFloatingElement('analytics', 30, 0.05)}
          </View>
        </View>
        
        <KeyboardAvoidingView
          behavior={Platform.OS === 'ios' ? 'padding' : 'height'}
          style={styles.keyboardView}
        >
          <ScrollView
            contentContainerStyle={styles.scrollContent}
            showsVerticalScrollIndicator={false}
            keyboardShouldPersistTaps="handled"
            removeClippedSubviews={false}
          >

            <Animated.View style={[styles.content, { opacity: fadeAnim }]}>
              {/* Logo */}
              <View style={styles.logoContainer}>
                <Image
                  source={require('../../assets/tiernerd-logo.png')}
                  style={styles.logo}
                  resizeMode="contain"
                />
              </View>

              {/* Title with animated phrase */}
              <Animated.Text style={[styles.phrase, { opacity: phraseOpacity }]}>
                {currentPhrase}
              </Animated.Text>

              {/* Login form */}
              <View style={styles.formContainer} collapsable={false}>
                <Input
                  label="Email"
                  value={email}
                  onChangeText={setEmail}
                  placeholder="name@example.com"
                  keyboardType="email-address"
                  autoCapitalize="none"
                  leftIcon={<Ionicons name="mail-outline" size={20} color={AppColors.neutral[600]} />}
                />

                <Input
                  label="Password"
                  value={password}
                  onChangeText={setPassword}
                  placeholder="••••••••"
                  secureTextEntry={!passwordVisible}
                  leftIcon={<Ionicons name="lock-closed-outline" size={20} color={AppColors.neutral[600]} />}
                  rightIcon={
                    <Ionicons
                      name={passwordVisible ? 'eye-outline' : 'eye-off-outline'}
                      size={20}
                      color={AppColors.neutral[600]}
                    />
                  }
                  onRightIconPress={() => setPasswordVisible(!passwordVisible)}
                />

                <TouchableOpacity style={styles.forgotPassword}>
                  <Text style={styles.forgotPasswordText}>Forgot Password?</Text>
                </TouchableOpacity>

                <Button
                  title="Log In"
                  onPress={handleEmailSignIn}
                  fullWidth
                  loading={isLoading}
                  disabled={!email || !password}
                  style={styles.loginButton}
                />

                {/* Divider */}
                <View style={styles.divider}>
                  <View style={styles.dividerLine} />
                  <Text style={styles.dividerText}>OR</Text>
                  <View style={styles.dividerLine} />
                </View>

                {/* Google Sign In */}
                <TouchableOpacity
                  style={styles.googleButton}
                  onPress={handleGoogleSignIn}
                  disabled={isLoading}
                >
                  {isLoading ? (
                    <ActivityIndicator color={AppColors.textPrimary} />
                  ) : (
                    <>
                      <Image
                        source={require('../../assets/google-logo.png')}
                        style={styles.googleIcon}
                      />
                      <Text style={styles.googleButtonText}>Sign in with Google</Text>
                    </>
                  )}
                </TouchableOpacity>

                {/* Sign up link */}
                <View style={styles.signUpContainer}>
                  <Text style={styles.signUpText}>Don't have an account? </Text>
                  <TouchableOpacity>
                    <Text style={styles.signUpLink}>Sign Up</Text>
                  </TouchableOpacity>
                </View>

                {/* Version */}
                <Text style={styles.version}>v1.0.0 • Tier Nerd</Text>
              </View>

              {error && (
                <View style={styles.errorContainer}>
                  <Text style={styles.errorText}>{error}</Text>
                </View>
              )}
            </Animated.View>
          </ScrollView>
        </KeyboardAvoidingView>
      </SafeAreaView>
    </LinearGradient>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
  },
  safeArea: {
    flex: 1,
  },
  keyboardView: {
    flex: 1,
  },
  scrollContent: {
    flexGrow: 1,
    paddingHorizontal: AppSpacing.lg,
  },
  floatingContainer: {
    position: 'absolute',
    top: 0,
    left: 0,
    right: 0,
    bottom: 0,
    zIndex: 1,
  },
  floatingPosition: {
    position: 'absolute',
  },
  floatingElement: {
    position: 'absolute',
  },
  floatingIcon: {
    backgroundColor: 'rgba(255, 255, 255, 0.9)',
    borderRadius: 999,
    alignItems: 'center',
    justifyContent: 'center',
  },
  content: {
    flex: 1,
    justifyContent: 'center',
    paddingVertical: AppSpacing.xl,
    zIndex: 5,
  },
  logoContainer: {
    alignItems: 'center',
    marginBottom: AppSpacing.xl,
  },
  logo: {
    width: 180,
    height: 180,
  },
  phrase: {
    ...AppTypography.headlineSmall,
    color: AppColors.textOnPrimary,
    textAlign: 'center',
    marginBottom: AppSpacing.xxxl,
    fontWeight: 'bold',
  },
  formContainer: {
    backgroundColor: 'rgba(255, 255, 255, 0.95)',
    borderRadius: AppBorders.radiusLg,
    padding: AppSpacing.lg,
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 4 },
    shadowOpacity: 0.1,
    shadowRadius: 8,
    elevation: 6,
    zIndex: 10,
  },
  loginButton: {
    marginTop: AppSpacing.md,
    backgroundColor: AppColors.primary,
  },
  forgotPassword: {
    alignSelf: 'flex-end',
    marginBottom: AppSpacing.md,
  },
  forgotPasswordText: {
    ...AppTypography.bodySmall,
    color: AppColors.primary,
  },
  divider: {
    flexDirection: 'row',
    alignItems: 'center',
    marginVertical: AppSpacing.lg,
  },
  dividerLine: {
    flex: 1,
    height: 1,
    backgroundColor: AppColors.neutral[300],
  },
  dividerText: {
    ...AppTypography.labelSmall,
    color: AppColors.textSecondary,
    marginHorizontal: AppSpacing.md,
  },
  googleButton: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'center',
    backgroundColor: AppColors.surface,
    borderWidth: 1,
    borderColor: AppColors.neutral[300],
    borderRadius: AppBorders.radiusMd,
    paddingVertical: AppSpacing.md,
    paddingHorizontal: AppSpacing.lg,
  },
  googleIcon: {
    width: 24,
    height: 24,
    marginRight: AppSpacing.sm,
  },
  googleButtonText: {
    ...AppTypography.labelLarge,
    color: AppColors.textPrimary,
    fontWeight: '500',
  },
  signUpContainer: {
    flexDirection: 'row',
    justifyContent: 'center',
    marginTop: AppSpacing.lg,
    paddingTop: AppSpacing.md,
    borderTopWidth: 1,
    borderTopColor: AppColors.neutral[200],
  },
  signUpText: {
    ...AppTypography.bodyMedium,
    color: AppColors.textSecondary,
  },
  signUpLink: {
    ...AppTypography.bodyMedium,
    color: AppColors.primary,
    fontWeight: 'bold',
    textDecorationLine: 'underline',
  },
  version: {
    ...AppTypography.labelSmall,
    color: AppColors.textSecondary,
    textAlign: 'center',
    marginTop: AppSpacing.md,
    opacity: 0.5,
  },
  errorContainer: {
    marginTop: AppSpacing.md,
    padding: AppSpacing.md,
    backgroundColor: AppColors.error,
    borderRadius: AppBorders.radiusMd,
  },
  errorText: {
    ...AppTypography.bodySmall,
    color: AppColors.textOnPrimary,
    textAlign: 'center',
  },
});