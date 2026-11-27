/// Formats an integer amount as a Nepali Rupee string.
///
/// Output is identical to the previously duplicated `_formatNpr` helpers:
/// e.g. `formatNpr(1000)` -> `'NPR 1,000'`, `formatNpr(250)` -> `'NPR 250'`.
String formatNpr(int amount) {
  final str = amount.toString();
  if (str.length <= 3) return 'NPR $str';
  final prefix = str.substring(0, str.length - 3);
  final suffix = str.substring(str.length - 3);
  return 'NPR $prefix,$suffix';
}

/// Formats an ISO-8601 date string (e.g. "2024-01-15" or "2024-01-15T10:30:00")
/// into a short DD/MM/YYYY string. Returns 'recently' for null/empty input.
String formatDateDmy(String? dateStr) {
  if (dateStr == null || dateStr.isEmpty) return 'recently';
  try {
    // Take only the date portion in case a time component is present.
    final datePart = dateStr.split('T').first.split(' ').first;
    final parts = datePart.split('-');
    if (parts.length == 3) {
      return '${parts[2]}/${parts[1]}/${parts[0]}';
    }
    final parsed = DateTime.parse(datePart);
    return '${parsed.day.toString().padLeft(2, '0')}/${parsed.month.toString().padLeft(2, '0')}/${parsed.year}';
  } catch (_) {
    return dateStr;
  }
}
