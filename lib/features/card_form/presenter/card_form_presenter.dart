import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/utils/bin_patterns.dart';
import '../../../core/utils/luhn.dart';
import '../../../domain/value_objects/card_brand.dart';
import '../../../domain/value_objects/country_code.dart';
import '../../scan/cubit/scan_cubit.dart';
import '../../scan/cubit/scan_state.dart';
import '../cubit/card_form_cubit.dart';
import '../cubit/card_form_state.dart';
import '../widgets/credit_card_widget.dart';

class CardFormPresenter extends StatefulWidget {
  const CardFormPresenter({super.key, this.onSuccess});
  
  final VoidCallback? onSuccess;
  
  @override
  State<CardFormPresenter> createState() => _CardFormPresenterState();
}

class _CardFormPresenterState extends State<CardFormPresenter> {
  final _formKey = GlobalKey<FormState>();
  final _numberController = TextEditingController();
  final _cvvController = TextEditingController();
  final _cardHolderNameController = TextEditingController();
  final _expiryDateController = TextEditingController();
  String? _selectedCountry;
  String? _lastShownError;
  
  @override
  void initState() {
    super.initState();
    // Listen to scan results
    context.read<ScanCubit>().stream.listen((scanState) {
      if (scanState.status == ScanStatus.success && mounted) {
        _numberController.text = scanState.scannedNumber;
        if (scanState.scannedCardHolderName.isNotEmpty) {
          _cardHolderNameController.text = scanState.scannedCardHolderName;
        }
        if (scanState.scannedExpiryDate.isNotEmpty) {
          _expiryDateController.text = scanState.scannedExpiryDate;
        }
        if (mounted) {
          context.read<CardFormCubit>().onScannedData(
            scanState.scannedNumber, 
            scanState.scannedCardHolderName.isNotEmpty ? scanState.scannedCardHolderName : null,
            scanState.scannedExpiryDate.isNotEmpty ? scanState.scannedExpiryDate : null,
          );
          context.read<ScanCubit>().reset();
        }
      }
    });
  }
  
