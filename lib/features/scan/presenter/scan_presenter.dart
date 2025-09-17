import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/utils/luhn.dart';
import '../cubit/scan_cubit.dart';
import '../cubit/scan_state.dart';

/// Presenter for card scanning functionality
class ScanPresenter extends StatelessWidget {
  const ScanPresenter({super.key, this.onScanned});
  
  final Function(String)? onScanned;
  
  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ScanCubit, ScanState>(
      listener: (context, state) {
        if (state.status == ScanStatus.success) {
          onScanned?.call(state.scannedNumber);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Card scanned successfully!'),
              backgroundColor: Colors.green,
            ),
          );
        } else if (state.status == ScanStatus.error) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      builder: (context, state) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildStatusIcon(state.status),
              const SizedBox(height: 16),
              _buildStatusText(state),
              const SizedBox(height: 32),
              _buildActionButton(context, state),
            ],
          ),
        );
      },
    );
  }
  
  Widget _buildStatusIcon(ScanStatus status) {
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
  
  Widget _buildStatusText(ScanState state) {
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
  
  Widget _buildActionButton(BuildContext context, ScanState state) {
    switch (state.status) {
      case ScanStatus.idle:
      case ScanStatus.error:
        return Column(
          children: [
            ElevatedButton.icon(
              onPressed: () => context.read<ScanCubit>().startScan(),
              icon: const Icon(Icons.camera_alt),
              label: const Text('Try Again'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            ),
            const SizedBox(height: 12),
            TextButton.icon(
              onPressed: () => _showManualEntryDialog(context),
              icon: const Icon(Icons.keyboard),
              label: const Text('Enter Manually'),
            ),
          ],
        );
      case ScanStatus.starting:
      case ScanStatus.scanning:
        return ElevatedButton.icon(
          onPressed: () => context.read<ScanCubit>().cancelScan(),
          icon: const Icon(Icons.cancel),
          label: const Text('Cancel'),
          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
        );
      case ScanStatus.success:
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            ElevatedButton.icon(
              onPressed: () => context.read<ScanCubit>().reset(),
              icon: const Icon(Icons.refresh),
              label: const Text('Scan Again'),
            ),
            const SizedBox(width: 16),
            ElevatedButton.icon(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.check),
              label: const Text('Use This Card'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            ),
          ],
        );
    }
  }
  
  String _maskCardNumber(String cardNumber) {
    if (cardNumber.length < 4) return cardNumber;
    
    final last4 = cardNumber.substring(cardNumber.length - 4);
    final masked = '*' * (cardNumber.length - 4);
    
    // Add spacing
    String result = '$masked$last4';
    if (result.length > 4) {
      final buffer = StringBuffer();
      for (int i = 0; i < result.length; i++) {
        if (i > 0 && i % 4 == 0) {
          buffer.write(' ');
        }
        buffer.write(result[i]);
      }
      result = buffer.toString();
    }
    
    return result;
  }

  void _showManualEntryDialog(BuildContext context) {
    final controller = TextEditingController();
    
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Enter Card Number'),
          content: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Card Number',
              hintText: 'Enter 13-19 digits',
            ),
            maxLength: 19,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final number = controller.text.replaceAll(RegExp(r'\D'), '');
                if (number.isNotEmpty) {
                  Navigator.of(dialogContext).pop();
                  // Show a warning if the manually entered number is also invalid
                  if (!_isValidLuhn(number)) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Warning: Card number "$number" may be invalid (failed Luhn validation)'),
                        backgroundColor: Colors.orange,
                      ),
                    );
                  }
                  onScanned?.call(number);
                }
              },
              child: const Text('Use This Number'),
            ),
          ],
        );
      },
    );
  }

  bool _isValidLuhn(String number) {
    return LuhnValidator.isValid(number);
  }
}