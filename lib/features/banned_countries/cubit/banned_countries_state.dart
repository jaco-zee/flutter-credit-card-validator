import 'package:equatable/equatable.dart';

enum BannedCountriesStatus { initial, loading, success, error }

/// State for banned countries management
class BannedCountriesState extends Equatable {
  const BannedCountriesState({
    this.status = BannedCountriesStatus.initial,
    this.bannedCodes = const <String>{},
    this.errorMessage = '',
  });
  
  final BannedCountriesStatus status;
  final Set<String> bannedCodes;
  final String errorMessage;
  
  BannedCountriesState copyWith({
    BannedCountriesStatus? status,
    Set<String>? bannedCodes,
    String? errorMessage,
  }) {
    return BannedCountriesState(
      status: status ?? this.status,
      bannedCodes: bannedCodes ?? this.bannedCodes,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
  
  @override
  List<Object?> get props => [status, bannedCodes, errorMessage];
}