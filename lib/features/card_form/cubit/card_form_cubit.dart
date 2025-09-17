import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/formatting/masking.dart';
import '../../../core/utils/bin_patterns.dart';
import '../../../core/utils/luhn.dart';
import '../../../data/datasources/local/card_local_ds.dart';
import '../../../domain/entities/credit_card.dart';
import '../../cards/cubit/cards_cubit.dart';
import 'card_form_state.dart';

class CardFormCubit extends Cubit<CardFormState> {
  
  CardFormCubit(this._dataSource, this._cardsCubit) : super(const CardFormState());
  final CardLocalDataSource _dataSource;
  final CardsCubit _cardsCubit;
  
  void onNumberChanged(String rawNumber) {
    if (state.submitStatus == SubmitStatus.error) {
      emit(state.copyWith(
        submitStatus: SubmitStatus.idle,
        errorMessage: '',
      ));
    }

    final normalized = LuhnValidator.normalize(rawNumber);

    final brand = BinPatterns.detectBrand(normalized);

    final masked = CardFormatter.formatCardNumber(normalized);
    
    emit(state.copyWith(
      rawNumber: normalized,
      maskedNumber: masked,
      brand: brand,
    ));
    
    _validateForm();
  }

  void onCvvChanged(String cvv) {
    // Clear any previous errors when user starts typing
    if (state.submitStatus == SubmitStatus.error) {
      emit(state.copyWith(
        submitStatus: SubmitStatus.idle,
        errorMessage: '',
      ));
    }

    final cleanedCvv = cvv.replaceAll(RegExp(r'\D'), '');
    final limitedCvv = cleanedCvv.length > 4 ? cleanedCvv.substring(0, 4) : cleanedCvv;
    
    emit(state.copyWith(cvv: limitedCvv));
    _validateForm();
  }

  void onCardHolderNameChanged(String name) {
    if (state.submitStatus == SubmitStatus.error) {
      emit(state.copyWith(
        submitStatus: SubmitStatus.idle,
        errorMessage: '',
      ));
    }
    
    final cleanedName = name.trim();
    final limitedName = cleanedName.length > 50 ? cleanedName.substring(0, 50) : cleanedName;
    
    emit(state.copyWith(cardHolderName: limitedName));
    _validateForm();
  }

  void onExpiryDateChanged(String date) {
    if (state.submitStatus == SubmitStatus.error) {
      emit(state.copyWith(
        submitStatus: SubmitStatus.idle,
        errorMessage: '',
      ));
    }
    
    // Format as MM/YY
    final cleanedDate = date.replaceAll(RegExp(r'\D'), '');
    String formattedDate = cleanedDate;
    
    if (cleanedDate.length >= 2) {
      formattedDate = '${cleanedDate.substring(0, 2)}/${cleanedDate.substring(2)}';
    }
    
    // Limit to MM/YY format
    if (formattedDate.length > 5) {
      formattedDate = formattedDate.substring(0, 5);
    }
    
    emit(state.copyWith(expiryDate: formattedDate));
    _validateForm();
  }
  
  void onCountryChanged(String code) {
    // Clear any previous errors when user makes changes
    if (state.submitStatus == SubmitStatus.error) {
      emit(state.copyWith(
        submitStatus: SubmitStatus.idle,
        errorMessage: '',
      ));
    }
    
    emit(state.copyWith(countryCode: code));
    _validateForm();
  }
  
