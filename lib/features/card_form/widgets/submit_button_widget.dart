import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubit/card_form_cubit.dart';
import '../cubit/card_form_state.dart';

class SubmitButtonWidget extends StatelessWidget {
  const SubmitButtonWidget({
    super.key,
    required this.onSubmit,
  });

  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CardFormCubit, CardFormState>(
      builder: (context, state) {
        final isSubmitting = state.submitStatus == SubmitStatus.submitting;
        final isValid = state.isValid;
        
        return SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: (isValid && !isSubmitting) 
                ? onSubmit
                : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: isValid 
                  ? Theme.of(context).primaryColor 
                  : Colors.grey.shade300,
              foregroundColor: Colors.white,
              elevation: isValid ? 4 : 0,
              shadowColor: Theme.of(context).primaryColor.withOpacity(0.3),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: isSubmitting 
                ? const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      ),
                      SizedBox(width: 12),
                      Text(
                        'Saving Card...',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  )
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isValid ? Icons.save : Icons.save_outlined,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Save Credit Card',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: isValid ? Colors.white : Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
          ),
        );
      },
    );
  }
}