import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../scan/cubit/scan_cubit.dart';
import '../../scan/cubit/scan_state.dart';

/// A button widget for scanning cards with camera
class ScanButtonWidget extends StatelessWidget {
  const ScanButtonWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ScanCubit, ScanState>(
      listener: (context, scanState) {
        if (scanState.status == ScanStatus.error) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(scanState.errorMessage),
              backgroundColor: Colors.red,
              action: SnackBarAction(
                label: 'Dismiss',
                textColor: Colors.white,
                onPressed: () {
                  context.read<ScanCubit>().clearError();
                },
              ),
            ),
          );
        }
      },
      builder: (context, scanState) {
        return SizedBox(
          width: double.infinity,
          height: 56,
          child: OutlinedButton.icon(
            onPressed: () => context.read<ScanCubit>().startScan(),
            style: OutlinedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              side: BorderSide(
                color: Theme.of(context).primaryColor,
                width: 2,
              ),
            ),
            icon: Icon(
              Icons.camera_alt,
              size: 24,
              color: Theme.of(context).primaryColor,
            ),
            label: Text(
              'Scan Card with Camera',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).primaryColor,
              ),
            ),
          ),
        );
      },
    );
  }
}