import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'providers/list_provider.dart';
import 'screens/login_screen_updated.dart';
import 'screens/home_screen.dart';
import 'screens/lists_screen.dart';
import 'widgets/dev_menu.dart';
import 'design_system/design_system.dart';
import 'services/service_factory.dart';

Future<void> main() async {
  // Ensure Flutter is initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables before running the app
  await dotenv.load(fileName: '.env');
  
  // Initialize the service factory
  ServiceFactory().initialize();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => AuthProvider()..initialize()),
        ChangeNotifierProvider(create: (context) => ListProvider()),
      ],
      child: Consumer<AuthProvider>(
        builder: (context, auth, child) {
          return MaterialApp(
            title: 'TierNerd',
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: ThemeMode.system, // Uses device theme settings
            initialRoute: auth.isAuthenticated ? '/home' : '/login',
            routes: {
              '/login': (context) => const LoginScreenUpdated(),
              '/home': (context) => const HomeScreen(),
              '/lists': (context) => const ListsScreen(),
              '/dev-menu': (context) => const DevMenu(),
            },
          );
        },
      ),
    );
  }
}