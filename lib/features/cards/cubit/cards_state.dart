import 'package:equatable/equatable.dart';
import '../../../domain/entities/credit_card.dart';

enum CardsStatus { initial, loading, success, error }

class CardsState extends Equatable {
  const CardsState({
    this.status = CardsStatus.initial,
    this.cards = const [],
    this.lastOperationStatus = CardsStatus.initial,
    this.errorMessage = '',
  });
  
  final CardsStatus status;
  final List<CreditCard> cards;
  final CardsStatus lastOperationStatus;
  final String errorMessage;
  
  CardsState copyWith({
    CardsStatus? status,
    List<CreditCard>? cards,
    CardsStatus? lastOperationStatus,
    String? errorMessage,
  }) {
    return CardsState(
      status: status ?? this.status,
      cards: cards ?? this.cards,
      lastOperationStatus: lastOperationStatus ?? this.lastOperationStatus,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
  
  @override
  List<Object?> get props => [status, cards, lastOperationStatus, errorMessage];
}