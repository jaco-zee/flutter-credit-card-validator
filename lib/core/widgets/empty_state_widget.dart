import 'package:flutter/material.dart';

// A reusable empty state widget that can be customized for different scenarios
class EmptyStateWidget extends StatelessWidget {
  const EmptyStateWidget({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.primaryAction,
    this.secondaryAction,
    this.iconColor,
  });

  final IconData icon;
  final String title;
  final String message;
  final Widget? primaryAction;
  final Widget? secondaryAction;
  final Color? iconColor;

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
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: (iconColor ?? Colors.blue.shade400).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  size: 64,
                  color: iconColor ?? Colors.blue.shade400,
                ),
              ),
              
              const SizedBox(height: 24),
              
              Text(
                title,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade700,
                ),
              ),
              
              const SizedBox(height: 12),
              
              Text(
                message,
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ),
              
              if (primaryAction != null || secondaryAction != null)
                const SizedBox(height: 32),
              
              if (primaryAction != null) ...[
                SizedBox(
                  width: double.infinity,
                  child: primaryAction!,
                ),
                if (secondaryAction != null) const SizedBox(height: 12),
              ],
              
              if (secondaryAction != null)
                SizedBox(
                  width: double.infinity,
                  child: secondaryAction!,
                ),
            ],
          ),
        ),
      ),
    );
  }
}