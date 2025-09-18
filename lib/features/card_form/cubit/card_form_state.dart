import 'package:equatable/equatable.dart';
import '../../../domain/value_objects/card_brand.dart';

enum SubmitStatus { idle, submitting, success, error }

class CardFormState extends Equatable {
  const CardFormState({
    this.rawNumber = '',
    this.maskedNumber = '',
    this.brand = CardBrand.unknown,
    this.cvv = '',
    this.cardHolderName = '',
    this.expiryDate = '',
    this.countryCode = '',
    this.isValid = false,
    this.submitStatus = SubmitStatus.idle,
    this.errorMessage = '',
    this.cardNumberError = '',
    this.cvvError = '',
    this.cardHolderNameError = '',
    this.expiryDateError = '',
    this.countryError = '',
  });
  
  final String rawNumber;
  final String maskedNumber;
  final CardBrand brand;
  final String cvv;
  final String cardHolderName;
  final String expiryDate;
  final String countryCode;
  final bool isValid;
  final SubmitStatus submitStatus;
  final String errorMessage;
  final String cardNumberError;
  final String cvvError;
  final String cardHolderNameError;
  final String expiryDateError;
  final String countryError;
  
  CardFormState copyWith({
    String? rawNumber,
    String? maskedNumber,
    CardBrand? brand,
    String? cvv,
    String? cardHolderName,
    String? expiryDate,
    String? countryCode,
    bool? isValid,
    SubmitStatus? submitStatus,
    String? errorMessage,
    String? cardNumberError,
    String? cvvError,
    String? cardHolderNameError,
    String? expiryDateError,
    String? countryError,
  }) {
    return CardFormState(
      rawNumber: rawNumber ?? this.rawNumber,
      maskedNumber: maskedNumber ?? this.maskedNumber,
      brand: brand ?? this.brand,
      cvv: cvv ?? this.cvv,
      cardHolderName: cardHolderName ?? this.cardHolderName,
      expiryDate: expiryDate ?? this.expiryDate,
      countryCode: countryCode ?? this.countryCode,
      isValid: isValid ?? this.isValid,
      submitStatus: submitStatus ?? this.submitStatus,
      errorMessage: errorMessage ?? this.errorMessage,
      cardNumberError: cardNumberError ?? this.cardNumberError,
      cvvError: cvvError ?? this.cvvError,
      cardHolderNameError: cardHolderNameError ?? this.cardHolderNameError,
      expiryDateError: expiryDateError ?? this.expiryDateError,
      countryError: countryError ?? this.countryError,
    );
  }
  
  @override
  List<Object?> get props => [
    rawNumber,
    maskedNumber,
    brand,
    cvv,
    cardHolderName,
    expiryDate,
    countryCode,
    isValid,
    submitStatus,
    errorMessage,
    cardNumberError,
    cvvError,
    cardHolderNameError,
    expiryDateError,
    countryError,
  ];
}