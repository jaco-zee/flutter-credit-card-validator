import 'package:equatable/equatable.dart';
import '../../../domain/value_objects/card_brand.dart';

enum SubmitStatus { idle, submitting, success, error }

/// State for the card form feature
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
  ];
}