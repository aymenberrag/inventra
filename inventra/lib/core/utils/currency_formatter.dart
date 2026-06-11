import 'package:intl/intl.dart';

class CurrencyFormatter {
  static final Map<String, String> symbols = {
    'USD': '\$',
    'EUR': '€',
    'GBP': '£',
    'MAD': 'MAD ',
    'DZD': 'DZD ',
    'TND': 'TND ',
  };

  static String format(double amount, String currency) {
    final symbol = symbols[currency] ?? '$currency ';
    final formatter = NumberFormat('#,##0.00');
    return '$symbol${formatter.format(amount)}';
  }
}
