import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/formatting/masking.dart';
import '../../../core/utils/bin_patterns.dart';
import '../../../core/utils/luhn.dart';
import '../../../data/datasources/local/card_local_ds.dart';
import '../../../domain/entities/credit_card.dart';
import '../../cards/cubit/cards_cubit.dart';
import 'card_form_state.dart';

/// Cubit for managing credit card form state and validation
class CardFormCubit extends Cubit<CardFormState> {
  
  CardFormCubit(this._dataSource, this._cardsCubit) : super(const CardFormState());
  final CardLocalDataSource _dataSource;
  final CardsCubit _cardsCubit;
  
  /// Updates card number and triggers validation
  void onNumberChanged(String rawNumber) {
    // Clear any previous errors when user starts typing
    if (state.submitStatus == SubmitStatus.error) {
      emit(state.copyWith(
        submitStatus: SubmitStatus.idle,
        errorMessage: '',
      ));
    }
    
    // Normalize the input
    final normalized = LuhnValidator.normalize(rawNumber);
    
    // Detect brand
    final brand = BinPatterns.detectBrand(normalized);
    
    // Format for display
    final masked = CardFormatter.formatCardNumber(normalized);
    
    emit(state.copyWith(
      rawNumber: normalized,
      maskedNumber: masked,
      brand: brand,
    ));
    
    _validateForm();
  }
  
  /// Updates CVV and triggers validation
  void onCvvChanged(String cvv) {
    // Clear any previous errors when user starts typing
    if (state.submitStatus == SubmitStatus.error) {
      emit(state.copyWith(
        submitStatus: SubmitStatus.idle,
        errorMessage: '',
      ));
    }
    
    // Only allow digits and limit to 4 characters
    final cleanedCvv = cvv.replaceAll(RegExp(r'\D'), '');
    final limitedCvv = cleanedCvv.length > 4 ? cleanedCvv.substring(0, 4) : cleanedCvv;
    
    emit(state.copyWith(cvv: limitedCvv));
    _validateForm();
  }

  /// Updates card holder name and triggers validation
  void onCardHolderNameChanged(String name) {
    // Clear any previous errors when user starts typing
    if (state.submitStatus == SubmitStatus.error) {
      emit(state.copyWith(
        submitStatus: SubmitStatus.idle,
        errorMessage: '',
      ));
    }
    
    // Clean and limit the name
    final cleanedName = name.trim();
    final limitedName = cleanedName.length > 50 ? cleanedName.substring(0, 50) : cleanedName;
    
    emit(state.copyWith(cardHolderName: limitedName));
    _validateForm();
  }

  /// Updates expiry date and triggers validation
  void onExpiryDateChanged(String date) {
    // Clear any previous errors when user starts typing
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
  
  /// Updates country code and triggers validation
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
  
  /// Updates form from scanned card data
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
  
  /// Submits the form if valid
  Future<void> onSubmit() async {
    if (!state.isValid) return;
    
    // Clear any previous operation status from cards cubit
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
      
      // Create card entity (without CVV)
      final card = CreditCard(
        number: state.rawNumber,
        brand: state.brand,
        cardHolderName: state.cardHolderName,
        expiryDate: state.expiryDate,
        issuingCountry: state.countryCode,
        savedAt: DateTime.now(),
      );
      
      // Add via CardsCubit (handles deduplication quietly)
      final success = await _cardsCubit.addCardQuietly(card);
      
      // Check if addition was successful
      if (success) {
        emit(state.copyWith(submitStatus: SubmitStatus.success));
        _resetForm();
      } else {
        // Check if it was a duplicate card error
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
  
  /// Resets form to initial state
  void resetForm() {
    _resetForm();
  }
  
  /// Clears error/success messages
  void clearMessage() {
    emit(state.copyWith(
      submitStatus: SubmitStatus.idle,
      errorMessage: '',
    ));
  }
  
  /// Internal form reset
  void _resetForm() {
    emit(const CardFormState());
  }
  
  /// Validates the entire form
  void _validateForm() {
    final isValidNumber = state.rawNumber.isNotEmpty && LuhnValidator.isValid(state.rawNumber);
    final isValidCvv = BinPatterns.isValidCvvLength(state.cvv, state.brand);
    final hasCardHolderName = state.cardHolderName.trim().isNotEmpty;
    final isValidExpiryDate = _isValidExpiryDate(state.expiryDate);
    final hasCountry = state.countryCode.isNotEmpty;
    
    final isValid = isValidNumber && isValidCvv && hasCardHolderName && isValidExpiryDate && hasCountry;
    
    emit(state.copyWith(isValid: isValid));
  }

  /// Validates expiry date format and ensures it's not expired
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