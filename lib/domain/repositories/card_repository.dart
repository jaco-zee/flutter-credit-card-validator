import '../entities/credit_card.dart';

/// Repository interface for credit card persistence and retrieval
abstract class CardRepository {
  /// Retrieves all saved credit cards
  Future<List<CreditCard>> getAll();
  
  /// Checks if a card with the given number already exists
  Future<bool> exists(String normalizedNumber);
  
  /// Saves a credit card (without CVV)
  Future<void> save(CreditCard card);
  
  /// Removes a credit card by its normalized number
  Future<bool> remove(String normalizedNumber);
  
  /// Clears all saved cards (useful for testing)
  Future<void> clear();
}