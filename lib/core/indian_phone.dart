const String indianMobileInvalidMessage =
    'Enter a valid 10-digit Indian mobile number. Example: 9451535710 or +919451535710';

/// Normalizes an Indian mobile number to +91XXXXXXXXXX.
/// Returns null when the input is invalid.
String? normalizeIndianMobile(String? input) {
  final raw = (input ?? '').trim();
  if (raw.isEmpty) return null;
  if (RegExp(r'[a-zA-Z]').hasMatch(raw)) return null;

  final cleaned = raw.replaceAll(RegExp(r'[\s\-().]'), '');
  if (cleaned.isEmpty) return null;
  if (!RegExp(r'^\+?[0-9]+$').hasMatch(cleaned)) return null;

  final plusCount = '+'.allMatches(cleaned).length;
  if (plusCount > 1) return null;
  if (plusCount == 1 && !cleaned.startsWith('+')) return null;

  final digits = cleaned.replaceAll(RegExp(r'\D'), '');
  String? national;

  if (cleaned.startsWith('+91')) {
    final afterCountry = cleaned.substring(3);
    if (!RegExp(r'^\d{10}$').hasMatch(afterCountry)) return null;
    national = afterCountry;
  } else if (digits.length == 10) {
    national = digits;
  } else if (digits.length == 12 && digits.startsWith('91')) {
    national = digits.substring(2);
  } else {
    return null;
  }

  if (!RegExp(r'^[6-9]\d{9}$').hasMatch(national)) return null;
  return '+91$national';
}

String? indianMobileValidator(String? value) {
  if (value == null || value.trim().isEmpty) return 'Required';
  if (RegExp(r'[a-zA-Z]').hasMatch(value)) {
    return 'Phone number cannot contain letters';
  }
  if (normalizeIndianMobile(value) == null) {
    return indianMobileInvalidMessage;
  }
  return null;
}