  void onScannedData(String scannedNumber, String? scannedName, String? scannedExpiry) {
    onNumberChanged(scannedNumber);
    // Auto-fill scanned data if available
    if (scannedName != null && scannedName.isNotEmpty) {
      emit(state.copyWith(cardHolderName: scannedName));
    }
    if (scannedExpiry != null && scannedExpiry.isNotEmpty) {
      // Convert expiry from MM/YY or MM/YYYY format to MM/YY
      String formattedExpiry = scannedExpiry;
      if (scannedExpiry.contains('/')) {
        final parts = scannedExpiry.split('/');
        if (parts.length == 2) {
          final month = parts[0].padLeft(2, '0');
          final year = parts[1].length == 4 ? parts[1].substring(2) : parts[1];
          formattedExpiry = '$month/$year';
        }
      } else if (scannedExpiry.length == 4) {
        // Format MMYY to MM/YY
        formattedExpiry = '${scannedExpiry.substring(0, 2)}/${scannedExpiry.substring(2)}';
      }
      
      emit(state.copyWith(expiryDate: formattedExpiry));
    }
    
    _validateForm();
  }
  
  Future<void> onSubmit() async {
    if (!state.isValid) return;
    
    _cardsCubit.clearMessage();
    
    emit(state.copyWith(submitStatus: SubmitStatus.submitting));
    
    try {
      // Check if country is banned
      final bannedCountries = await _dataSource.getBannedCountries();
      if (bannedCountries.contains(state.countryCode)) {
        emit(state.copyWith(
          submitStatus: SubmitStatus.error,
          errorMessage: 'Cards from ${state.countryCode} are not accepted',
        ));
        return;
      }
      
      final card = CreditCard(
        number: state.rawNumber,
        brand: state.brand,
        cardHolderName: state.cardHolderName,
        expiryDate: state.expiryDate,
        issuingCountry: state.countryCode,
        savedAt: DateTime.now(),
      );
      
      final success = await _cardsCubit.addCardQuietly(card);
      
      if (success) {
        emit(state.copyWith(submitStatus: SubmitStatus.success));
        _resetForm();
      } else {
        final exists = await _dataSource.cardExists(state.rawNumber);
        final errorMessage = exists ? 'Card already exists' : 'Failed to save card';
        
        emit(state.copyWith(
          submitStatus: SubmitStatus.error,
          errorMessage: errorMessage,
        ));
      }
    } catch (error) {
      emit(state.copyWith(
        submitStatus: SubmitStatus.error,
        errorMessage: 'Failed to save card: $error',
      ));
    }
  }
  
  void resetForm() {
    _resetForm();
  }
  
  void clearMessage() {
    emit(state.copyWith(
      submitStatus: SubmitStatus.idle,
      errorMessage: '',
    ));
  }
  
  void _resetForm() {
    emit(const CardFormState());
  }
  
  void _validateForm() {
    final isValidNumber = state.rawNumber.isNotEmpty && LuhnValidator.isValid(state.rawNumber);
    final isValidCvv = BinPatterns.isValidCvvLength(state.cvv, state.brand);
    final hasCardHolderName = state.cardHolderName.trim().isNotEmpty;
    final isValidExpiryDate = _isValidExpiryDate(state.expiryDate);
    final hasCountry = state.countryCode.isNotEmpty;
    
    final isValid = isValidNumber && isValidCvv && hasCardHolderName && isValidExpiryDate && hasCountry;
    
    emit(state.copyWith(isValid: isValid));
  }

  bool _isValidExpiryDate(String expiryDate) {
    if (expiryDate.length != 5 || !expiryDate.contains('/')) {
      return false;
    }
    
    final parts = expiryDate.split('/');
    if (parts.length != 2) return false;
    
    final month = int.tryParse(parts[0]);
    final year = int.tryParse(parts[1]);
    
    if (month == null || year == null) return false;
    if (month < 1 || month > 12) return false;
    
    // Convert 2-digit year to 4-digit year
    final fullYear = year + 2000;
    
    // Check if the date is not expired (current month/year or later)
    final now = DateTime.now();
    final expiryDateTime = DateTime(fullYear, month);
    final currentMonthYear = DateTime(now.year, now.month);
    
    return expiryDateTime.isAfter(currentMonthYear) || expiryDateTime.isAtSameMomentAs(currentMonthYear);
  }
}