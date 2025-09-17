import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/scan_cubit.dart';
import '../cubit/scan_state.dart';
import '../widgets/status_display_widgets.dart';

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
              StatusIconWidget(status: state.status),
              const SizedBox(height: 16),
              StatusTextWidget(state: state),
              const SizedBox(height: 32),
              ScanActionButtonWidget(
                status: state.status,
                onStartScan: () => context.read<ScanCubit>().startScan(),
                onReset: () => context.read<ScanCubit>().reset(),
              ),
            ],
          ),
        );
      },
    );
  }
}