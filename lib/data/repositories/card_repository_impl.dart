import '../../domain/entities/credit_card.dart';
import '../../domain/repositories/card_repository.dart';
import '../datasources/local/card_local_ds.dart';
import '../models/credit_card_model.dart';

/// Implementation of CardRepository using local storage
class CardRepositoryImpl implements CardRepository {
  
  CardRepositoryImpl(this._dataSource);
  final CardLocalDataSource _dataSource;
  
  @override
  Future<List<CreditCard>> getAll() async {
    final models = await _dataSource.getAllCards();
    return models.map((model) => model.toEntity()).toList();
  }
  
  @override
  Future<bool> exists(String normalizedNumber) async {
    return _dataSource.cardExists(normalizedNumber);
  }
  
  @override
  Future<void> save(CreditCard card) async {
    final model = CreditCardModel.fromEntity(card);
    await _dataSource.saveCard(model);
  }
  
  @override
  Future<bool> remove(String normalizedNumber) async {
    return _dataSource.removeCard(normalizedNumber);
  }
  
  @override
  Future<void> clear() async {
    await _dataSource.clearAllCards();
  }
}