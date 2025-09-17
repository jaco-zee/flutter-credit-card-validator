import 'package:flutter/material.dart';
import '../../../core/theme/card_colors.dart';
import '../../../domain/entities/credit_card.dart';
import '../../../domain/value_objects/card_brand.dart';

class MiniCreditCardWidget extends StatelessWidget {
  const MiniCreditCardWidget({
    super.key,
    required this.card,
    this.onTap,
    this.height = 100,
  });

  final CreditCard card;
  final VoidCallback? onTap;
  final double height;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: height,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: CardColors.getCardGradient(card.brand),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Left side: Card info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Brand logo and name
                    Row(
                      children: [
                        _buildBrandIcon(card.brand),
                        const SizedBox(width: 8),
                        Text(
                          card.brand.name.toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                    
                    // Card number (last 4 digits)
                    Text(
                      '•••• ${_getLastFourDigits(card.number)}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontFamily: 'Courier',
                        fontWeight: FontWeight.w600,
                        letterSpacing: 2,
                      ),
                    ),
                    
                    // Country
                    Text(
                      card.issuingCountry,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Right side: EMV chip
              _buildMiniChip(),
            ],
          ),
        ),
      ),
    );
  }

  //brand icon
  Widget _buildBrandIcon(CardBrand brand) {
    IconData iconData;
    
    switch (brand) {
      case CardBrand.visa:
      case CardBrand.mastercard:
      case CardBrand.americanExpress:
      case CardBrand.discover:
      case CardBrand.dinersClub:
      case CardBrand.jcb:
        iconData = Icons.credit_card;
        break;
      default:
        iconData = Icons.credit_card_outlined;
    }
    
    return Icon(
      iconData,
      color: Colors.white,
      size: 20,
    );
  }

  // mini EMV chip widget
  Widget _buildMiniChip() {
    return Container(
      width: 24,
      height: 18,
      decoration: BoxDecoration(
        color: Colors.amber[400],
        borderRadius: BorderRadius.circular(3),
        border: Border.all(
          color: Colors.amber[600]!,
          width: 0.5,
        ),
      ),
      child: Container(
        margin: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          color: Colors.amber[300],
          borderRadius: BorderRadius.circular(1.5),
        ),
        child: const Center(
          child: Icon(
            Icons.memory,
            color: Colors.amber,
            size: 10,
          ),
        ),
      ),
    );
  }

  //Gets the last four digits of the card number
  String _getLastFourDigits(String number) {
    if (number.length >= 4) {
      return number.substring(number.length - 4);
    }
    return number;
  }
}