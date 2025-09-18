import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/value_objects/card_brand.dart';
import '../../scan/cubit/scan_cubit.dart';
import '../../scan/cubit/scan_state.dart';
import '../cubit/card_form_cubit.dart';
import '../cubit/card_form_state.dart';
import '../widgets/widgets.dart';

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
          _lastShownError = null;
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
                        
                        CardNumberFormField(
                          controller: _numberController,
                          onChanged: (value) => context.read<CardFormCubit>().onNumberChanged(value),
                        ),
                        const SizedBox(height: 20),
                        BrandChipWidget(brand: state.brand),
                        const SizedBox(height: 20),
                        const ScanButtonWidget(),
                        const SizedBox(height: 20),
                        CvvFormField(
                          controller: _cvvController,
                          onChanged: (value) => context.read<CardFormCubit>().onCvvChanged(value),
                        ),
                        const SizedBox(height: 20),
                        CardHolderNameFormField(
                          controller: _cardHolderNameController,
                          onChanged: (value) => context.read<CardFormCubit>().onCardHolderNameChanged(value),
                        ),
                        const SizedBox(height: 20),
                        ExpiryDateFormField(
                          controller: _expiryDateController,
                          onChanged: (value) => context.read<CardFormCubit>().onExpiryDateChanged(value),
                        ),
                        const SizedBox(height: 20),
                        CountryDropdownFormField(
                          value: _selectedCountry,
                          onChanged: (value) {
                            setState(() {
                              _selectedCountry = value;
                            });
                            if (value != null) {
                              context.read<CardFormCubit>().onCountryChanged(value);
                            }
                          },
                        ),
                        const SizedBox(height: 32),
                        
                        SubmitButtonWidget(
                          onSubmit: () => context.read<CardFormCubit>().onSubmit(),
                        ),
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
}