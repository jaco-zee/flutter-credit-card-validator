import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/entities/credit_card.dart';
import '../../../domain/value_objects/card_brand.dart';
import 'cards_filter_state.dart';

/// Cubit for filtering and searching credit cards
class CardsFilterCubit extends Cubit<CardsFilterState> {
  CardsFilterCubit() : super(const CardsFilterState());
  
  /// Updates the base cards list (called when cards are loaded/updated)
  void updateBaseCards(List<CreditCard> cards) {
    emit(state.copyWith(baseCards: cards));
    _applyFilters();
  }
  
  /// Sets search query
  void setQuery(String query) {
    emit(state.copyWith(query: query.trim()));
    _applyFilters();
  }
  
  /// Toggles a brand filter
  void toggleBrand(CardBrand brand) {
    final selected = Set<CardBrand>.from(state.selectedBrands);
    if (selected.contains(brand)) {
      selected.remove(brand);
    } else {
      selected.add(brand);
    }
    emit(state.copyWith(selectedBrands: selected));
    _applyFilters();
  }
  
  /// Toggles a country filter
  void toggleCountry(String countryCode) {
    final selected = Set<String>.from(state.selectedCountries);
    if (selected.contains(countryCode)) {
      selected.remove(countryCode);
    } else {
      selected.add(countryCode);
    }
    emit(state.copyWith(selectedCountries: selected));
    _applyFilters();
  }
  
  /// Sets sort option
  void setSortOption(SortOption option) {
    emit(state.copyWith(sortOption: option));
    _applyFilters();
  }
  
  /// Clears all filters
  void clearAll() {
    emit(state.copyWith(
      query: '',
      selectedBrands: const <CardBrand>{},
      selectedCountries: const <String>{},
      sortOption: SortOption.newestFirst,
    ));
    _applyFilters();
  }
  
  /// Applies all active filters to create the filtered list
  void _applyFilters() {
    List<CreditCard> filtered = List<CreditCard>.from(state.baseCards);
    
    // Apply search query
    if (state.query.isNotEmpty) {
      final queryLower = state.query.toLowerCase();
      filtered = filtered.where((card) {
        return card.brand.displayName.toLowerCase().contains(queryLower) ||
               card.lastFourDigits.contains(queryLower) ||
               card.issuingCountry.toLowerCase().contains(queryLower) ||
               card.maskedNumber.toLowerCase().contains(queryLower);
      }).toList();
    }
    
    // Apply brand filters
    if (state.selectedBrands.isNotEmpty) {
      filtered = filtered.where((card) => state.selectedBrands.contains(card.brand)).toList();
    }
    
    // Apply country filters
    if (state.selectedCountries.isNotEmpty) {
      filtered = filtered.where((card) => state.selectedCountries.contains(card.issuingCountry)).toList();
    }
    
    // Apply sorting
    switch (state.sortOption) {
      case SortOption.newestFirst:
        filtered.sort((a, b) => b.savedAt.compareTo(a.savedAt));
        break;
      case SortOption.oldestFirst:
        filtered.sort((a, b) => a.savedAt.compareTo(b.savedAt));
        break;
      case SortOption.brandAToZ:
        filtered.sort((a, b) => a.brand.displayName.compareTo(b.brand.displayName));
        break;
      case SortOption.brandZToA:
        filtered.sort((a, b) => b.brand.displayName.compareTo(a.brand.displayName));
        break;
    }
    
    emit(state.copyWith(filteredCards: filtered));
  }
}