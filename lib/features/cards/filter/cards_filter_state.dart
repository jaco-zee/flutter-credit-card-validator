import 'package:equatable/equatable.dart';
import '../../../domain/entities/credit_card.dart';
import '../../../domain/value_objects/card_brand.dart';

enum SortOption { newestFirst, oldestFirst, brandAToZ, brandZToA }

class CardsFilterState extends Equatable {
  const CardsFilterState({
    this.query = '',
    this.selectedBrands = const <CardBrand>{},
    this.selectedCountries = const <String>{},
    this.sortOption = SortOption.newestFirst,
    this.baseCards = const <CreditCard>[],
    this.filteredCards = const <CreditCard>[],
  });
  
  final String query;
  final Set<CardBrand> selectedBrands;
  final Set<String> selectedCountries;
  final SortOption sortOption;
  final List<CreditCard> baseCards;
  final List<CreditCard> filteredCards;
  
  CardsFilterState copyWith({
    String? query,
    Set<CardBrand>? selectedBrands,
    Set<String>? selectedCountries,
    SortOption? sortOption,
    List<CreditCard>? baseCards,
    List<CreditCard>? filteredCards,
  }) {
    return CardsFilterState(
      query: query ?? this.query,
      selectedBrands: selectedBrands ?? this.selectedBrands,
      selectedCountries: selectedCountries ?? this.selectedCountries,
      sortOption: sortOption ?? this.sortOption,
      baseCards: baseCards ?? this.baseCards,
      filteredCards: filteredCards ?? this.filteredCards,
    );
  }
  
  @override
  List<Object?> get props => [
    query,
    selectedBrands,
    selectedCountries,
    sortOption,
    baseCards,
    filteredCards,
  ];
}