import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/value_objects/card_brand.dart';
import '../cubit/card_form_cubit.dart';
import '../cubit/card_form_state.dart';

// A specialized form field for CVV input with brand-specific validation
class CvvFormField extends StatelessWidget {
  const CvvFormField({
    super.key,
    required this.controller,
    required this.onChanged,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CardFormCubit, CardFormState>(
      builder: (context, state) {
        final expectedLength = state.brand == CardBrand.americanExpress ? 4 : 3;
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              controller: controller,
              decoration: InputDecoration(
                labelText: 'CVV',
                hintText: expectedLength == 4 ? '1234' : '123',
                hintStyle: TextStyle(color: Colors.grey.shade400),
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
                    Icons.lock,
                    color: state.cvv.isNotEmpty && state.cvv.length == expectedLength
                        ? Theme.of(context).primaryColor
                        : Colors.grey.shade400,
                  ),
                ),
                suffixIcon: Tooltip(
                  message: expectedLength == 4 
                      ? 'American Express CVV is 4 digits on the front'
                      : 'CVV is 3 digits on the back of your card',
                  child: Icon(
                    Icons.help_outline,
                    color: Colors.grey.shade400,
                  ),
                ),
                errorText: state.cvvError.isEmpty ? null : state.cvvError,
              ),
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                letterSpacing: 1,
              ),
              keyboardType: TextInputType.number,
              obscureText: true,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(expectedLength),
              ],
              onChanged: onChanged,
              validator: (value) {
                return null;
              },
            ),
          ],
        );
      },
    );
  }
}