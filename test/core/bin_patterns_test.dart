import 'package:flutter_test/flutter_test.dart';

import 'package:card_submitter/core/utils/bin_patterns.dart';
import 'package:card_submitter/domain/value_objects/card_brand.dart';

void main() {
  group('BinPatterns', () {
    group('detectBrand', () {
      test('detects Visa cards correctly', () {
        expect(BinPatterns.detectBrand('4111111111111111'), equals(CardBrand.visa));
        expect(BinPatterns.detectBrand('4000000000000000'), equals(CardBrand.visa));
        expect(BinPatterns.detectBrand('4999999999999999'), equals(CardBrand.visa));
      });
      
      test('detects Mastercard cards correctly', () {
        // Traditional Mastercard range (51-55)
        expect(BinPatterns.detectBrand('5555555555554444'), equals(CardBrand.mastercard));
        expect(BinPatterns.detectBrand('5105105105105100'), equals(CardBrand.mastercard));
        expect(BinPatterns.detectBrand('5199999999999999'), equals(CardBrand.mastercard));
        
        // New Mastercard range (2221-2720)
        expect(BinPatterns.detectBrand('2221000000000000'), equals(CardBrand.mastercard));
        expect(BinPatterns.detectBrand('2720000000000000'), equals(CardBrand.mastercard));
      });
      
      test('detects American Express cards correctly', () {
        expect(BinPatterns.detectBrand('378282246310005'), equals(CardBrand.americanExpress));
        expect(BinPatterns.detectBrand('371449635398431'), equals(CardBrand.americanExpress));
        expect(BinPatterns.detectBrand('340000000000009'), equals(CardBrand.americanExpress));
        expect(BinPatterns.detectBrand('370000000000002'), equals(CardBrand.americanExpress));
      });
      
      test('detects Discover cards correctly', () {
        expect(BinPatterns.detectBrand('6011111111111117'), equals(CardBrand.discover));
        expect(BinPatterns.detectBrand('6500000000000000'), equals(CardBrand.discover));
        expect(BinPatterns.detectBrand('6440000000000000'), equals(CardBrand.discover));
        expect(BinPatterns.detectBrand('6220000000000000'), equals(CardBrand.discover));
      });
      
      test('detects Diners Club cards correctly', () {
        expect(BinPatterns.detectBrand('30000000000000'), equals(CardBrand.dinersClub));
        expect(BinPatterns.detectBrand('30500000000000'), equals(CardBrand.dinersClub));
        expect(BinPatterns.detectBrand('36000000000000'), equals(CardBrand.dinersClub));
        expect(BinPatterns.detectBrand('38000000000000'), equals(CardBrand.dinersClub));
      });
      
      test('detects JCB cards correctly', () {
        expect(BinPatterns.detectBrand('3528000000000000'), equals(CardBrand.jcb));
        expect(BinPatterns.detectBrand('3589000000000000'), equals(CardBrand.jcb));
      });
      
      test('returns unknown for unrecognized patterns', () {
        expect(BinPatterns.detectBrand('1111111111111111'), equals(CardBrand.unknown));
        expect(BinPatterns.detectBrand('9999999999999999'), equals(CardBrand.unknown));
        expect(BinPatterns.detectBrand(''), equals(CardBrand.unknown));
      });
      
      test('handles numbers with spaces and dashes', () {
        expect(BinPatterns.detectBrand('4111 1111 1111 1111'), equals(CardBrand.visa));
        expect(BinPatterns.detectBrand('4111-1111-1111-1111'), equals(CardBrand.visa));
        expect(BinPatterns.detectBrand('5555 5555 5555 4444'), equals(CardBrand.mastercard));
      });
    });
    
    group('getCvvLength', () {
      test('returns correct CVV length for each brand', () {
        expect(BinPatterns.getCvvLength(CardBrand.visa), equals(3));
        expect(BinPatterns.getCvvLength(CardBrand.mastercard), equals(3));
        expect(BinPatterns.getCvvLength(CardBrand.americanExpress), equals(4));
        expect(BinPatterns.getCvvLength(CardBrand.discover), equals(3));
        expect(BinPatterns.getCvvLength(CardBrand.dinersClub), equals(3));
        expect(BinPatterns.getCvvLength(CardBrand.jcb), equals(3));
        expect(BinPatterns.getCvvLength(CardBrand.unknown), equals(3));
      });
    });
    
    group('isValidCvvLength', () {
      test('validates CVV length correctly for each brand', () {
        // Visa
        expect(BinPatterns.isValidCvvLength('123', CardBrand.visa), isTrue);
        expect(BinPatterns.isValidCvvLength('1234', CardBrand.visa), isFalse);
        expect(BinPatterns.isValidCvvLength('12', CardBrand.visa), isFalse);
        
        // American Express
        expect(BinPatterns.isValidCvvLength('1234', CardBrand.americanExpress), isTrue);
        expect(BinPatterns.isValidCvvLength('123', CardBrand.americanExpress), isFalse);
        expect(BinPatterns.isValidCvvLength('12345', CardBrand.americanExpress), isFalse);
        
        // Mastercard
        expect(BinPatterns.isValidCvvLength('123', CardBrand.mastercard), isTrue);
        expect(BinPatterns.isValidCvvLength('1234', CardBrand.mastercard), isFalse);
      });
    });
  });
}