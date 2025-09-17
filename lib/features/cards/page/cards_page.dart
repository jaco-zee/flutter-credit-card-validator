import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/value_objects/card_brand.dart';
import '../../../domain/value_objects/country_code.dart';
import '../../card_form/page/card_form_page.dart';
import '../cubit/cards_cubit.dart';
import '../cubit/cards_state.dart';
import '../filter/cards_filter_cubit.dart';
import '../filter/cards_filter_state.dart';
import '../presenter/cards_presenter.dart';

/// Page for displaying and managing credit cards
class CardsPage extends StatelessWidget {
  const CardsPage({super.key});
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                Icons.credit_card,
                color: Theme.of(context).primaryColor,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            const Text('My Cards'),
          ],
        ),
        actions: [
          BlocBuilder<CardsFilterCubit, CardsFilterState>(
            builder: (context, filterState) {
              final hasActiveFilters = filterState.query.isNotEmpty ||
                  filterState.selectedBrands.isNotEmpty ||
                  filterState.selectedCountries.isNotEmpty;
              
              return Stack(
                children: [
                  IconButton(
                    icon: Icon(
                      hasActiveFilters ? Icons.filter_alt : Icons.filter_list,
                      color: hasActiveFilters 
                          ? Theme.of(context).primaryColor 
                          : null,
                    ),
                    onPressed: () => _showFilterBottomSheet(context),
                  ),
                  if (hasActiveFilters)
                    Positioned(
                      right: 8,
                      top: 8,
                      child: Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => _navigateToSettings(context),
          ),
        ],
      ),
      body: CardsPresenter(
        onAddCard: () => _navigateToCardForm(context),
        onOpenFilter: () => _showFilterBottomSheet(context),
      ),
      floatingActionButton: BlocBuilder<CardsCubit, CardsState>(
        builder: (context, state) {
          // Only show FAB if there are cards saved
          if (state.cards.isEmpty) {
            return const SizedBox.shrink();
          }
          
          return Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Theme.of(context).primaryColor.withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: FloatingActionButton.extended(
              onPressed: () => _navigateToCardForm(context),
              icon: const Icon(Icons.add),
              label: const Text('Add Card'),
              backgroundColor: Theme.of(context).primaryColor,
              foregroundColor: Colors.white,
            ),
          );
        },
      ),
    );
  }
  
  void _navigateToCardForm(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const CardFormPage(),
      ),
    ).then((_) {
      // Reload cards when returning from form
      if (context.mounted) {
        context.read<CardsCubit>().load();
      }
    });
  }
  
  void _navigateToSettings(BuildContext context) {
    Navigator.of(context).pushNamed('/settings');
  }
  
  void _showFilterBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.8,
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
            
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Filter & Sort',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  BlocBuilder<CardsFilterCubit, CardsFilterState>(
                    builder: (context, state) {
                      final hasActiveFilters = state.query.isNotEmpty ||
                          state.selectedBrands.isNotEmpty ||
                          state.selectedCountries.isNotEmpty;
                      
                      return TextButton(
                        onPressed: hasActiveFilters
                            ? () => context.read<CardsFilterCubit>().clearAll()
                            : null,
                        child: Text(
                          'Clear All',
                          style: TextStyle(
                            color: hasActiveFilters
                                ? Theme.of(context).primaryColor
                                : Colors.grey.shade400,
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            
            const Divider(),
            
            // Filter content
            Expanded(
              child: BlocBuilder<CardsFilterCubit, CardsFilterState>(
                builder: (context, state) => SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSearchField(context, state),
                      const SizedBox(height: 32),
                      _buildBrandFilters(context, state),
                      const SizedBox(height: 32),
                      _buildCountryFilters(context, state),
                      const SizedBox(height: 32),
                      _buildSortOptions(context, state),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildSearchField(BuildContext context, CardsFilterState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.search,
              size: 20,
              color: Theme.of(context).primaryColor,
            ),
            const SizedBox(width: 8),
            Text(
              'Search Cards',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        TextField(
          decoration: InputDecoration(
            hintText: 'Search by brand, last 4 digits, or country...',
            prefixIcon: const Icon(Icons.search),
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
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
          style: const TextStyle(fontSize: 16),
          onChanged: (query) => context.read<CardsFilterCubit>().setQuery(query),
        ),
      ],
    );
  }
  
  Widget _buildBrandFilters(BuildContext context, CardsFilterState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.credit_card,
              size: 20,
              color: Theme.of(context).primaryColor,
            ),
            const SizedBox(width: 8),
            Text(
              'Card Brands',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            if (state.selectedBrands.isNotEmpty) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${state.selectedBrands.length}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: CardBrand.values
              .where((brand) => brand != CardBrand.unknown)
              .map((brand) => FilterChip(
                    label: Text(brand.displayName),
                    selected: state.selectedBrands.contains(brand),
                    onSelected: (_) => context.read<CardsFilterCubit>().toggleBrand(brand),
                    backgroundColor: Colors.grey.shade100,
                    selectedColor: Theme.of(context).primaryColor.withOpacity(0.2),
                    checkmarkColor: Theme.of(context).primaryColor,
                    labelStyle: TextStyle(
                      color: state.selectedBrands.contains(brand)
                          ? Theme.of(context).primaryColor
                          : Colors.grey.shade700,
                      fontWeight: FontWeight.w500,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: BorderSide(
                        color: state.selectedBrands.contains(brand)
                            ? Theme.of(context).primaryColor
                            : Colors.grey.shade300,
                      ),
                    ),
                  ))
              .toList(),
        ),
      ],
    );
  }
  
  Widget _buildCountryFilters(BuildContext context, CardsFilterState state) {
    // Get unique countries from the current cards
    final availableCountries = context.read<CardsFilterCubit>().state.baseCards
        .map((card) => card.issuingCountry)
        .toSet()
        .toList()
      ..sort();
    
    if (availableCountries.isEmpty) {
      return const SizedBox.shrink();
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Issuing Countries',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 4,
          children: availableCountries.map((countryCode) {
            final country = CountryCode.findByCode(countryCode);
            final displayName = country?.name ?? countryCode;
            
            return FilterChip(
              label: Text(displayName),
              selected: state.selectedCountries.contains(countryCode),
              onSelected: (_) => context.read<CardsFilterCubit>().toggleCountry(countryCode),
            );
          }).toList(),
        ),
      ],
    );
  }
  
  Widget _buildSortOptions(BuildContext context, CardsFilterState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Sort By',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Column(
          children: SortOption.values.map((option) {
            String label;
            switch (option) {
              case SortOption.newestFirst:
                label = 'Newest First';
                break;
              case SortOption.oldestFirst:
                label = 'Oldest First';
                break;
              case SortOption.brandAToZ:
                label = 'Brand A-Z';
                break;
              case SortOption.brandZToA:
                label = 'Brand Z-A';
                break;
            }
            
            return RadioListTile<SortOption>(
              title: Text(label),
              value: option,
              groupValue: state.sortOption,
              onChanged: (value) {
                if (value != null) {
                  context.read<CardsFilterCubit>().setSortOption(value);
                }
              },
            );
          }).toList(),
        ),
      ],
    );
  }
}