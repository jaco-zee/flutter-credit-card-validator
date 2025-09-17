
class CountryCode {
  const CountryCode(this.code, this.name);
  
  final String code;
  final String name;
  
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CountryCode && runtimeType == other.runtimeType && code == other.code;

  @override
  int get hashCode => code.hashCode;

  @override
  String toString() => '$name ($code)';

  static const List<CountryCode> common = [
    CountryCode('US', 'United States'),
    CountryCode('CA', 'Canada'),
    CountryCode('GB', 'United Kingdom'),
    CountryCode('AU', 'Australia'),
    CountryCode('DE', 'Germany'),
    CountryCode('FR', 'France'),
    CountryCode('IT', 'Italy'),
    CountryCode('ES', 'Spain'),
    CountryCode('NL', 'Netherlands'),
    CountryCode('BE', 'Belgium'),
    CountryCode('CH', 'Switzerland'),
    CountryCode('AT', 'Austria'),
    CountryCode('SE', 'Sweden'),
    CountryCode('NO', 'Norway'),
    CountryCode('DK', 'Denmark'),
    CountryCode('FI', 'Finland'),
    CountryCode('JP', 'Japan'),
    CountryCode('KR', 'South Korea'),
    CountryCode('SG', 'Singapore'),
    CountryCode('HK', 'Hong Kong'),
    CountryCode('BR', 'Brazil'),
    CountryCode('MX', 'Mexico'),
    CountryCode('IN', 'India'),
    CountryCode('CN', 'China'),
    CountryCode('ZA', 'South Africa'),
    CountryCode('NZ', 'New Zealand'),
    CountryCode('IE', 'Ireland'),
    CountryCode('PT', 'Portugal'),
    CountryCode('GR', 'Greece'),
    CountryCode('PL', 'Poland'),
  ];

  static CountryCode? findByCode(String code) {
    try {
      return common.firstWhere((country) => country.code == code.toUpperCase());
    } catch (e) {
      return null;
    }
  }
}