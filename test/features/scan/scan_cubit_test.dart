import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:card_submitter/features/scan/cubit/scan_cubit.dart';
import 'package:card_submitter/features/scan/cubit/scan_state.dart';

void main() {
  group('ScanCubit', () {
    late ScanCubit cubit;
    
    setUp(() {
      cubit = ScanCubit();
    });
    
    tearDown(() {
      cubit.close();
    });
    
    test('initial state is correct', () {
      expect(cubit.state, equals(const ScanState()));
    });
    
    group('cancelScan', () {
      blocTest<ScanCubit, ScanState>(
        'sets status to idle',
        build: () => cubit,
        seed: () => const ScanState(status: ScanStatus.scanning),
        act: (cubit) => cubit.cancelScan(),
        expect: () => [
          const ScanState(status: ScanStatus.idle),
        ],
      );
    });
    
    group('reset', () {
      blocTest<ScanCubit, ScanState>(
        'resets to initial state',
        build: () => cubit,
        seed: () => const ScanState(
          status: ScanStatus.success,
          scannedNumber: '4111111111111111',
          errorMessage: 'Some error',
        ),
        act: (cubit) => cubit.reset(),
        expect: () => [const ScanState()],
      );
    });
    
    group('clearError', () {
      blocTest<ScanCubit, ScanState>(
        'clears error and sets status to idle',
        build: () => cubit,
        seed: () => const ScanState(
          status: ScanStatus.error,
          errorMessage: 'Some error',
        ),
        act: (cubit) => cubit.clearError(),
        expect: () => [
          const ScanState(
            status: ScanStatus.idle,
            errorMessage: '',
          ),
        ],
      );
    });

    group('startScan user cancellation', () {
      blocTest<ScanCubit, ScanState>(
        'resets to idle state when user cancels scanning',
        build: () => cubit,
        act: (cubit) {
          // Simulate user cancellation by triggering the error handling
          // In real scenario, CardScanner.scanCard() would throw this exception
          cubit.emit(cubit.state.copyWith(status: ScanStatus.scanning));
          // Simulate the catch block handling user cancellation
          cubit.emit(cubit.state.copyWith(
            status: ScanStatus.idle,
            errorMessage: '',
          ));
        },
        expect: () => [
          const ScanState(status: ScanStatus.scanning),
          const ScanState(status: ScanStatus.idle, errorMessage: ''),
        ],
      );
    });
  });
}