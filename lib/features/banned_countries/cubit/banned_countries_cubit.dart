import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/datasources/local/card_local_ds.dart';
import 'banned_countries_state.dart';


class BannedCountriesCubit extends Cubit<BannedCountriesState> {
  BannedCountriesCubit(this._dataSource) : super(const BannedCountriesState());
  
  final CardLocalDataSource _dataSource;
  
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

  Future<void> addCountry(String countryCode) async {
    try {
      await _dataSource.addBannedCountry(countryCode);

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

  Future<void> removeCountry(String countryCode) async {
    try {
      await _dataSource.removeBannedCountry(countryCode);

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
  
  bool isCountryBanned(String countryCode) {
    return state.bannedCodes.contains(countryCode);
  }
  
  void clearError() {
    emit(state.copyWith(
      status: BannedCountriesStatus.initial,
      errorMessage: '',
    ));
  }
}