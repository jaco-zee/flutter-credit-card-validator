import 'package:flutter/material.dart';
import '../../../core/theme/card_colors.dart';
import '../../../domain/value_objects/card_brand.dart';

/// A realistic credit card visual widget that updates in real-time
class CreditCardWidget extends StatelessWidget {
  const CreditCardWidget({
    super.key,
    required this.cardNumber,
    this.brand,
    this.cardHolderName,
    this.expiryDate,
    this.country,
    this.width = 320,
    this.height = 200,
  });

  final String cardNumber;
  final CardBrand? brand;
  final String? cardHolderName;
  final String? expiryDate;
  final String? country;
  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: CardColors.getCardGradient(brand),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top row: Brand logo and chip
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildBrandLogo(brand),
                _buildChip(),
              ],
            ),
            
            const Spacer(flex: 2),
            
            // Card number
            Text(
              _formatCardNumber(cardNumber),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontFamily: 'Courier',
                fontWeight: FontWeight.w600,
                letterSpacing: 2,
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Bottom section: Card holder name and expiry date
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // Card holder name
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'CARD HOLDER',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        cardHolderName?.toUpperCase() ?? 'YOUR NAME',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(width: 16),
                
                // Expiry date
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'EXPIRES',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      expiryDate ?? 'MM/YY',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1,
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(width: 16),
                
                // Brand name (moved to bottom right)
                Text(
                  brand?.name.toUpperCase() ?? '',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Builds the brand logo widget
  Widget _buildBrandLogo(CardBrand? brand) {
    IconData iconData;
    Color iconColor = Colors.white;
    
    switch (brand) {
      case CardBrand.visa:
        iconData = Icons.credit_card;
        break;
      case CardBrand.mastercard:
        iconData = Icons.credit_card;
        break;
      case CardBrand.americanExpress:
        iconData = Icons.credit_card;
        break;
      case CardBrand.discover:
        iconData = Icons.credit_card;
        break;
      case CardBrand.dinersClub:
        iconData = Icons.credit_card;
        break;
      case CardBrand.jcb:
        iconData = Icons.credit_card;
        break;
      default:
        iconData = Icons.credit_card_outlined;
        iconColor = Colors.white54;
    }
    
    return Icon(
      iconData,
      color: iconColor,
      size: 32,
    );
  }

  /// Builds the EMV chip widget
  Widget _buildChip() {
    return Container(
      width: 40,
      height: 30,
      decoration: BoxDecoration(
        color: Colors.amber[400],
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: Colors.amber[600]!,
        ),
      ),
      child: Container(
        margin: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: Colors.amber[300],
          borderRadius: BorderRadius.circular(2),
        ),
        child: const Center(
          child: Icon(
            Icons.memory,
            color: Colors.amber,
            size: 16,
          ),
        ),
      ),
    );
  }

  /// Formats card number with proper spacing
  String _formatCardNumber(String number) {
    if (number.isEmpty) {
      return '•••• •••• •••• ••••';
    }
    
    // Pad with bullets if less than 16 digits
    String paddedNumber = number.padRight(16, '•');
    
    // Add spacing every 4 digits
    StringBuffer buffer = StringBuffer();
    for (int i = 0; i < paddedNumber.length; i += 4) {
      if (i > 0) buffer.write(' ');
      buffer.write(paddedNumber.substring(i, (i + 4).clamp(0, paddedNumber.length)));
    }
    
    return buffer.toString();
  }
}