  @override
  void dispose() {
    _numberController.dispose();
    _cvvController.dispose();
    _cardHolderNameController.dispose();
    _expiryDateController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CardFormCubit, CardFormState>(
      listener: (context, state) {
        if (state.submitStatus == SubmitStatus.success) {
          _lastShownError = null; // Clear error tracking on success
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Card added successfully!'),
              backgroundColor: Colors.green,
            ),
          );
          widget.onSuccess?.call();
        } else if (state.submitStatus == SubmitStatus.error && 
                   state.errorMessage.isNotEmpty && 
                   _lastShownError != state.errorMessage) {
          // Only show error if it's different from the last shown error
          _lastShownError = state.errorMessage;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage),
              backgroundColor: Colors.red,
              action: SnackBarAction(
                label: 'Dismiss',
                textColor: Colors.white,
                onPressed: () {
                  context.read<CardFormCubit>().clearMessage();
                },
              ),
            ),
          );
        } else if (state.submitStatus == SubmitStatus.idle) {
          _lastShownError = null;
        }
      },
      builder: (context, state) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.grey.shade50,
                Colors.white,
              ],
            ),
          ),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Visual Credit Card
                  Center(
                    child: CreditCardWidget(
                      cardNumber: state.rawNumber,
                      brand: state.brand == CardBrand.unknown ? null : state.brand,
                      cardHolderName: state.cardHolderName.isNotEmpty ? state.cardHolderName : null,
                      expiryDate: state.expiryDate.isNotEmpty ? state.expiryDate : null,
                      country: _selectedCountry,
                    ),
                  ),
                  
                  const SizedBox(height: 40),
                  
                  // Form Fields
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'Card Details',
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.grey.shade800,
                          ),
                        ),
                        
                        const SizedBox(height: 24),
                        
                        _buildCardNumberField(context, state),
                        const SizedBox(height: 20),
                        _buildBrandChip(state),
                        const SizedBox(height: 20),
                        _buildScanButton(context),
                        const SizedBox(height: 20),
                        _buildCvvField(context, state),
                        const SizedBox(height: 20),
                        _buildCardHolderNameField(context, state),
                        const SizedBox(height: 20),
                        _buildExpiryDateField(context, state),
                        const SizedBox(height: 20),
                        _buildCountryField(context, state),
                        const SizedBox(height: 32),
                        // Validation hint
                        if (!state.isValid)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: _buildValidationHint(state),
                          ),
                        
                        _buildSubmitButton(context, state),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
  
  Widget _buildCardNumberField(BuildContext context, CardFormState state) {
    return TextFormField(
      controller: _numberController,
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
            color: state.brand != CardBrand.unknown 
                ? Theme.of(context).primaryColor 
                : Colors.grey.shade400,
          ),
        ),
        errorText: state.rawNumber.isNotEmpty && !_isValidCardNumber(state.rawNumber) 
            ? 'Invalid card number' 
            : null,
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
      onChanged: (value) {
        context.read<CardFormCubit>().onNumberChanged(value);
      },
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter card number';
        }
        if (!_isValidCardNumber(state.rawNumber)) {
          return 'Please enter a valid card number';
        }
        return null;
      },
    );
  }
  
  Widget _buildBrandChip(CardFormState state) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(
            Icons.verified,
            size: 20,
            color: state.brand != CardBrand.unknown 
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
              color: state.brand == CardBrand.unknown 
                  ? Colors.grey.shade100
                  : Theme.of(context).primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: state.brand == CardBrand.unknown
                    ? Colors.grey.shade300
                    : Theme.of(context).primaryColor.withOpacity(0.3),
              ),
            ),
            child: Text(
              state.brand.displayName,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: state.brand == CardBrand.unknown
                    ? Colors.grey.shade600
                    : Theme.of(context).primaryColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildScanButton(BuildContext context) {
    return BlocConsumer<ScanCubit, ScanState>(
      listener: (context, scanState) {
        if (scanState.status == ScanStatus.error) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(scanState.errorMessage),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      builder: (context, scanState) {
        final isScanning = scanState.status == ScanStatus.scanning || 
                          scanState.status == ScanStatus.starting;
        
        return SizedBox(
          width: double.infinity,
          height: 56,
          child: OutlinedButton.icon(
            onPressed: isScanning 
                ? null 
                : () => context.read<ScanCubit>().startScan(),
            style: OutlinedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              side: BorderSide(
                color: isScanning 
                    ? Colors.grey.shade300
                    : Theme.of(context).primaryColor,
                width: 2,
              ),
            ),
            icon: isScanning 
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Theme.of(context).primaryColor,
                      ),
                    ),
                  )
                : Icon(
                    Icons.camera_alt,
                    size: 24,
                    color: Theme.of(context).primaryColor,
                  ),
            label: Text(
              isScanning ? 'Scanning...' : 'Scan Card with Camera',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: isScanning 
                    ? Colors.grey.shade500
                    : Theme.of(context).primaryColor,
              ),
            ),
          ),
        );
      },
    );
  }
  
  Widget _buildCvvField(BuildContext context, CardFormState state) {
    final expectedLength = state.brand == CardBrand.americanExpress ? 4 : 3;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextFormField(
          controller: _cvvController,
          decoration: InputDecoration(
            labelText: 'CVV',
            hintText: expectedLength == 4 ? '1234' : '123',
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
          onChanged: (value) {
            context.read<CardFormCubit>().onCvvChanged(value);
          },
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter CVV';
            }
            if (value.length != expectedLength) {
              return 'CVV must be $expectedLength digits';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildCardHolderNameField(BuildContext context, CardFormState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Card Holder Name',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade700,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _cardHolderNameController,
          decoration: InputDecoration(
            labelText: 'Full Name',
            hintText: 'John Doe',
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
                Icons.person,
                color: state.cardHolderName.isNotEmpty
                    ? Theme.of(context).primaryColor
                    : Colors.grey.shade400,
              ),
            ),
          ),
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
          textCapitalization: TextCapitalization.words,
          inputFormatters: [
            LengthLimitingTextInputFormatter(50),
          ],
          onChanged: (value) {
            context.read<CardFormCubit>().onCardHolderNameChanged(value);
          },
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Please enter card holder name';
            }
            if (value.trim().length < 2) {
              return 'Name must be at least 2 characters';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildExpiryDateField(BuildContext context, CardFormState state) {
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
          controller: _expiryDateController,
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
                color: state.expiryDate.length == 5
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
          onChanged: (value) {
            context.read<CardFormCubit>().onExpiryDateChanged(value);
          },
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter expiry date';
            }
            if (value.length != 5 || !value.contains('/')) {
              return 'Enter date as MM/YY';
            }
            final parts = value.split('/');
            final month = int.tryParse(parts[0]);
            final year = int.tryParse(parts[1]);
            
            if (month == null || month < 1 || month > 12) {
              return 'Invalid month';
            }
            
            // Check if expired
            final now = DateTime.now();
            final fullYear = year! + 2000;
            final expiryDate = DateTime(fullYear, month);
            final currentMonthYear = DateTime(now.year, now.month);
            
            if (expiryDate.isBefore(currentMonthYear)) {
              return 'Card has expired';
            }
            
            return null;
          },
        ),
      ],
    );
  }
  
  Widget _buildCountryField(BuildContext context, CardFormState state) {
    return DropdownButtonFormField<String>(
      value: _selectedCountry,
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
            color: _selectedCountry != null
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
      onChanged: (value) {
        setState(() {
          _selectedCountry = value;
        });
        if (value != null) {
          context.read<CardFormCubit>().onCountryChanged(value);
        }
      },
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please select a country';
        }
        return null;
      },
    );
  }
  
  Widget _buildSubmitButton(BuildContext context, CardFormState state) {
    final isSubmitting = state.submitStatus == SubmitStatus.submitting;
    final isValid = state.isValid;
    
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: (isValid && !isSubmitting) 
            ? () {
                if (_formKey.currentState!.validate()) {
                  context.read<CardFormCubit>().onSubmit();
                }
              }
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
  }

  Widget _buildValidationHint(CardFormState state) {
    List<String> issues = [];
    
    if (state.rawNumber.isEmpty || !LuhnValidator.isValid(state.rawNumber)) {
      issues.add('Enter a valid card number');
    }
    if (!BinPatterns.isValidCvvLength(state.cvv, state.brand)) {
      final expectedLength = BinPatterns.getCvvLength(state.brand);
      issues.add('CVV must be $expectedLength digits');
    }
    if (state.cardHolderName.trim().isEmpty) {
      issues.add('Enter card holder name');
    }
    if (state.expiryDate.length != 5 || !state.expiryDate.contains('/')) {
      issues.add('Enter expiry date (MM/YY)');
    }
    if (state.countryCode.isEmpty) {
      issues.add('Select issuing country');
    }
    
    if (issues.isEmpty) return const SizedBox.shrink();
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.orange.shade200),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: Colors.orange.shade700, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              issues.join(' • '),
              style: TextStyle(
                color: Colors.orange.shade700,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  bool _isValidCardNumber(String number) {
    // This would use the Luhn validator
    return number.isNotEmpty && number.length >= 13;
  }
}

/// Input formatter for card numbers with spacing
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
    
    final formattedText = buffer.toString();
    return TextEditingValue(
      text: formattedText,
      selection: TextSelection.collapsed(offset: formattedText.length),
    );
  }
}

/// Input formatter for expiry date with MM/YY format
class _ExpiryDateInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text.replaceAll(RegExp(r'\D'), '');
    
    if (text.length <= 2) {
      return TextEditingValue(
        text: text,
        selection: TextSelection.collapsed(offset: text.length),
      );
    } else {
      final month = text.substring(0, 2);
      final year = text.substring(2, text.length > 4 ? 4 : text.length);
      final formattedText = '$month/$year';
      
      return TextEditingValue(
        text: formattedText,
        selection: TextSelection.collapsed(offset: formattedText.length),
      );
    }
  }
}