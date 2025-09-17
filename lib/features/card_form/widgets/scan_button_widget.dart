import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../scan/cubit/scan_cubit.dart';
import '../../scan/cubit/scan_state.dart';

//button widget for scanning cards with camera
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
            ),
          );
        }
      },
      builder: (context, scanState) {
        final isScanning = scanState.status == ScanStatus.scanning || 
                          scanState.status == ScanStatus.starting;
        
        return SizedBox(
          width: double.infinity,
          height: 56,
          child: OutlinedButton.icon(
            onPressed: isScanning 
                ? null 
                : () => context.read<ScanCubit>().startScan(),
            style: OutlinedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              side: BorderSide(
                color: isScanning 
                    ? Colors.grey.shade300
                    : Theme.of(context).primaryColor,
                width: 2,
              ),
            ),
            icon: isScanning 
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Theme.of(context).primaryColor,
                      ),
                    ),
                  )
                : Icon(
                    Icons.camera_alt,
                    size: 24,
                    color: Theme.of(context).primaryColor,
                  ),
            label: Text(
              isScanning ? 'Scanning...' : 'Scan Card with Camera',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: isScanning 
                    ? Colors.grey.shade500
                    : Theme.of(context).primaryColor,
              ),
            ),
          ),
        );
      },
    );
  }
}