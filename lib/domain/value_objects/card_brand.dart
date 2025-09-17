// card brands
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

  String get name => displayName;

  bool get isKnown => this != CardBrand.unknown;
}