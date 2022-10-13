import 'package:app_brigada_militar/database/db.dart';
import 'package:app_brigada_militar/database/sync/lastSyncUpdate.dart';
import 'package:app_brigada_militar/database/sync/syncUsers.dart';

syncAll(var db) async {
  await db.transaction((txn) async {
    // Sync Users
    var query = await syncUsers();
    if (query != null) {
      txn.execute(query);
    }
    txn.execute(await lastSyncUpdate());
  });
}

updateSyncAll() async {
  final db = await DB.instance.database;

  await db.transaction((txn) async {
    await updateUsers(txn);
    print("Usuários sincronizados!");
    txn.execute(await lastSyncUpdate());
    print("Última sincronização atualizada!");
  });

}