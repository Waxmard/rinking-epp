import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final userData = auth.userData;

    return Scaffold(
      appBar: AppBar(
        title: const Text('TierNerd Home'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await auth.signOut();
              Navigator.of(context).pushReplacementNamed('/login');
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            userData?['photoUrl'] != null
                ? CircleAvatar(
                    backgroundImage: NetworkImage(userData!['photoUrl']!),
                    radius: 40,
                  )
                : const CircleAvatar(
                    child: Icon(Icons.person, size: 40),
                    radius: 40,
                  ),
            const SizedBox(height: 20),
            Text(
              'Welcome, ${userData?['displayName'] ?? 'User'}!',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 10),
            Text(
              userData?['email'] ?? '',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 40),
            // Placeholder content
            const Card(
              margin: EdgeInsets.symmetric(horizontal: 20),
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Text(
                  'Your tier lists will appear here. This is a placeholder for the home screen.',
                  style: TextStyle(fontSize: 16),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Add new tier list
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}