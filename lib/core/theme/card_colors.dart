import 'package:flutter/material.dart';
import '../../domain/value_objects/card_brand.dart';

/// Utility class for card-related colors and gradients
class CardColors {
  // Private constructor to prevent instantiation
  CardColors._();

  /// Gets gradient colors based on card brand
  static LinearGradient getCardGradient(CardBrand? brand) {
    switch (brand) {
      case CardBrand.visa:
        return const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF1A237E), // Deep blue
            Color(0xFF3949AB), // Lighter blue
          ],
        );
      case CardBrand.mastercard:
        return const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFD32F2F), // Red
            Color(0xFFFF7043), // Orange-red
          ],
        );
      case CardBrand.americanExpress:
        return const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF2E7D32), // Dark green
            Color(0xFF66BB6A), // Light green
          ],
        );
      case CardBrand.discover:
        return const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFFF6F00), // Orange
            Color(0xFFFFB300), // Yellow-orange
          ],
        );
      case CardBrand.dinersClub:
        return const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF424242), // Dark grey
            Color(0xFF757575), // Light grey
          ],
        );
      case CardBrand.jcb:
        return const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF7B1FA2), // Purple
            Color(0xFFBA68C8), // Light purple
          ],
        );
      default:
        return const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF37474F), // Blue grey
            Color(0xFF78909C), // Light blue grey
          ],
        );
    }
  }

  /// Common app gradients
  static const backgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFFF9FAFB),
      Colors.white,
    ],
  );

  /// Common app colors
  static const primaryDark = Color(0xFF1F2937);
  static const textSecondary = Color(0xFF374151);
  static const textMuted = Color(0xFF6B7280);
  static const borderLight = Color(0xFFE5E7EB);
  static const backgroundLight = Color(0xFFF9FAFB);
  static const backgroundCard = Color(0xFFFAFAFA);
}