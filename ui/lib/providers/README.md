# Provider Setup Guide

## Overview
This directory contains provider classes for state management in the application.

## Files

## Usage
1. Create provider classes extending `ChangeNotifier`
2. Wrap your app with `ChangeNotifierProvider` or `MultiProvider`
3. Use `Provider.of<YourProvider>(context)` to access state
4. Use `Consumer<YourProvider>` for widgets that need to rebuild when state changes

## Best Practices
- Keep providers focused on specific state domains
- Use `listen: false` when just calling methods without needing rebuilds
- Consider using `Provider.of` for occasional access and `Consumer` for frequent updates
- Use `MultiProvider` when your app needs multiple providers
- Create separate provider files for different state domains

## Example
```dart
// Access provider state
final counter = Provider.of<CounterProvider>(context).count;

// Update provider state
Provider.of<CounterProvider>(context, listen: false).increment();

// Listen to changes with Consumer
Consumer<CounterProvider>(
  builder: (context, provider, child) {
    return Text('${provider.count}');
  },
)
```