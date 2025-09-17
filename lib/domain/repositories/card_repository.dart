import '../entities/credit_card.dart';

abstract class CardRepository {

  Future<List<CreditCard>> getAll();

  Future<bool> exists(String normalizedNumber);

  Future<void> save(CreditCard card);

  Future<bool> remove(String normalizedNumber);

  Future<void> clear();
}