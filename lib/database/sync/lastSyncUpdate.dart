import 'package:app_brigada_militar/database/utils/datetimeToStr.dart';

lastSyncUpdate() async {
  final DateTime now = DateTime.now();
  String datetimeStr = datetimeToStr(now);

  String query = "UPDATE sync SET last_sync = '${datetimeStr}'";
  return query;
}