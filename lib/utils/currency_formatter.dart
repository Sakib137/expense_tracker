import 'package:intl/intl.dart';

class CurrencyFormatter {
  static String format(double amount, {String symbol = '\$', bool showSign = false}) {
    final formatter = NumberFormat('#,##0.00', 'en_US');
    final formattedNumber = formatter.format(amount.abs());
    
    if (showSign) {
      if (amount > 0) {
        return '+$symbol$formattedNumber';
      } else if (amount < 0) {
        return '-$symbol$formattedNumber';
      }
    }
    return '$symbol$formattedNumber';
  }

  static String formatCompact(double amount, {String symbol = '\$'}) {
    final formatter = NumberFormat.compact(locale: 'en_US');
    final formatted = formatter.format(amount.abs());
    if (amount < 0) {
      return '-$symbol$formatted';
    }
    return '$symbol$formatted';
  }

  static String formatPercent(double percent) {
    return '${(percent * 100).toStringAsFixed(1)}%';
  }
}
