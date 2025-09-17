import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// form field for expiry date input with MM/YY format
class ExpiryDateFormField extends StatelessWidget {
  const ExpiryDateFormField({
    super.key,
    required this.controller,
    required this.onChanged,
    this.validator,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final FormFieldValidator<String>? validator;

  @override
  Widget build(BuildContext context) {
    final expiryValue = controller.text;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Expiry Date',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade700,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          decoration: InputDecoration(
            labelText: 'MM/YY',
            hintText: '12/28',
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
                Icons.calendar_today,
                color: expiryValue.length == 5
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
            _ExpiryDateInputFormatter(),
          ],
          onChanged: onChanged,
          validator: validator,
        ),
      ],
    );
  }
}

/// Input formatter for expiry dates in MM/YY format
class _ExpiryDateInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text.replaceAll('/', '');
    
    if (text.length <= 2) {
      return newValue.copyWith(text: text);
    }
    
    if (text.length <= 4) {
      final month = text.substring(0, 2);
      final year = text.substring(2);
      final formatted = '$month/$year';
      
      return newValue.copyWith(
        text: formatted,
        selection: TextSelection.collapsed(offset: formatted.length),
      );
    }
    
    return oldValue;
  }
}