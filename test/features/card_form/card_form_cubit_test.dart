import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:card_submitter/features/card_form/cubit/card_form_cubit.dart';
import 'package:card_submitter/features/card_form/cubit/card_form_state.dart';
import 'package:card_submitter/features/cards/cubit/cards_cubit.dart';
import 'package:card_submitter/features/cards/cubit/cards_state.dart';
import 'package:card_submitter/data/datasources/local/card_local_ds.dart';
import 'package:card_submitter/domain/value_objects/card_brand.dart';

class MockCardLocalDataSource extends Mock implements CardLocalDataSource {}
class MockCardsCubit extends Mock implements CardsCubit {}

void main() {
  group('CardFormCubit', () {
    late MockCardLocalDataSource mockDataSource;
    late MockCardsCubit mockCardsCubit;
    late CardFormCubit cardFormCubit;
    
    setUp(() {
      mockDataSource = MockCardLocalDataSource();
      mockCardsCubit = MockCardsCubit();
      cardFormCubit = CardFormCubit(mockDataSource, mockCardsCubit);
      
      // Setup default mock behavior
      when(() => mockDataSource.getBannedCountries()).thenAnswer((_) async => <String>{});
      when(() => mockCardsCubit.state).thenReturn(const CardsState(lastOperationStatus: CardsStatus.success));
    });
    
    tearDown(() {
      cardFormCubit.close();
    });
    
    test('initial state is correct', () {
      expect(cardFormCubit.state, equals(const CardFormState()));
    });
    
    group('onNumberChanged', () {
      blocTest<CardFormCubit, CardFormState>(
        'updates number, brand and masked number',
        build: () => cardFormCubit,
        act: (cubit) => cubit.onNumberChanged('4111 1111 1111 1111'),
        expect: () => [
          const CardFormState(
            rawNumber: '4111111111111111',
            maskedNumber: '4111 1111 1111 1111',
            brand: CardBrand.visa,
            isValid: false,
          ),
        ],
      );
      
      blocTest<CardFormCubit, CardFormState>(
        'detects Mastercard brand correctly',
        build: () => cardFormCubit,
        act: (cubit) => cubit.onNumberChanged('5555555555554444'),
        expect: () => [
          const CardFormState(
            rawNumber: '5555555555554444',
            maskedNumber: '5555 5555 5555 4444',
            brand: CardBrand.mastercard,
            isValid: false,
          ),
        ],
      );
    });
    
    group('onCvvChanged', () {
      blocTest<CardFormCubit, CardFormState>(
        'updates CVV and limits to 4 digits',
        build: () => cardFormCubit,
        act: (cubit) => cubit.onCvvChanged('12345'),
        expect: () => [
          const CardFormState(cvv: '1234', isValid: false),
        ],
      );
      
      blocTest<CardFormCubit, CardFormState>(
        'removes non-digit characters',
        build: () => cardFormCubit,
        act: (cubit) => cubit.onCvvChanged('1a2b3'),
        expect: () => [
          const CardFormState(cvv: '123', isValid: false),
        ],
      );
    });
    
    group('onCountryChanged', () {
      blocTest<CardFormCubit, CardFormState>(
        'updates country code',
        build: () => cardFormCubit,
        act: (cubit) => cubit.onCountryChanged('US'),
        expect: () => [
          const CardFormState(countryCode: 'US', isValid: false),
        ],
      );
    });
    
    group('form validation', () {
      blocTest<CardFormCubit, CardFormState>(
        'becomes valid when all fields are correct',
        build: () => cardFormCubit,
        act: (cubit) {
          cubit.onNumberChanged('4111111111111111');
          cubit.onCvvChanged('123');
          cubit.onCardHolderNameChanged('John Doe');
          cubit.onExpiryDateChanged('12/28');
          cubit.onCountryChanged('US');
        },
        expect: () => [
          const CardFormState(
            rawNumber: '4111111111111111',
            maskedNumber: '4111 1111 1111 1111',
            brand: CardBrand.visa,
            isValid: false,
          ),
          const CardFormState(
            rawNumber: '4111111111111111',
            maskedNumber: '4111 1111 1111 1111',
            brand: CardBrand.visa,
            cvv: '123',
            isValid: false,
          ),
          const CardFormState(
            rawNumber: '4111111111111111',
            maskedNumber: '4111 1111 1111 1111',
            brand: CardBrand.visa,
            cvv: '123',
            cardHolderName: 'John Doe',
            isValid: false,
          ),
          const CardFormState(
            rawNumber: '4111111111111111',
            maskedNumber: '4111 1111 1111 1111',
            brand: CardBrand.visa,
            cvv: '123',
            cardHolderName: 'John Doe',
            expiryDate: '12/28',
            isValid: false,
          ),
          const CardFormState(
            rawNumber: '4111111111111111',
            maskedNumber: '4111 1111 1111 1111',
            brand: CardBrand.visa,
            cvv: '123',
            cardHolderName: 'John Doe',
            expiryDate: '12/28',
            countryCode: 'US',
            isValid: false,
          ),
          const CardFormState(
            rawNumber: '4111111111111111',
            maskedNumber: '4111 1111 1111 1111',
            brand: CardBrand.visa,
            cvv: '123',
            cardHolderName: 'John Doe',
            expiryDate: '12/28',
            countryCode: 'US',
            isValid: true,
          ),
        ],
      );
    });
    
    group('onSubmit', () {
      blocTest<CardFormCubit, CardFormState>(
        'does nothing when form is invalid',
        build: () => cardFormCubit,
        act: (cubit) => cubit.onSubmit(),
        expect: () => [],
      );
      
      blocTest<CardFormCubit, CardFormState>(
        'shows error when country is banned',
        build: () => cardFormCubit,
        setUp: () {
          when(() => mockDataSource.getBannedCountries()).thenAnswer((_) async => {'US'});
        },
        seed: () => const CardFormState(
          rawNumber: '4111111111111111',
          brand: CardBrand.visa,
          cvv: '123',
          countryCode: 'US',
          isValid: true,
        ),
        act: (cubit) => cubit.onSubmit(),
        expect: () => [
          const CardFormState(
            rawNumber: '4111111111111111',
            brand: CardBrand.visa,
            cvv: '123',
            countryCode: 'US',
            isValid: true,
            submitStatus: SubmitStatus.submitting,
          ),
          const CardFormState(
            rawNumber: '4111111111111111',
            brand: CardBrand.visa,
            cvv: '123',
            countryCode: 'US',
            isValid: true,
            submitStatus: SubmitStatus.error,
            errorMessage: 'Cards from US are not accepted',
          ),
        ],
      );
    });
    
    group('resetForm', () {
      blocTest<CardFormCubit, CardFormState>(
        'resets to initial state',
        build: () => cardFormCubit,
        seed: () => const CardFormState(
          rawNumber: '4111111111111111',
          brand: CardBrand.visa,
          cvv: '123',
          countryCode: 'US',
          isValid: true,
        ),
        act: (cubit) => cubit.resetForm(),
        expect: () => [const CardFormState()],
      );
    });
  });
}