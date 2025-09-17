import 'package:equatable/equatable.dart';
import '../value_objects/card_brand.dart';

/// Domain entity representing a credit card
class CreditCard extends Equatable {
  const CreditCard({
    required this.number,
    required this.brand,
    required this.cardHolderName,
    required this.expiryDate,
    required this.issuingCountry,
    required this.savedAt,
  });
  
  /// The normalized card number (digits only, no spaces/dashes)
  final String number;
  
  /// The detected/inferred card brand
  final CardBrand brand;
  
  /// The card holder's name as entered by the user
  final String cardHolderName;
  
  /// The card's expiry date in MM/YY format
  final String expiryDate;
  
  /// ISO 3166-1 alpha-2 country code of the issuing country
  final String issuingCountry;
  
  /// When this card was saved
  final DateTime savedAt;
  
  /// Returns the last 4 digits of the card number
  String get lastFourDigits => number.length >= 4 ? number.substring(number.length - 4) : number;
  
  /// Returns a masked version of the card number
  String get maskedNumber {
    if (number.length < 4) return number;
    
    final last4 = lastFourDigits;
    final maskedPart = '#' * (number.length - 4);
    
    return _formatWithSpaces('$maskedPart$last4');
  }
  
  /// Formats a card number with standard 4-digit grouping
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