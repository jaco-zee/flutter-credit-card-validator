import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/entities/credit_card.dart';
import '../../../domain/repositories/card_repository.dart';
import 'cards_state.dart';

class CardsCubit extends Cubit<CardsState> {
  CardsCubit(this._repository) : super(const CardsState());
  
  final CardRepository _repository;

  Future<void> load() async {
    emit(state.copyWith(status: CardsStatus.loading));
    
    try {
      final cards = await _repository.getAll();
      // Sort by saved date (newest first)
      cards.sort((a, b) => b.savedAt.compareTo(a.savedAt));
      
      emit(state.copyWith(
        status: CardsStatus.success,
        cards: cards,
        lastOperationStatus: CardsStatus.success,
      ));
    } catch (error) {
      emit(state.copyWith(
        status: CardsStatus.error,
        lastOperationStatus: CardsStatus.error,
        errorMessage: 'Failed to load cards: $error',
      ));
    }
  }
  
  // (with deduplication) without UI feedback
  Future<bool> addCardQuietly(CreditCard card) async {
    try {
      final exists = await _repository.exists(card.number);
      if (exists) {
        return false;
      }
      await _repository.save(card);

      await load();
      
      return true;
    } catch (error) {
      return false;
    }
  }

  Future<void> addCard(CreditCard card) async {
    emit(state.copyWith(lastOperationStatus: CardsStatus.loading));
    try {
      // Check for duplicates
      final exists = await _repository.exists(card.number);
      if (exists) {
        emit(state.copyWith(
          lastOperationStatus: CardsStatus.error,
          errorMessage: 'Card already exists',
        ));
        return;
      }
      
      // Save the card
      await _repository.save(card);

      await load();
      
      emit(state.copyWith(
        lastOperationStatus: CardsStatus.success,
        errorMessage: '',
      ));
    } catch (error) {
      emit(state.copyWith(
        lastOperationStatus: CardsStatus.error,
        errorMessage: 'Failed to add card: $error',
      ));
    }
  }
  
  // Removes a credit card by normalized number
  Future<void> deleteCard(String normalizedNumber) async {
    try {
      final removed = await _repository.remove(normalizedNumber);
      if (removed) {
        // Reload the list to reflect changes
        await load();
        
        emit(state.copyWith(
          lastOperationStatus: CardsStatus.success,
          errorMessage: 'Card removed successfully',
        ));
      } else {
        emit(state.copyWith(
          lastOperationStatus: CardsStatus.error,
          errorMessage: 'Card not found',
        ));
      }
    } catch (error) {
      emit(state.copyWith(
        lastOperationStatus: CardsStatus.error,
        errorMessage: 'Failed to remove card: $error',
      ));
    }
  }

  void clearMessage() {
    emit(state.copyWith(
      lastOperationStatus: CardsStatus.initial,
      errorMessage: '',
    ));
  }
}