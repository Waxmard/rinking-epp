import React from 'react';
import { StatusBar } from 'expo-status-bar';
import { AuthProvider } from './src/providers/AuthContext';
import { AppNavigator } from './src/navigation/AppNavigator';

// Suppress useInsertionEffect warnings in development
if (__DEV__) {
  const originalWarn = console.warn;
  console.warn = (...args) => {
    if (args[0]?.includes?.('useInsertionEffect must not schedule updates')) {
      return;
    }
    originalWarn(...args);
  };
}

export default function App() {
  return (
    <AuthProvider>
      <AppNavigator />
      <StatusBar style="light" />
    </AuthProvider>
  );
}
