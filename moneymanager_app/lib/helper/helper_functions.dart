// Helpful functions used across the app

import 'package:intl/intl.dart';

double convertStringToDouble(String string) {
  double? amount = double.tryParse(string);
  return amount ?? 0;
}

String formatAmount(double amount) {
  final format = NumberFormat.currency(locale: "en_IN", symbol: "\₹", decimalDigits: 2);
  return format.format(amount);
}