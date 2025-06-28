import 'package:flutter/material.dart';
import 'package:love_in/LoginScreen.dart';
import 'package:love_in/homeScreen.dart';

void main() {
  runApp(const CareGoalsApp());
}

class CareGoalsApp extends StatelessWidget {
  const CareGoalsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'CareGoals',
      initialRoute: '/login',
      routes: {
        '/login': (context) => const LoginScreen(),
        '/main': (context) => const HomeScreen(), // ✅ Match this name
      },
    );
  }
}
