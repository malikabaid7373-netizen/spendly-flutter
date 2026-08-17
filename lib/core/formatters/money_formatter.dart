import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

String formatMoney(BuildContext context, double value, {bool compact = false}) {
  final locale = Localizations.localeOf(context).languageCode;
  final formatter = compact
      ? NumberFormat.compactCurrency(locale: locale, symbol: 'SAR ', decimalDigits: 0)
      : NumberFormat.currency(locale: locale, symbol: 'SAR ', decimalDigits: 0);
  return formatter.format(value);
}

String formatDate(BuildContext context, DateTime date) {
  final locale = Localizations.localeOf(context).languageCode;
  return DateFormat('dd MMM', locale).format(date);
}
