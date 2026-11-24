import 'package:flutter/material.dart';
import 'package:workbee_frontend/constants/app_colors.dart';

/// Error + retry state shown when a screen fails to load data.
///
/// Replaces the repeated `Error: <msg>` + `Retry` button pattern.
class ErrorRetryState extends StatelessWidget {
  final String error;
  final VoidCallback onRetry;

  const ErrorRetryState({
    super.key,
    required this.error,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Error: $error',
            style: const TextStyle(color: AppColors.errorRed),
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: onRetry,
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}
