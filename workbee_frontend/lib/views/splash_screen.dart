import 'dart:async';
import 'package:flutter/material.dart';
import 'package:workbee_frontend/services/auth_service.dart';
import 'login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  double _opacity = 0.0;

  @override
  void initState() {
    super.initState();

    AuthService().warmUp();

    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) {
        setState(() => _opacity = 1.0);
      }
    });

    _navigateAfterSplash();
  }

  Future<void> _navigateAfterSplash() async {
    await Future.delayed(const Duration(milliseconds: 800));
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 800),
          opacity: _opacity,
          child: Image.asset(
            'assets/workbee_logo.png',
            width: 210,
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}