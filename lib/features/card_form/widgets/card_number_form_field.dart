import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../domain/value_objects/card_brand.dart';

// text form field for credit card number input
class CardNumberFormField extends StatelessWidget {
  const CardNumberFormField({
    super.key,
    required this.controller,
    required this.brand,
    required this.onChanged,
    this.validator,
  });

  final TextEditingController controller;
  final CardBrand brand;
  final ValueChanged<String> onChanged;
  final FormFieldValidator<String>? validator;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: 'Card Number',
        hintText: '1234 5678 9012 3456',
        filled: true,
        fillColor: Colors.grey.shade50,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 2),
        ),
        prefixIcon: Container(
          padding: const EdgeInsets.all(12),
          child: Icon(
            Icons.credit_card,
            color: brand != CardBrand.unknown 
                ? Theme.of(context).primaryColor 
                : Colors.grey.shade400,
          ),
        ),
      ),
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        letterSpacing: 1,
      ),
      keyboardType: TextInputType.number,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(19),
        _CardNumberInputFormatter(),
      ],
      onChanged: onChanged,
      validator: validator,
    );
  }
}

/// Input formatter for card numbers that adds spaces every 4 digits
class _CardNumberInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text.replaceAll(' ', '');
    final buffer = StringBuffer();
    
    for (int i = 0; i < text.length; i++) {
      if (i > 0 && i % 4 == 0) {
        buffer.write(' ');
      }
      buffer.write(text[i]);
    }
    
    final formatted = buffer.toString();
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}