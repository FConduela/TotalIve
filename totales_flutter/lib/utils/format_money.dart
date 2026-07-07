import 'package:intl/intl.dart';

String formatMoney(num n) {
  final f = NumberFormat.currency(
    locale: 'es',
    symbol: r'$',
    decimalDigits: 0,
  );
  return f.format(n).replaceAll('\u00A0', ' ');
}
