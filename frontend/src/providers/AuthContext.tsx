import React, { createContext, useContext, useState, useEffect, ReactNode } from 'react';
import AsyncStorage from '@react-native-async-storage/async-storage';
import * as WebBrowser from 'expo-web-browser';
import * as AuthSession from 'expo-auth-session';

WebBrowser.maybeCompleteAuthSession();

interface User {
  id: string;
  email: string;
  displayName: string;
  photoUrl?: string;
}

interface AuthContextType {
  user: User | null;
  userData: any | null;
  isLoading: boolean;
  error: string | null;
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

// Mock Google OAuth config for development
const discovery = {
  authorizationEndpoint: 'https://accounts.google.com/o/oauth2/v2/auth',
  tokenEndpoint: 'https://oauth2.googleapis.com/token',
};

export const AuthProvider: React.FC<AuthProviderProps> = ({ children }) => {
  const [user, setUser] = useState<User | null>(null);
  const [userData, setUserData] = useState<any | null>(null);
  const [isLoading, setIsLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);

  // For development, we'll use mock auth
  const [request, response, promptAsync] = AuthSession.useAuthRequest(
    {
      clientId: 'YOUR_GOOGLE_CLIENT_ID.apps.googleusercontent.com',
      scopes: ['openid', 'profile', 'email'],
      responseType: AuthSession.ResponseType.Token,
      redirectUri: AuthSession.makeRedirectUri({
        scheme: 'your.app.scheme'
      }),
    },
    discovery
  );

  useEffect(() => {
    // Check for existing auth token
    checkAuthState();
  }, []);

  const checkAuthState = async () => {
    try {
      const token = await AsyncStorage.getItem('authToken');
      const userData = await AsyncStorage.getItem('userData');
      
      if (token && userData) {
        const parsedUserData = JSON.parse(userData);
        setUser({
          id: parsedUserData.id,
          email: parsedUserData.email,
          displayName: parsedUserData.displayName,
          photoUrl: parsedUserData.photoUrl,
        });
        setUserData(parsedUserData);
      }
    } catch (error) {
      console.error('Error checking auth state:', error);
    }
  };

  const signInWithGoogle = async (): Promise<boolean> => {
    try {
      setIsLoading(true);
      setError(null);

      // For development, use mock data
      const mockUser = {
        id: '123456789',
        email: 'user@example.com',
        displayName: 'Test User',
        photoUrl: null,
      };

      // Simulate network delay
      await new Promise(resolve => setTimeout(resolve, 1000));

      // Store auth data
      await AsyncStorage.setItem('authToken', 'mock-auth-token');
      await AsyncStorage.setItem('userData', JSON.stringify(mockUser));

      setUser(mockUser);
      setUserData(mockUser);
      
      return true;
    } catch (error: any) {
      setError(error.message || 'Authentication failed');
      return false;
    } finally {
      setIsLoading(false);
    }
  };

  const signOut = async () => {
    try {
      setIsLoading(true);
      
      // Clear stored data
      await AsyncStorage.removeItem('authToken');
      await AsyncStorage.removeItem('userData');
      
      setUser(null);
      setUserData(null);
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
        userData,
        isLoading,
        error,
        signInWithGoogle,
        signOut,
      }}
    >
      {children}
    </AuthContext.Provider>
  );
};