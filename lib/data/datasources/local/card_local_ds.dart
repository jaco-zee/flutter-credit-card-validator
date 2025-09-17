import 'package:hive_flutter/hive_flutter.dart';
import '../../models/credit_card_model.dart';

/// Local data source for credit cards using Hive
class CardLocalDataSource {
  static const String _boxName = 'cards';
  static const String _settingsBoxName = 'settings';
  static const String _bannedCountriesKey = 'banned_countries';
  
  late final Box<CreditCardModel> _cardBox;
  late final Box<dynamic> _settingsBox;
  
  /// Initializes Hive boxes
  Future<void> init() async {
    await Hive.initFlutter();
    
    // Register adapters
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(CreditCardModelAdapter());
    }
    
    // Open boxes with migration support
    try {
      _cardBox = await Hive.openBox<CreditCardModel>(_boxName);
      _settingsBox = await Hive.openBox<dynamic>(_settingsBoxName);
      
      // Test read to check for compatibility issues
      _cardBox.values.toList();
    } catch (e) {
      // If there's a compatibility issue, clear the boxes and reopen
      // ignore: avoid_print
      print('Schema migration needed, clearing boxes...');
      
      try {
        // Close boxes first if they were opened
        if (_cardBox.isOpen) await _cardBox.close();
        if (_settingsBox.isOpen) await _settingsBox.close();
      } catch (e) {
        // ignore: avoid_print
        print('Warning: Failed to close boxes during migration: $e');
        // Continue migration even if close fails
      }
      
      try {
        await Hive.deleteBoxFromDisk(_boxName);
      } catch (e) {
        // ignore: avoid_print
        print('Warning: Failed to delete cards box: $e');
        // Continue migration even if deletion fails
      }
      
      try {
        await Hive.deleteBoxFromDisk(_settingsBoxName);
      } catch (e) {
        // ignore: avoid_print
        print('Warning: Failed to delete settings box: $e');
        // Continue migration even if deletion fails
      }
      
      _cardBox = await Hive.openBox<CreditCardModel>(_boxName);
      _settingsBox = await Hive.openBox<dynamic>(_settingsBoxName);
      
      // ignore: avoid_print
      print('Schema migration completed successfully');
    }
  }
  
  /// Gets all saved credit cards
  Future<List<CreditCardModel>> getAllCards() async {
    return _cardBox.values.toList();
  }
  
  /// Checks if a card with the given number exists
  Future<bool> cardExists(String normalizedNumber) async {
    return _cardBox.values.any((card) => card.number == normalizedNumber);
  }
  
  /// Saves a credit card
  Future<void> saveCard(CreditCardModel card) async {
    await _cardBox.add(card);
  }
  
  /// Removes a card by normalized number
  Future<bool> removeCard(String normalizedNumber) async {
    final index = _cardBox.values.toList().indexWhere((card) => card.number == normalizedNumber);
    if (index != -1) {
      await _cardBox.deleteAt(index);
      return true;
    }
    return false;
  }
  
  /// Clears all cards
  Future<void> clearAllCards() async {
    await _cardBox.clear();
  }
  
  /// Gets banned country codes
  Future<Set<String>> getBannedCountries() async {
    final List<dynamic>? codes = _settingsBox.get(_bannedCountriesKey);
    return codes?.cast<String>().toSet() ?? <String>{};
  }
  
  /// Saves banned country codes
  Future<void> saveBannedCountries(Set<String> countryCodes) async {
    await _settingsBox.put(_bannedCountriesKey, countryCodes.toList());
  }
  
  /// Adds a banned country code
  Future<void> addBannedCountry(String countryCode) async {
    final banned = await getBannedCountries();
    banned.add(countryCode);
    await saveBannedCountries(banned);
  }
  
  /// Removes a banned country code
  Future<void> removeBannedCountry(String countryCode) async {
    final banned = await getBannedCountries();
    banned.remove(countryCode);
    await saveBannedCountries(banned);
  }
}