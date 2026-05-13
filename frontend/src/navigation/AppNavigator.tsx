import React from 'react';
import { NavigationContainer } from '@react-navigation/native';
import { createStackNavigator } from '@react-navigation/stack';
import { LoginScreen } from '../screens/LoginScreen';
import { RegisterScreen } from '../screens/RegisterScreen';
import { HomeScreen } from '../screens/HomeScreen';
import { ListsScreen } from '../screens/ListsScreen';
import { ProfileScreen } from '../screens/ProfileScreen';
import { ListDetailScreen } from '../screens/ListDetailScreen';
import { useAuth } from '../providers/AuthContext';

const Stack = createStackNavigator();

export const AppNavigator: React.FC = () => {
  const { user } = useAuth();

  return (
    <NavigationContainer>
      <Stack.Navigator screenOptions={{ headerShown: false }}>
        {user ? (
          <>
            <Stack.Screen name="Main">
              {(props) => <HomeScreen {...props} />}
            </Stack.Screen>
            <Stack.Screen name="Lists">
              {(props) => <ListsScreen {...props} />}
            </Stack.Screen>
            <Stack.Screen name="Profile">
              {(props) => <ProfileScreen {...props} />}
            </Stack.Screen>
            <Stack.Screen name="ListDetail">
              {(props) => <ListDetailScreen {...(props as any)} />}
            </Stack.Screen>
          </>
        ) : (
          <>
            <Stack.Screen name="Login">
              {(props) => <LoginScreen {...props} />}
            </Stack.Screen>
            <Stack.Screen name="Register">
              {(props) => <RegisterScreen {...props} />}
            </Stack.Screen>
          </>
        )}
      </Stack.Navigator>
    </NavigationContainer>
  );
};
