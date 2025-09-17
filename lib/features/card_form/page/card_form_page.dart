import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../app/di.dart';
import '../../scan/cubit/scan_cubit.dart';
import '../cubit/card_form_cubit.dart';
import '../presenter/card_form_presenter.dart';

/// Page for adding a new credit card
class CardFormPage extends StatelessWidget {
  const CardFormPage({super.key});
  
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => CardFormCubit(
            getIt(),
            context.read(),
          ),
        ),
        BlocProvider(
          create: (context) => ScanCubit(),
        ),
      ],
      child: Scaffold(
        backgroundColor: const Color(0xFFFAFAFA),
        appBar: AppBar(
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.add_card,
                  color: Theme.of(context).primaryColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text('Add New Card'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
          ],
        ),
        body: CardFormPresenter(
          onSuccess: () => Navigator.of(context).pop(),
        ),
      ),
    );
  }
}