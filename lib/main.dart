import 'package:flutter/material.dart';

import 'screens/splash_screen.dart';

void main() {
  runApp(const JomEatApp());
}

class JomEatApp extends StatelessWidget {
  const JomEatApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'JomEat',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFE66A2C),
          primary: const Color(0xFFE66A2C),
          secondary: const Color(0xFF2E7D5B),
          surface: const Color(0xFFFFFBF6),
        ),
        scaffoldBackgroundColor: const Color(0xFFFFFBF6),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFE66A2C),
          foregroundColor: Colors.white,
          centerTitle: true,
        ),
        cardTheme: CardThemeData(
          color: Colors.white,
          elevation: 2,
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFE66A2C),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          ),
        ),
      ),
      home: const SplashScreen(),
    );
  }
}
