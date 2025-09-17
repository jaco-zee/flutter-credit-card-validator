import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../domain/entities/credit_card.dart';
import 'mini_credit_card_widget.dart';

// bottom sheet widget for displaying detailed card information
class CardDetailsBottomSheet extends StatelessWidget {
  const CardDetailsBottomSheet({
    super.key,
    required this.card,
    this.onDelete,
  });

  final CreditCard card;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.6,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          
          // Card preview
          Padding(
            padding: const EdgeInsets.all(20),
            child: MiniCreditCardWidget(
              card: card,
              height: 120,
            ),
          ),
          
          // Card details
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Card Details',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  // Scrollable details section
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildDetailRow('Card Number', card.maskedNumber),
                          _buildDetailRow('Card Holder', card.cardHolderName.isNotEmpty ? card.cardHolderName : 'Not specified'),
                          _buildDetailRow('Expiry Date', card.expiryDate.isNotEmpty ? card.expiryDate : 'Not specified'),
                          _buildDetailRow('Brand', card.brand.displayName),
                          _buildDetailRow('Issuing Country', card.issuingCountry),
                          _buildDetailRow('Added', DateFormat.yMMMd().add_jm().format(card.savedAt)),
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Delete button
                  if (onDelete != null)
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: onDelete,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        icon: const Icon(Icons.delete),
                        label: const Text('Delete Card'),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontFamily: 'monospace',
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Helper method to show the card details bottom sheet
  static void show(BuildContext context, CreditCard card, {VoidCallback? onDelete}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CardDetailsBottomSheet(
        card: card,
        onDelete: onDelete,
      ),
    );
  }
}