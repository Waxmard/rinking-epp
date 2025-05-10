import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'providers/counter_provider.dart';
import 'screens/login_screen.dart';
import 'utils/app_theme.dart';

Future<void> main() async {
  // Load environment variables before running the app
  await dotenv.load(fileName: '.env');

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => CounterProvider(),
      child: MaterialApp(
        title: 'TierNerd',
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system, // Uses device theme settings
        home: const LoginScreen(),
      ),
    );
  }
}

// Demo code removed and replaced with LoginScreen