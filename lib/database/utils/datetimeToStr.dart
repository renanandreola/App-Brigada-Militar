import 'package:intl/intl.dart';

datetimeToStr(DateTime date) {
  date = date.toUtc();
  final DateFormat formatter = DateFormat('yyyy-MM-ddTHH:mm:ss');
  return formatter.format(date);
}
