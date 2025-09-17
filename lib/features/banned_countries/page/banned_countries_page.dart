import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../app/di.dart';
import '../cubit/banned_countries_cubit.dart';
import '../presenter/banned_countries_presenter.dart';

class BannedCountriesPage extends StatelessWidget {
  const BannedCountriesPage({super.key});
  
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => BannedCountriesCubit(getIt())..load(),
      child: Scaffold(
        backgroundColor: const Color(0xFFFAFAFA),
        appBar: AppBar(
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.block,
                  color: Colors.red,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text('Banned Countries'),
            ],
          ),
        ),
        body: const BannedCountriesPresenter(),
      ),
    );
  }
}