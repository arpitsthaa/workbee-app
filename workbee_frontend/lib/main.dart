import 'package:flutter/material.dart';
import 'views/auth/splash_screen.dart';

void main() {
  runApp(const WorkBeeApp());
}

class WorkBeeApp extends StatelessWidget {
  const WorkBeeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'WorkBee',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: Colors.white,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1D61E7),
          primary: const Color(0xFF1D61E7),
          secondary: const Color(0xFFE5A922),
        ),
      ),
      home: const SplashScreen(),
    );
  }
}