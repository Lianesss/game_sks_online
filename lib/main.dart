import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/app_provider.dart';
import 'theme/app_theme.dart';
import 'screens/auth/login_screen.dart';
import 'screens/home/main_shell.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => AppProvider(),
      child: const SKSQuestApp(),
    ),
  );
}

class SKSQuestApp extends StatelessWidget {
  const SKSQuestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SKS Quest',
      theme: AppTheme.lightTheme,
      debugShowCheckedModeBanner: false,
      initialRoute: '/login',
      routes: {
        '/login': (_) => const LoginScreen(),
        '/home': (context) {
          final args = ModalRoute.of(context)?.settings.arguments;
          return MainShell(initialIndex: args is int ? args : 0);
        },
      },
    );
  }
}
