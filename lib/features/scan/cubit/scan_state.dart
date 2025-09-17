import 'package:equatable/equatable.dart';

enum ScanStatus { idle, starting, scanning, success, error }

/// State for card scanning feature
class ScanState extends Equatable {
  const ScanState({
    this.status = ScanStatus.idle,
    this.scannedNumber = '',
    this.scannedCardHolderName = '',
    this.scannedExpiryDate = '',
    this.errorMessage = '',
  });
  
  final ScanStatus status;
  final String scannedNumber;
  final String scannedCardHolderName;
  final String scannedExpiryDate;
  final String errorMessage;
  
  ScanState copyWith({
    ScanStatus? status,
    String? scannedNumber,
    String? scannedCardHolderName,
    String? scannedExpiryDate,
    String? errorMessage,
  }) {
    return ScanState(
      status: status ?? this.status,
      scannedNumber: scannedNumber ?? this.scannedNumber,
      scannedCardHolderName: scannedCardHolderName ?? this.scannedCardHolderName,
      scannedExpiryDate: scannedExpiryDate ?? this.scannedExpiryDate,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
  
  @override
  List<Object?> get props => [status, scannedNumber, scannedCardHolderName, scannedExpiryDate, errorMessage];
}