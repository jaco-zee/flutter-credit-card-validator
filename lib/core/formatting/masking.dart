/// Utility functions for credit card number masking and formatting
class CardFormatter {
  // Private constructor to prevent instantiation
  CardFormatter._();

  /// Masks a credit card number showing only the last 4 digits
  /// Example: "4111111111111111" -> "#### #### #### 1111"
  static String maskCardNumber(String cardNumber) {
    final normalized = cardNumber.replaceAll(RegExp(r'\D'), '');
    
    if (normalized.length < 4) {
      return cardNumber;
    }
    
    final last4 = normalized.substring(normalized.length - 4);
    final maskedPart = '#' * (normalized.length - 4);
    
    return _addSpacing('$maskedPart$last4');
  }
  
  /// Formats a credit card number with standard spacing
  /// Example: "4111111111111111" -> "4111 1111 1111 1111"
  static String formatCardNumber(String cardNumber) {
    final normalized = cardNumber.replaceAll(RegExp(r'\D'), '');
    return _addSpacing(normalized);
  }
  
  /// Adds standard 4-digit grouping to a card number
  static String _addSpacing(String cardNumber) {
    if (cardNumber.length <= 4) return cardNumber;
    
    final buffer = StringBuffer();
    for (int i = 0; i < cardNumber.length; i++) {
      if (i > 0 && i % 4 == 0) {
        buffer.write(' ');
      }
      buffer.write(cardNumber[i]);
    }
    return buffer.toString();
  }
  
  /// Gets the last 4 digits of a card number
  static String getLastFourDigits(String cardNumber) {
    final normalized = cardNumber.replaceAll(RegExp(r'\D'), '');
    return normalized.length >= 4 ? normalized.substring(normalized.length - 4) : normalized;
  }
  
  /// Formats display text for a masked card
  /// Example: "#### #### #### 1111 | Visa | US"
  static String formatCardDisplay(String maskedNumber, String brand, String country) {
    return '$maskedNumber | $brand | $country';
  }
}