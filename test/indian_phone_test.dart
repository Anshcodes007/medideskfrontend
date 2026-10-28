import 'package:flutter_test/flutter_test.dart';
import 'package:medidesk/core/indian_phone.dart';

void main() {
  group('normalizeIndianMobile', () {
    test('accepts valid formats and stores +91XXXXXXXXXX', () {
      const expected = '+919451535710';
      expect(normalizeIndianMobile('9451535710'), expected);
      expect(normalizeIndianMobile('94515 35710'), expected);
      expect(normalizeIndianMobile('+91 94515 35710'), expected);
      expect(normalizeIndianMobile('+919451535710'), expected);
      expect(normalizeIndianMobile('+91-94515-35710'), expected);
    });

    test('does not double the country code', () {
      expect(normalizeIndianMobile('919451535710'), '+919451535710');
      expect(normalizeIndianMobile('+919451535710'), '+919451535710');
      expect(normalizeIndianMobile('+91+919451535710'), isNull);
      expect(normalizeIndianMobile('+91919451535710'), isNull);
    });

    test('rejects invalid lengths, letters, and non-mobile numbers', () {
      expect(normalizeIndianMobile('94515357'), isNull);
      expect(normalizeIndianMobile('94515357101'), isNull);
      expect(normalizeIndianMobile('94515abc10'), isNull);
      expect(normalizeIndianMobile('5451535710'), isNull);
      expect(normalizeIndianMobile(''), isNull);
    });
  });
}
