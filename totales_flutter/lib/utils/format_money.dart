import 'package:intl/intl.dart';

String formatMoney(num n) {
  final amount = NumberFormat('#,##0', 'es').format(n);
  return '\$$amount';
}
