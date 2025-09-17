import 'package:equatable/equatable.dart';
import '../value_objects/card_brand.dart';

class CreditCard extends Equatable {
  const CreditCard({
    required this.number,
    required this.brand,
    required this.cardHolderName,
    required this.expiryDate,
    required this.issuingCountry,
    required this.savedAt,
  });
  
  final String number;
  final CardBrand brand;
  final String cardHolderName;
  final String expiryDate;
  final String issuingCountry;
  final DateTime savedAt;
  String get lastFourDigits => number.length >= 4 ? number.substring(number.length - 4) : number;
  String get maskedNumber {
    if (number.length < 4) return number;
    final last4 = lastFourDigits;
    final maskedPart = '#' * (number.length - 4);
    return _formatWithSpaces('$maskedPart$last4');
  }
  
  String _formatWithSpaces(String cardNumber) {
    final buffer = StringBuffer();
    for (int i = 0; i < cardNumber.length; i++) {
      if (i > 0 && i % 4 == 0) {
        buffer.write(' ');
      }
      buffer.write(cardNumber[i]);
    }
    return buffer.toString();
  }
  
  @override
  List<Object?> get props => [number, brand, cardHolderName, expiryDate, issuingCountry, savedAt];
  
  @override
  String toString() => 'CreditCard($maskedNumber, $cardHolderName, ${brand.displayName}, $issuingCountry, expires: $expiryDate)';
}