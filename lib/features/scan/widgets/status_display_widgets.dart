import 'package:flutter/material.dart';
import '../cubit/scan_state.dart';

class StatusIconWidget extends StatelessWidget {
  const StatusIconWidget({
    super.key,
    required this.status,
  });

  final ScanStatus status;

  @override
  Widget build(BuildContext context) {
    switch (status) {
      case ScanStatus.idle:
        return const Icon(Icons.camera_alt, size: 64, color: Colors.blue);
      case ScanStatus.starting:
      case ScanStatus.scanning:
        return const SizedBox(
          width: 64,
          height: 64,
          child: CircularProgressIndicator(),
        );
      case ScanStatus.success:
        return const Icon(Icons.check_circle, size: 64, color: Colors.green);
      case ScanStatus.error:
        return const Icon(Icons.error, size: 64, color: Colors.red);
    }
  }
}

class StatusTextWidget extends StatelessWidget {
  const StatusTextWidget({
    super.key,
    required this.state,
  });

  final ScanState state;

  @override
  Widget build(BuildContext context) {
    switch (state.status) {
      case ScanStatus.idle:
        return const Text(
          'Ready to scan your credit card',
          style: TextStyle(fontSize: 18),
          textAlign: TextAlign.center,
        );
      case ScanStatus.starting:
        return const Text(
          'Preparing camera...',
          style: TextStyle(fontSize: 18),
          textAlign: TextAlign.center,
        );
      case ScanStatus.scanning:
        return const Text(
          'Point your camera at the credit card\nMake sure the number is clearly visible',
          style: TextStyle(fontSize: 16),
          textAlign: TextAlign.center,
        );
      case ScanStatus.success:
        return Text(
          'Card number detected:\n${_maskCardNumber(state.scannedNumber)}',
          style: const TextStyle(fontSize: 16),
          textAlign: TextAlign.center,
        );
      case ScanStatus.error:
        return Text(
          state.errorMessage,
          style: const TextStyle(fontSize: 16, color: Colors.red),
          textAlign: TextAlign.center,
        );
    }
  }

  String _maskCardNumber(String number) {
    if (number.length < 4) return number;
    final lastFour = number.substring(number.length - 4);
    return '**** **** **** $lastFour';
  }
}

class ScanActionButtonWidget extends StatelessWidget {
  const ScanActionButtonWidget({
    super.key,
    required this.status,
    required this.onStartScan,
    required this.onReset,
  });

  final ScanStatus status;
  final VoidCallback onStartScan;
  final VoidCallback onReset;

  @override
  Widget build(BuildContext context) {
    switch (status) {
      case ScanStatus.idle:
        return ElevatedButton.icon(
          onPressed: onStartScan,
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          icon: const Icon(Icons.camera_alt),
          label: const Text('Start Scanning'),
        );
      case ScanStatus.starting:
      case ScanStatus.scanning:
        return ElevatedButton.icon(
          onPressed: onReset,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          icon: const Icon(Icons.stop),
          label: const Text('Stop Scanning'),
        );
      case ScanStatus.success:
        return ElevatedButton.icon(
          onPressed: onReset,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          icon: const Icon(Icons.check),
          label: const Text('Scan Complete'),
        );
      case ScanStatus.error:
        return ElevatedButton.icon(
          onPressed: onStartScan,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.orange,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          icon: const Icon(Icons.refresh),
          label: const Text('Try Again'),
        );
    }
  }
}