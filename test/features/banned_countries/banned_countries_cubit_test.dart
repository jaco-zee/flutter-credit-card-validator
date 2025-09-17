import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:card_submitter/features/banned_countries/cubit/banned_countries_cubit.dart';
import 'package:card_submitter/features/banned_countries/cubit/banned_countries_state.dart';
import 'package:card_submitter/data/datasources/local/card_local_ds.dart';

class MockCardLocalDataSource extends Mock implements CardLocalDataSource {}

void main() {
  group('BannedCountriesCubit', () {
    late MockCardLocalDataSource mockDataSource;
    late BannedCountriesCubit cubit;
    
    setUp(() {
      mockDataSource = MockCardLocalDataSource();
      cubit = BannedCountriesCubit(mockDataSource);
    });
    
    tearDown(() {
      cubit.close();
    });
    
    test('initial state is correct', () {
      expect(cubit.state, equals(const BannedCountriesState()));
    });
    
    group('load', () {
      blocTest<BannedCountriesCubit, BannedCountriesState>(
        'loads banned countries successfully',
        build: () => cubit,
        setUp: () {
          when(() => mockDataSource.getBannedCountries())
              .thenAnswer((_) async => {'US', 'CA'});
        },
        act: (cubit) => cubit.load(),
        expect: () => [
          const BannedCountriesState(status: BannedCountriesStatus.loading),
          const BannedCountriesState(
            status: BannedCountriesStatus.success,
            bannedCodes: {'US', 'CA'},
          ),
        ],
      );
      
      blocTest<BannedCountriesCubit, BannedCountriesState>(
        'handles load error',
        build: () => cubit,
        setUp: () {
          when(() => mockDataSource.getBannedCountries())
              .thenThrow(Exception('Storage error'));
        },
        act: (cubit) => cubit.load(),
        expect: () => [
          const BannedCountriesState(status: BannedCountriesStatus.loading),
          const BannedCountriesState(
            status: BannedCountriesStatus.error,
            errorMessage: 'Failed to load banned countries: Exception: Storage error',
          ),
        ],
      );
    });
    
    group('addCountry', () {
      blocTest<BannedCountriesCubit, BannedCountriesState>(
        'adds country to banned list',
        build: () => cubit,
        seed: () => const BannedCountriesState(
          status: BannedCountriesStatus.success,
          bannedCodes: {'US'},
        ),
        setUp: () {
          when(() => mockDataSource.addBannedCountry(any()))
              .thenAnswer((_) async => {});
        },
        act: (cubit) => cubit.addCountry('CA'),
        expect: () => [
          const BannedCountriesState(
            status: BannedCountriesStatus.success,
            bannedCodes: {'US', 'CA'},
          ),
        ],
        verify: (cubit) {
          verify(() => mockDataSource.addBannedCountry('CA')).called(1);
        },
      );
      
      blocTest<BannedCountriesCubit, BannedCountriesState>(
        'handles add error',
        build: () => cubit,
        seed: () => const BannedCountriesState(
          status: BannedCountriesStatus.success,
          bannedCodes: {'US'},
        ),
        setUp: () {
          when(() => mockDataSource.addBannedCountry(any()))
              .thenThrow(Exception('Storage error'));
        },
        act: (cubit) => cubit.addCountry('CA'),
        expect: () => [
          const BannedCountriesState(
            status: BannedCountriesStatus.error,
            bannedCodes: {'US'},
            errorMessage: 'Failed to add banned country: Exception: Storage error',
          ),
        ],
      );
    });
    
    group('removeCountry', () {
      blocTest<BannedCountriesCubit, BannedCountriesState>(
        'removes country from banned list',
        build: () => cubit,
        seed: () => const BannedCountriesState(
          status: BannedCountriesStatus.success,
          bannedCodes: {'US', 'CA'},
        ),
        setUp: () {
          when(() => mockDataSource.removeBannedCountry(any()))
              .thenAnswer((_) async => {});
        },
        act: (cubit) => cubit.removeCountry('CA'),
        expect: () => [
          const BannedCountriesState(
            status: BannedCountriesStatus.success,
            bannedCodes: {'US'},
          ),
        ],
        verify: (cubit) {
          verify(() => mockDataSource.removeBannedCountry('CA')).called(1);
        },
      );
    });
    
    group('isCountryBanned', () {
      test('returns true for banned country', () {
        cubit.emit(const BannedCountriesState(bannedCodes: {'US', 'CA'}));
        expect(cubit.isCountryBanned('US'), isTrue);
        expect(cubit.isCountryBanned('CA'), isTrue);
      });
      
      test('returns false for non-banned country', () {
        cubit.emit(const BannedCountriesState(bannedCodes: {'US', 'CA'}));
        expect(cubit.isCountryBanned('GB'), isFalse);
        expect(cubit.isCountryBanned('DE'), isFalse);
      });
    });
    
    group('clearError', () {
      blocTest<BannedCountriesCubit, BannedCountriesState>(
        'clears error state',
        build: () => cubit,
        seed: () => const BannedCountriesState(
          status: BannedCountriesStatus.error,
          errorMessage: 'Some error',
        ),
        act: (cubit) => cubit.clearError(),
        expect: () => [
          const BannedCountriesState(
            status: BannedCountriesStatus.initial,
            errorMessage: '',
          ),
        ],
      );
    });
  });
}