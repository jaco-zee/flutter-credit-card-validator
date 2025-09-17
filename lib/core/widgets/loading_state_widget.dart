import 'package:flutter/material.dart';

// A reusable loading state widget for consistent loading UI across the app
class LoadingStateWidget extends StatelessWidget {
  const LoadingStateWidget({
    super.key,
    this.message = 'Loading...',
    this.showMessage = true,
  });

  final String message;
  final bool showMessage;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.grey.shade50,
            Colors.white,
          ],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            if (showMessage) ...[
              const SizedBox(height: 16),
              Text(
                message,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}