/// Represents supported credit card brands
enum CardBrand {
  visa('Visa'),
  mastercard('Mastercard'),
  americanExpress('American Express'),
  discover('Discover'),
  dinersClub('Diners Club'),
  jcb('JCB'),
  unknown('Unknown');

  const CardBrand(this.displayName);
  
  final String displayName;
  
  /// Returns the brand name formatted for display
  String get name => displayName;
  
  /// Returns true if this is a known/supported brand
  bool get isKnown => this != CardBrand.unknown;
}