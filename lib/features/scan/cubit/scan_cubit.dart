import 'dart:async';
import 'package:card_scanner/card_scanner.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/utils/luhn.dart';
import 'scan_state.dart';

class ScanCubit extends Cubit<ScanState> {
  ScanCubit() : super(const ScanState());
  
  Timer? _timeoutTimer;
  
  @override
  Future<void> close() {
    _timeoutTimer?.cancel();
    return super.close();
  }
  
  Future<void> startScan() async {
    emit(state.copyWith(status: ScanStatus.starting));
    
    // Set a timeout to prevent indefinite hanging
    _timeoutTimer = Timer(const Duration(seconds: 30), () {
      print('Scan timeout - forcing reset to idle');
      if (state.status == ScanStatus.scanning || state.status == ScanStatus.starting) {
        emit(state.copyWith(status: ScanStatus.idle));
      }
    });
    
    try {
      emit(state.copyWith(status: ScanStatus.scanning));
      
      // Scan the card
      final cardDetails = await CardScanner.scanCard();
      
      // Cancel timeout since we got a result
      _timeoutTimer?.cancel();
      
      if (cardDetails != null && cardDetails.cardNumber.isNotEmpty) {
        // Validate the scanned number
        final normalized = LuhnValidator.normalize(cardDetails.cardNumber);
        
        if (normalized.length < 13 || normalized.length > 19) {
          emit(state.copyWith(
            status: ScanStatus.error,
            errorMessage: 'Invalid card number length (${normalized.length} digits). Expected 13-19 digits.',
          ));
        } else if (LuhnValidator.isValid(normalized)) {
          emit(state.copyWith(
            status: ScanStatus.success,
            scannedNumber: normalized,
            scannedCardHolderName: cardDetails.cardHolderName,
            scannedExpiryDate: cardDetails.expiryDate,
            errorMessage: '',
          ));
        } else {
          // For testing: allow bypass with a warning
          emit(state.copyWith(
            status: ScanStatus.error,
            errorMessage: 'Card number "$normalized" failed Luhn validation. This may be a damaged card or test number. Use "Enter Manually" to bypass validation if needed.',
          ));
        }
      } else {
        emit(state.copyWith(
          status: ScanStatus.error,
          errorMessage: 'No card number detected',
        ));
      }
    } catch (error) {
      // Cancel timeout since we got an error response
      _timeoutTimer?.cancel();
      
      // Debug: print the actual error to understand what's happening
      print('Scan error: $error');
      print('Error type: ${error.runtimeType}');
      
      // Always reset to idle first to clear any loading states
      String errorMessage = 'Scanning failed';
      
      // Check for user cancellation in various forms
      final errorString = error.toString().toLowerCase();
      if (errorString.contains('user canceled') || 
          errorString.contains('cancelled') || 
          errorString.contains('canceled') ||
          errorString.contains('user_canceled') ||
          errorString.contains('cancel') ||
          error is Exception && errorString.isEmpty) {
        // For user cancellation, just reset to idle without showing error
        print('Detected cancellation, resetting to idle');
        emit(state.copyWith(status: ScanStatus.idle));
        return;
      } else if (errorString.contains('permission')) {
        errorMessage = 'Camera permission is required';
      } else {
        // For unknown errors, also try to reset after a brief moment
        print('Unknown error, will reset to idle');
        emit(state.copyWith(status: ScanStatus.idle));
        return;
      }
      
      emit(state.copyWith(
        status: ScanStatus.error,
        errorMessage: errorMessage,
      ));
    }
  }
  
  void cancelScan() {
    _timeoutTimer?.cancel();
    emit(state.copyWith(status: ScanStatus.idle));
  }
  
  void reset() {
    _timeoutTimer?.cancel();
    emit(const ScanState());
  }
  
  void clearError() {
    emit(state.copyWith(
      status: ScanStatus.idle,
      errorMessage: '',
    ));
  }
}