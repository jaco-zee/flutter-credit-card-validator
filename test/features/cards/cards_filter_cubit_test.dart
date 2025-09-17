import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:card_submitter/features/cards/filter/cards_filter_cubit.dart';
import 'package:card_submitter/features/cards/filter/cards_filter_state.dart';
import 'package:card_submitter/domain/entities/credit_card.dart';
import 'package:card_submitter/domain/value_objects/card_brand.dart';

void main() {
  group('CardsFilterCubit', () {
    late CardsFilterCubit cubit;
    
    final testCards = [
      CreditCard(
        number: '4111111111111111',
        brand: CardBrand.visa,
        issuingCountry: 'US',
        savedAt: DateTime(2023, 1, 1),
        cardHolderName: 'John Doe',
        expiryDate: '12/26',
      ),
      CreditCard(
        number: '5555555555554444',
        brand: CardBrand.mastercard,
        issuingCountry: 'CA',
        savedAt: DateTime(2023, 1, 2),
        cardHolderName: 'Jane Smith',
        expiryDate: '06/27',
      ),
      CreditCard(
        number: '378282246310005',
        brand: CardBrand.americanExpress,
        issuingCountry: 'US',
        savedAt: DateTime(2023, 1, 3),
        cardHolderName: 'Bob Johnson',
        expiryDate: '03/25',
      ),
    ];
    
    setUp(() {
      cubit = CardsFilterCubit();
    });
    
    tearDown(() {
      cubit.close();
    });
    
    test('initial state is correct', () {
      expect(cubit.state, equals(const CardsFilterState()));
    });
    
    group('updateBaseCards', () {
      blocTest<CardsFilterCubit, CardsFilterState>(
        'updates base cards and applies filters',
        build: () => cubit,
        act: (cubit) => cubit.updateBaseCards(testCards),
        expect: () => [
          CardsFilterState(
            baseCards: testCards,
            filteredCards: testCards,
          ),
        ],
      );
    });
    
    group('setQuery', () {
      blocTest<CardsFilterCubit, CardsFilterState>(
        'filters cards by brand name',
        build: () => cubit,
        seed: () => CardsFilterState(
          baseCards: testCards,
          filteredCards: testCards,
        ),
        act: (cubit) => cubit.setQuery('Visa'),
        expect: () => [
          CardsFilterState(
            query: 'Visa',
            baseCards: testCards,
            filteredCards: [testCards[0]], // Only Visa card
          ),
        ],
      );
      
      blocTest<CardsFilterCubit, CardsFilterState>(
        'filters cards by last 4 digits',
        build: () => cubit,
        seed: () => CardsFilterState(
          baseCards: testCards,
          filteredCards: testCards,
        ),
        act: (cubit) => cubit.setQuery('1111'),
        expect: () => [
          CardsFilterState(
            query: '1111',
            baseCards: testCards,
            filteredCards: [testCards[0]], // Only card ending in 1111
          ),
        ],
      );
      
      blocTest<CardsFilterCubit, CardsFilterState>(
        'filters cards by country',
        build: () => cubit,
        seed: () => CardsFilterState(
          baseCards: testCards,
          filteredCards: testCards,
        ),
        act: (cubit) => cubit.setQuery('US'),
        expect: () => [
          CardsFilterState(
            query: 'US',
            baseCards: testCards,
            filteredCards: [testCards[0], testCards[2]], // US cards
          ),
        ],
      );
    });
    
    group('toggleBrand', () {
      blocTest<CardsFilterCubit, CardsFilterState>(
        'adds brand to selected brands',
        build: () => cubit,
        seed: () => CardsFilterState(
          baseCards: testCards,
          filteredCards: testCards,
        ),
        act: (cubit) => cubit.toggleBrand(CardBrand.visa),
        expect: () => [
          CardsFilterState(
            selectedBrands: {CardBrand.visa},
            baseCards: testCards,
            filteredCards: [testCards[0]], // Only Visa card
          ),
        ],
      );
      
      blocTest<CardsFilterCubit, CardsFilterState>(
        'removes brand from selected brands',
        build: () => cubit,
        seed: () => CardsFilterState(
          selectedBrands: {CardBrand.visa},
          baseCards: testCards,
          filteredCards: [testCards[0]],
        ),
        act: (cubit) => cubit.toggleBrand(CardBrand.visa),
        expect: () => [
          CardsFilterState(
            selectedBrands: <CardBrand>{},
            baseCards: testCards,
            filteredCards: testCards, // All cards
          ),
        ],
      );
    });
    
    group('toggleCountry', () {
      blocTest<CardsFilterCubit, CardsFilterState>(
        'filters by selected country',
        build: () => cubit,
        seed: () => CardsFilterState(
          baseCards: testCards,
          filteredCards: testCards,
        ),
        act: (cubit) => cubit.toggleCountry('US'),
        expect: () => [
          CardsFilterState(
            selectedCountries: {'US'},
            baseCards: testCards,
            filteredCards: [testCards[0], testCards[2]], // US cards
          ),
        ],
      );
    });
    
    group('setSortOption', () {
      blocTest<CardsFilterCubit, CardsFilterState>(
        'sorts by oldest first',
        build: () => cubit,
        seed: () => CardsFilterState(
          baseCards: testCards,
          filteredCards: testCards,
        ),
        act: (cubit) => cubit.setSortOption(SortOption.oldestFirst),
        expect: () => [
          CardsFilterState(
            sortOption: SortOption.oldestFirst,
            baseCards: testCards,
            filteredCards: testCards, // Already in chronological order
          ),
        ],
      );
      
      blocTest<CardsFilterCubit, CardsFilterState>(
        'sorts by brand A-Z',
        build: () => cubit,
        seed: () => CardsFilterState(
          baseCards: testCards,
          filteredCards: testCards,
        ),
        act: (cubit) => cubit.setSortOption(SortOption.brandAToZ),
        expect: () => [
          CardsFilterState(
            sortOption: SortOption.brandAToZ,
            baseCards: testCards,
            filteredCards: [testCards[2], testCards[1], testCards[0]], // Amex, Master, Visa
          ),
        ],
      );
    });
    
    group('clearAll', () {
      blocTest<CardsFilterCubit, CardsFilterState>(
        'clears all filters',
        build: () => cubit,
        seed: () => const CardsFilterState(
          query: 'test',
          selectedBrands: {CardBrand.visa},
          selectedCountries: {'US'},
          sortOption: SortOption.brandAToZ,
        ),
        act: (cubit) => cubit.clearAll(),
        expect: () => [
          const CardsFilterState(
            query: '',
            selectedBrands: <CardBrand>{},
            selectedCountries: <String>{},
            sortOption: SortOption.newestFirst,
          ),
        ],
      );
    });
  });
}