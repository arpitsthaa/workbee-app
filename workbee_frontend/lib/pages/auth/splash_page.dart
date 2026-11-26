import 'dart:async';
import 'package:flutter/material.dart';
import 'package:workbee_frontend/clients/auth_client.dart';
import 'package:workbee_frontend/pages/auth/login_page.dart';

/// Splash screen shown on app startup. Warms up the backend then navigates to login.
class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  double _opacity = 0.0;

  @override
  void initState() {
    super.initState();

    AuthClient.getToken(); // warm-up check for token presence

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
      MaterialPageRoute(builder: (context) => const LoginPage()),
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
