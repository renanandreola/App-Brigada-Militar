import 'package:app_brigada_militar/database/db.dart';
import 'package:app_brigada_militar/database/sync/lastSyncUpdate.dart';
import 'package:app_brigada_militar/database/sync/syncProperties.dart';
import 'package:app_brigada_militar/database/sync/syncOwners.dart';
import 'package:app_brigada_militar/database/sync/syncPropertyTypes.dart';
import 'package:app_brigada_militar/database/sync/syncUsers.dart';

syncAll(var db) async {
  await db.transaction((txn) async {
    // Sync Users
    var query = await syncUsers();
    if (query != null) {
      txn.execute(query);
    }

    // Sync Owners
    query = await syncOwners();
    if (query != null) {
      txn.execute(query);
    }

    // Sync PropertyTypes
    query = await syncPropertyTypes();
    if (query != null) {
      txn.execute(query);
    }

    // Sync Properties
    query = await syncProperties();
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

    await updateOwners(txn);
    print("Proprietários sincronizados!");

    await updatePropertyTypes(txn);
    print("Tipos de Propriedades atualizadas");

    await updateProperties(txn);
    print("Propriedades atualizadas");

    txn.execute(await lastSyncUpdate());
    print("Última sincronização atualizada!");
  });

}