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
