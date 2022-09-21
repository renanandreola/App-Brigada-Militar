import 'package:intl/intl.dart';

datetimeToStr(DateTime date) {
  final DateFormat formatter = DateFormat('yyyy-MM-dd HH:mm:ss');
  return formatter.format(date);
}
