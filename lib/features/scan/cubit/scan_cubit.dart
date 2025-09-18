import 'package:card_scanner/card_scanner.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/utils/luhn.dart';
import 'scan_state.dart';

class ScanCubit extends Cubit<ScanState> {
  ScanCubit() : super(const ScanState());
  
  Future<void> startScan() async {
    emit(state.copyWith(status: ScanStatus.starting));
    
    try {
      emit(state.copyWith(status: ScanStatus.scanning));
      final cardDetails = await CardScanner.scanCard();
      if (cardDetails == null) {
        emit(state.copyWith(status: ScanStatus.idle));
        return;
      }
      
      if (cardDetails.cardNumber.isNotEmpty) {
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
      if (error.toString().toLowerCase().contains('cancel')) {
        emit(state.copyWith(status: ScanStatus.idle));
        return;
      }
      String errorMessage = 'Scanning failed';
      if (error.toString().contains('permission')) {
        errorMessage = 'Camera permission is required';
      }
      
      emit(state.copyWith(
        status: ScanStatus.error,
        errorMessage: errorMessage,
      ));
    }
  }
  
  void cancelScan() {
    emit(state.copyWith(status: ScanStatus.idle));
  }
  
  void reset() {
    emit(const ScanState());
  }
  
  void clearError() {
    emit(state.copyWith(
      status: ScanStatus.idle,
      errorMessage: '',
    ));
  }
}