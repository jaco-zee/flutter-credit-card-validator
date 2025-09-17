import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/datasources/local/card_local_ds.dart';
import 'banned_countries_state.dart';

/// Cubit for managing banned countries
class BannedCountriesCubit extends Cubit<BannedCountriesState> {
  BannedCountriesCubit(this._dataSource) : super(const BannedCountriesState());
  
  final CardLocalDataSource _dataSource;
  
  /// Loads banned countries from storage
  Future<void> load() async {
    emit(state.copyWith(status: BannedCountriesStatus.loading));
    
    try {
      final codes = await _dataSource.getBannedCountries();
      emit(state.copyWith(
        status: BannedCountriesStatus.success,
        bannedCodes: codes,
      ));
    } catch (error) {
      emit(state.copyWith(
        status: BannedCountriesStatus.error,
        errorMessage: 'Failed to load banned countries: $error',
      ));
    }
  }
  
  /// Adds a country to the banned list
  Future<void> addCountry(String countryCode) async {
    try {
      await _dataSource.addBannedCountry(countryCode);
      
      // Update local state
      final updated = Set<String>.from(state.bannedCodes);
      updated.add(countryCode);
      
      emit(state.copyWith(
        status: BannedCountriesStatus.success,
        bannedCodes: updated,
      ));
    } catch (error) {
      emit(state.copyWith(
        status: BannedCountriesStatus.error,
        errorMessage: 'Failed to add banned country: $error',
      ));
    }
  }
  
  /// Removes a country from the banned list
  Future<void> removeCountry(String countryCode) async {
    try {
      await _dataSource.removeBannedCountry(countryCode);
      
      // Update local state
      final updated = Set<String>.from(state.bannedCodes);
      updated.remove(countryCode);
      
      emit(state.copyWith(
        status: BannedCountriesStatus.success,
        bannedCodes: updated,
      ));
    } catch (error) {
      emit(state.copyWith(
        status: BannedCountriesStatus.error,
        errorMessage: 'Failed to remove banned country: $error',
      ));
    }
  }
  
  /// Checks if a country is banned
  bool isCountryBanned(String countryCode) {
    return state.bannedCodes.contains(countryCode);
  }
  
  /// Clears error messages
  void clearError() {
    emit(state.copyWith(
      status: BannedCountriesStatus.initial,
      errorMessage: '',
    ));
  }
}