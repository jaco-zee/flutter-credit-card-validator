import 'package:flutter/material.dart';
import '../../../domain/value_objects/card_brand.dart';

// detected card brand as a chip
class BrandChipWidget extends StatelessWidget {
  const BrandChipWidget({
    super.key,
    required this.brand,
  });

  final CardBrand brand;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(
            Icons.verified,
            size: 20,
            color: brand != CardBrand.unknown 
                ? Colors.green 
                : Colors.grey.shade400,
          ),
          const SizedBox(width: 8),
          Text(
            'Detected:',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: brand == CardBrand.unknown 
                  ? Colors.grey.shade100
                  : Theme.of(context).primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: brand == CardBrand.unknown
                    ? Colors.grey.shade300
                    : Theme.of(context).primaryColor.withOpacity(0.3),
              ),
            ),
            child: Text(
              brand.displayName,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: brand == CardBrand.unknown
                    ? Colors.grey.shade600
                    : Theme.of(context).primaryColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}