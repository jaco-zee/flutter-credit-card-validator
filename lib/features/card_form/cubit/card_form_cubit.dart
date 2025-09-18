import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/formatting/masking.dart';
import '../../../core/utils/bin_patterns.dart';
import '../../../core/utils/luhn.dart';
import '../../../data/datasources/local/card_local_ds.dart';
import '../../../domain/entities/credit_card.dart';
import '../../../domain/value_objects/card_brand.dart';
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
    final cardNumberValidation = validateCardNumber(state.rawNumber);
    final cvvValidation = validateCvv(state.cvv, state.brand);
    final nameValidation = validateCardHolderName(state.cardHolderName);
    final expiryValidation = validateExpiryDate(state.expiryDate);
    final countryValidation = validateCountry(state.countryCode);
    
    final isValid = cardNumberValidation.isEmpty && 
                   cvvValidation.isEmpty && 
                   nameValidation.isEmpty && 
                   expiryValidation.isEmpty && 
                   countryValidation.isEmpty;
    
    emit(state.copyWith(
      isValid: isValid,
      cardNumberError: cardNumberValidation,
      cvvError: cvvValidation,
      cardHolderNameError: nameValidation,
      expiryDateError: expiryValidation,
      countryError: countryValidation,
    ));
  }

  // Validation methods that return error messages (empty string means valid)
  String validateCardNumber(String number) {
    if (number.isEmpty) {
      return 'Please enter card number';
    }
    if (!LuhnValidator.isValid(number)) {
      return 'Please enter a valid card number';
    }
    return '';
  }

  String validateCvv(String cvv, CardBrand brand) {
    final expectedLength = brand == CardBrand.americanExpress ? 4 : 3;
    if (cvv.isEmpty) {
      return 'Please enter CVV';
    }
    if (cvv.length != expectedLength) {
      return 'CVV must be $expectedLength digits';
    }
    return '';
  }

  String validateCardHolderName(String name) {
    final trimmedName = name.trim();
    if (trimmedName.isEmpty) {
      return 'Please enter card holder name';
    }
    if (trimmedName.length < 2) {
      return 'Name must be at least 2 characters';
    }
    return '';
  }

  String validateExpiryDate(String date) {
    if (date.isEmpty) {
      return 'Please enter expiry date';
    }
    if (date.length != 5 || !date.contains('/')) {
      return 'Enter date as MM/YY';
    }
    
    final parts = date.split('/');
    final month = int.tryParse(parts[0]);
    final year = int.tryParse(parts[1]);
    
    if (month == null || month < 1 || month > 12) {
      return 'Invalid month';
    }
    
    // Check if expired
    final now = DateTime.now();
    final fullYear = year! + 2000;
    final expiryDate = DateTime(fullYear, month);
    final currentMonthYear = DateTime(now.year, now.month);
    
    if (expiryDate.isBefore(currentMonthYear)) {
      return 'Card has expired';
    }
    
    return '';
  }

  String validateCountry(String countryCode) {
    if (countryCode.isEmpty) {
      return 'Please select a country';
    }
    return '';
  }
}