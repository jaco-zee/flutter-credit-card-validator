import 'package:flutter/material.dart';
import '../../../domain/value_objects/country_code.dart';

// dropdown form field for country selection
class CountryDropdownFormField extends StatelessWidget {
  const CountryDropdownFormField({
    super.key,
    required this.value,
    required this.onChanged,
    this.validator,
  });

  final String? value;
  final ValueChanged<String?> onChanged;
  final FormFieldValidator<String>? validator;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        labelText: 'Issuing Country',
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
            Icons.public,
            color: value != null
                ? Theme.of(context).primaryColor
                : Colors.grey.shade400,
          ),
        ),
      ),
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: Colors.grey.shade800,
      ),
      dropdownColor: Colors.white,
      items: CountryCode.common
          .map((country) => DropdownMenuItem<String>(
                value: country.code,
                child: Text(
                  country.toString(),
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey.shade800,
                  ),
                ),
              ))
          .toList(),
      onChanged: onChanged,
      validator: validator,
    );
  }
}