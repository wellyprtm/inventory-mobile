class CurrencyFormatter {
  /// Converts double amount to Indonesian Rupiah string (e.g. 1500000 -> Rp 1.500.000)
  static String formatRupiah(double amount) {
    final integerPart = amount.toStringAsFixed(0);
    final buffer = StringBuffer();

    for (int i = 0; i < integerPart.length; i++) {
      if (i > 0 && (integerPart.length - i) % 3 == 0) {
        buffer.write('.');
      }
      buffer.write(integerPart[i]);
    }

    return 'Rp $buffer';
  }
}

class DateFormatter {
  /// Formats DateTime to readable string (e.g. 2026-10-20 04:15)
  static String formatDateTime(DateTime dt) {
    final y = dt.year.toString().padLeft(4, '0');
    final m = dt.month.toString().padLeft(2, '0');
    final d = dt.day.toString().padLeft(2, '0');
    final h = dt.hour.toString().padLeft(2, '0');
    final min = dt.minute.toString().padLeft(2, '0');
    return '$d-$m-$y $h:$min';
  }
}
