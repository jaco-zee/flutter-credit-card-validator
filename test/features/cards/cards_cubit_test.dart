import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:card_submitter/features/cards/cubit/cards_cubit.dart';
import 'package:card_submitter/features/cards/cubit/cards_state.dart';
import 'package:card_submitter/domain/entities/credit_card.dart';
import 'package:card_submitter/domain/repositories/card_repository.dart';
import 'package:card_submitter/domain/value_objects/card_brand.dart';

class MockCardRepository extends Mock implements CardRepository {}

void main() {
  group('CardsCubit', () {
    late MockCardRepository mockRepository;
    late CardsCubit cardsCubit;
    
    final testCard = CreditCard(
      number: '4242424242424242',
      brand: CardBrand.visa,
      cardHolderName: 'John Doe',
      expiryDate: '12/28',
      issuingCountry: 'US',
      savedAt: DateTime.now(),
    );
    
    setUpAll(() {
      registerFallbackValue(testCard);
    });
    
    setUp(() {
      mockRepository = MockCardRepository();
      cardsCubit = CardsCubit(mockRepository);
    });
    
    tearDown(() {
      cardsCubit.close();
    });
    
    test('initial state is correct', () {
      expect(cardsCubit.state, equals(const CardsState()));
    });
    
    group('load', () {
      blocTest<CardsCubit, CardsState>(
        'emits success when cards are loaded',
        build: () => cardsCubit,
        setUp: () {
          when(() => mockRepository.getAll()).thenAnswer((_) async => [testCard]);
        },
        act: (cubit) => cubit.load(),
        expect: () => [
          const CardsState(status: CardsStatus.loading),
          CardsState(
            status: CardsStatus.success,
            cards: [testCard],
            lastOperationStatus: CardsStatus.success,
          ),
        ],
      );
      
      blocTest<CardsCubit, CardsState>(
        'emits error when loading fails',
        build: () => cardsCubit,
        setUp: () {
          when(() => mockRepository.getAll()).thenThrow(Exception('Network error'));
        },
        act: (cubit) => cubit.load(),
        expect: () => [
          const CardsState(status: CardsStatus.loading),
          const CardsState(
            status: CardsStatus.error,
            lastOperationStatus: CardsStatus.error,
            errorMessage: 'Failed to load cards: Exception: Network error',
          ),
        ],
      );
    });
    
    group('addCard', () {
      blocTest<CardsCubit, CardsState>(
        'adds card when it does not exist',
        build: () => cardsCubit,
        setUp: () {
          when(() => mockRepository.exists(any())).thenAnswer((_) async => false);
          when(() => mockRepository.save(any())).thenAnswer((_) async => {});
          when(() => mockRepository.getAll()).thenAnswer((_) async => [testCard]);
        },
        act: (cubit) => cubit.addCard(testCard),
        verify: (cubit) {
          verify(() => mockRepository.exists(testCard.number)).called(1);
          verify(() => mockRepository.save(testCard)).called(1);
        },
      );
      
      blocTest<CardsCubit, CardsState>(
        'shows error when card already exists',
        build: () => cardsCubit,
        setUp: () {
          when(() => mockRepository.exists(any())).thenAnswer((_) async => true);
        },
        act: (cubit) => cubit.addCard(testCard),
        expect: () => [
          const CardsState(
            lastOperationStatus: CardsStatus.loading,
          ),
          const CardsState(
            lastOperationStatus: CardsStatus.error,
            errorMessage: 'Card already exists',
          ),
        ],
        verify: (cubit) {
          verify(() => mockRepository.exists(testCard.number)).called(1);
          verifyNever(() => mockRepository.save(any()));
        },
      );
    });
    
    group('deleteCard', () {
      blocTest<CardsCubit, CardsState>(
        'removes card when it exists',
        build: () => cardsCubit,
        setUp: () {
          when(() => mockRepository.remove(any())).thenAnswer((_) async => true);
          when(() => mockRepository.getAll()).thenAnswer((_) async => []);
        },
        act: (cubit) => cubit.deleteCard('4111111111111111'),
        verify: (cubit) {
          verify(() => mockRepository.remove('4111111111111111')).called(1);
        },
      );
      
      blocTest<CardsCubit, CardsState>(
        'shows error when card not found',
        build: () => cardsCubit,
        setUp: () {
          when(() => mockRepository.remove(any())).thenAnswer((_) async => false);
        },
        act: (cubit) => cubit.deleteCard('4111111111111111'),
        expect: () => [
          const CardsState(
            lastOperationStatus: CardsStatus.error,
            errorMessage: 'Card not found',
          ),
        ],
      );
    });
    
    group('clearMessage', () {
      blocTest<CardsCubit, CardsState>(
        'clears error and success messages',
        build: () => cardsCubit,
        seed: () => const CardsState(
          lastOperationStatus: CardsStatus.error,
          errorMessage: 'Some error',
        ),
        act: (cubit) => cubit.clearMessage(),
        expect: () => [
          const CardsState(
            lastOperationStatus: CardsStatus.initial,
            errorMessage: '',
          ),
        ],
      );
    });
  });
}