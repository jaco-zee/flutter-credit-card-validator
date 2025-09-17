import '../../domain/value_objects/card_brand.dart';

/// BIN (Bank Identification Number) patterns for detecting card brands
class BinPatterns {
  // Private constructor to prevent instantiation
  BinPatterns._();

  static const Map<CardBrand, List<String>> _patterns = {
    CardBrand.visa: ['^4'],
    CardBrand.mastercard: [
      '^5[1-5]',
      '^2(22[1-9]|2[3-9][0-9]|[3-6][0-9][0-9]|7[01][0-9]|720)'
    ],
    CardBrand.americanExpress: ['^3[47]'],
    CardBrand.discover: ['^6011', '^65', '^64[4-9]', '^622'],
    CardBrand.dinersClub: ['^30[0-5]', '^36', '^38'],
    CardBrand.jcb: ['^35(2[89]|[3-8][0-9])'],
  };

  /// Detects card brand from card number using BIN patterns
  static CardBrand detectBrand(String cardNumber) {
    final normalized = cardNumber.replaceAll(RegExp(r'\D'), '');
    
    if (normalized.isEmpty) return CardBrand.unknown;
    
    for (final entry in _patterns.entries) {
      final brand = entry.key;
      final patterns = entry.value;
      
      for (final pattern in patterns) {
        if (RegExp(pattern).hasMatch(normalized)) {
          return brand;
        }
      }
    }
    
    return CardBrand.unknown;
  }
  
  /// Gets the expected CVV length for a given card brand
  static int getCvvLength(CardBrand brand) {
    switch (brand) {
      case CardBrand.americanExpress:
        return 4;
      case CardBrand.visa:
      case CardBrand.mastercard:
      case CardBrand.discover:
      case CardBrand.dinersClub:
      case CardBrand.jcb:
      case CardBrand.unknown:
        return 3;
    }
  }
  
  /// Validates CVV length for the given brand
  static bool isValidCvvLength(String cvv, CardBrand brand) {
    return cvv.length == getCvvLength(brand);
  }
}