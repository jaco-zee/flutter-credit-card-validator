import 'package:flutter_test/flutter_test.dart';

import 'package:card_submitter/core/utils/luhn.dart';

void main() {
  group('LuhnValidator', () {
    group('isValid', () {
      test('returns true for valid credit card numbers', () {
        // Visa test number
        expect(LuhnValidator.isValid('4111111111111111'), isTrue);
        // Mastercard test number
        expect(LuhnValidator.isValid('5555555555554444'), isTrue);
        // American Express test number
        expect(LuhnValidator.isValid('378282246310005'), isTrue);
        // Discover test number
        expect(LuhnValidator.isValid('6011111111111117'), isTrue);
      });
      
      test('returns false for invalid credit card numbers', () {
        expect(LuhnValidator.isValid('1234567890123456'), isFalse);
        expect(LuhnValidator.isValid('4111111111111112'), isFalse);
        expect(LuhnValidator.isValid('1234567890123457'), isFalse);
      });
      
      test('returns false for empty or short numbers', () {
        expect(LuhnValidator.isValid(''), isFalse);
        expect(LuhnValidator.isValid('123'), isFalse);
        expect(LuhnValidator.isValid('123456789012'), isFalse);
      });
      
      test('returns false for too long numbers', () {
        expect(LuhnValidator.isValid('12345678901234567890'), isFalse);
      });
      
      test('handles numbers with spaces and dashes', () {
        expect(LuhnValidator.isValid('4111 1111 1111 1111'), isTrue);
        expect(LuhnValidator.isValid('4111-1111-1111-1111'), isTrue);
        expect(LuhnValidator.isValid('4111 1111-1111 1111'), isTrue);
      });
    });
    
    group('normalize', () {
      test('removes all non-digit characters', () {
        expect(LuhnValidator.normalize('4111 1111 1111 1111'), equals('4111111111111111'));
        expect(LuhnValidator.normalize('4111-1111-1111-1111'), equals('4111111111111111'));
        expect(LuhnValidator.normalize('4111a1111b1111c1111'), equals('4111111111111111'));
        expect(LuhnValidator.normalize('(411) 111-1111-1111'), equals('41111111111111'));
      });
      
      test('returns empty string for non-numeric input', () {
        expect(LuhnValidator.normalize('abcd'), equals(''));
        expect(LuhnValidator.normalize(''), equals(''));
        expect(LuhnValidator.normalize('   '), equals(''));
      });
    });
  });
}