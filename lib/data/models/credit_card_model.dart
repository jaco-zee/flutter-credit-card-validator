import 'package:hive/hive.dart';
import '../../domain/entities/credit_card.dart';
import '../../domain/value_objects/card_brand.dart';

part 'credit_card_model.g.dart';

/// Hive model for credit card persistence
@HiveType(typeId: 0)
class CreditCardModel extends HiveObject {
  CreditCardModel({
    required this.number,
    required this.brand,
    this.cardHolderName = '',
    this.expiryDate = '',
    required this.issuingCountry,
    required this.savedAt,
  });
  
  /// Converts from domain entity to model
  factory CreditCardModel.fromEntity(CreditCard entity) {
    return CreditCardModel(
      number: entity.number,
      brand: entity.brand.name,
      cardHolderName: entity.cardHolderName,
      expiryDate: entity.expiryDate,
      issuingCountry: entity.issuingCountry,
      savedAt: entity.savedAt,
    );
  }

  @HiveField(0)
  String number;
  
  @HiveField(1)
  String brand;
  
  @HiveField(2)
  String issuingCountry;
  
  @HiveField(3)
  DateTime savedAt;
  
  @HiveField(4)
  String cardHolderName;
  
  @HiveField(5)
  String expiryDate;
  
  /// Converts from model to domain entity
  CreditCard toEntity() {
    return CreditCard(
      number: number,
      brand: _parseBrand(brand),
      cardHolderName: cardHolderName,
      expiryDate: expiryDate,
      issuingCountry: issuingCountry,
      savedAt: savedAt,
    );
  }
  
  /// Parses brand string back to CardBrand enum
  CardBrand _parseBrand(String brandName) {
    return CardBrand.values.firstWhere(
      (brand) => brand.displayName == brandName,
      orElse: () => CardBrand.unknown,
    );
  }
}