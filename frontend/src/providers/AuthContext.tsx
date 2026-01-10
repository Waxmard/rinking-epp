import React, {
  createContext,
  useContext,
  useState,
  useEffect,
  ReactNode,
} from 'react';
import AsyncStorage from '@react-native-async-storage/async-storage';
import * as WebBrowser from 'expo-web-browser';
import * as AuthSession from 'expo-auth-session';
import { USE_MOCK_AUTH } from '../config/api';
import { authService, User as ApiUser } from '../services/authService';

WebBrowser.maybeCompleteAuthSession();

interface User {
  id: string;
  email: string;
  displayName: string;
  photoUrl?: string;
}

interface AuthContextType {
  user: User | null;
  isLoading: boolean;
  error: string | null;
  signIn: (email: string, password: string) => Promise<boolean>;
  register: (
    email: string,
    password: string,
    username?: string
  ) => Promise<boolean>;
  signInWithGoogle: () => Promise<boolean>;
  signOut: () => Promise<void>;
}

const AuthContext = createContext<AuthContextType | undefined>(undefined);

export const useAuth = () => {
  const context = useContext(AuthContext);
  if (!context) {
    throw new Error('useAuth must be used within an AuthProvider');
  }
  return context;
};

interface AuthProviderProps {
  children: ReactNode;
}

// Storage keys
const AUTH_TOKEN_KEY = 'authToken';
const USER_DATA_KEY = 'userData';

// Convert API user to local user format
const toLocalUser = (apiUser: ApiUser): User => ({
  id: apiUser.user_id,
  email: apiUser.email,
  displayName: apiUser.username || apiUser.email.split('@')[0],
  photoUrl: undefined,
});

// Mock Google OAuth config (kept for future use)
const discovery = {
  authorizationEndpoint: 'https://accounts.google.com/o/oauth2/v2/auth',
  tokenEndpoint: 'https://oauth2.googleapis.com/token',
};

export const AuthProvider: React.FC<AuthProviderProps> = ({ children }) => {
  const [user, setUser] = useState<User | null>(null);
  const [isLoading, setIsLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  // Google OAuth setup (for future use)
  const [request, response, promptAsync] = AuthSession.useAuthRequest(
    {
      clientId: 'YOUR_GOOGLE_CLIENT_ID.apps.googleusercontent.com',
      scopes: ['openid', 'profile', 'email'],
      responseType: AuthSession.ResponseType.Token,
      redirectUri: AuthSession.makeRedirectUri({
        scheme: 'tiernerd',
      }),
    },
    discovery
  );

  useEffect(() => {
    checkAuthState();
  }, []);

  const checkAuthState = async () => {
    try {
      const token = await AsyncStorage.getItem(AUTH_TOKEN_KEY);
      const userData = await AsyncStorage.getItem(USER_DATA_KEY);

      if (token && userData) {
        if (USE_MOCK_AUTH) {
          // Mock mode: trust stored data
          setUser(JSON.parse(userData));
        } else {
          // Real mode: validate token with backend
          const result = await authService.validateToken(token);
          if (result.success && result.user) {
            const localUser = toLocalUser(result.user);
            setUser(localUser);
            await AsyncStorage.setItem(
              USER_DATA_KEY,
              JSON.stringify(localUser)
            );
          } else {
            // Token invalid, clear storage
            await AsyncStorage.removeItem(AUTH_TOKEN_KEY);
            await AsyncStorage.removeItem(USER_DATA_KEY);
          }
        }
      }
    } catch (error) {
      console.error('Error checking auth state:', error);
    } finally {
      setIsLoading(false);
    }
  };

  const signIn = async (email: string, password: string): Promise<boolean> => {
    try {
      setIsLoading(true);
      setError(null);

      if (USE_MOCK_AUTH) {
        // Mock authentication
        await new Promise((resolve) => setTimeout(resolve, 500));
        const mockUser: User = {
          id: '123456789',
          email: email,
          displayName: email.split('@')[0],
          photoUrl: undefined,
        };
        await AsyncStorage.setItem(AUTH_TOKEN_KEY, 'mock-auth-token');
        await AsyncStorage.setItem(USER_DATA_KEY, JSON.stringify(mockUser));
        setUser(mockUser);
        return true;
      }

      // Real authentication
      const result = await authService.login(email, password);
      if (result.success && result.user && result.token) {
        const localUser = toLocalUser(result.user);
        await AsyncStorage.setItem(AUTH_TOKEN_KEY, result.token);
        await AsyncStorage.setItem(USER_DATA_KEY, JSON.stringify(localUser));
        setUser(localUser);
        return true;
      } else {
        setError(result.error || 'Login failed');
        return false;
      }
    } catch (error: any) {
      setError(error.message || 'Authentication failed');
      return false;
    } finally {
      setIsLoading(false);
    }
  };

  const register = async (
    email: string,
    password: string,
    username?: string
  ): Promise<boolean> => {
    try {
      setIsLoading(true);
      setError(null);

      if (USE_MOCK_AUTH) {
        // Mock registration (same as login for mock)
        return signIn(email, password);
      }

      // Real registration
      const result = await authService.register({ email, password, username });
      if (result.success && result.user && result.token) {
        const localUser = toLocalUser(result.user);
        await AsyncStorage.setItem(AUTH_TOKEN_KEY, result.token);
        await AsyncStorage.setItem(USER_DATA_KEY, JSON.stringify(localUser));
        setUser(localUser);
        return true;
      } else {
        setError(result.error || 'Registration failed');
        return false;
      }
    } catch (error: any) {
      setError(error.message || 'Registration failed');
      return false;
    } finally {
      setIsLoading(false);
    }
  };

  const signInWithGoogle = async (): Promise<boolean> => {
    // Google OAuth not yet implemented - show message
    setError('Google sign-in coming soon! Please use email/password for now.');
    return false;
  };

  const signOut = async () => {
    try {
      setIsLoading(true);
      await AsyncStorage.removeItem(AUTH_TOKEN_KEY);
      await AsyncStorage.removeItem(USER_DATA_KEY);
      setUser(null);
    } catch (error) {
      console.error('Error signing out:', error);
    } finally {
      setIsLoading(false);
    }
  };

  return (
    <AuthContext.Provider
      value={{
        user,
        isLoading,
        error,
        signIn,
        register,
        signInWithGoogle,
        signOut,
      }}
    >
      {children}
    </AuthContext.Provider>
  );
};
