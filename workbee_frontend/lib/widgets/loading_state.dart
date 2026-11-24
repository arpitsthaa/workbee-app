import 'package:flutter/material.dart';

/// Centered loading indicator.
///
/// Replaces the repeated `const Center(child: CircularProgressIndicator())`
/// used while screens fetch data.
class LoadingState extends StatelessWidget {
  const LoadingState({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(child: CircularProgressIndicator());
  }
}
