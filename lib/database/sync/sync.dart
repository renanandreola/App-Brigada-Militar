import 'package:app_brigada_militar/database/db.dart';
import 'package:app_brigada_militar/database/sync/lastSyncUpdate.dart';
import 'package:app_brigada_militar/database/sync/syncAgriculturalMachines.dart';
import 'package:app_brigada_militar/database/sync/syncProperties.dart';
import 'package:app_brigada_militar/database/sync/syncOwners.dart';
import 'package:app_brigada_militar/database/sync/syncPropertyTypes.dart';
import 'package:app_brigada_militar/database/sync/syncUsers.dart';
import 'package:app_brigada_militar/database/sync/syncVehicles.dart';

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

    // Sync Vehicles
    query = await syncVehicles();
    if (query != null) {
      txn.execute(query);
    }

    // Sync Agricultural Machines
    query = await syncAgriculturalMachines();
    if (query != null) {
      txn.execute(query);
    }

    txn.execute(await lastSyncUpdate());
  });
}

Future<bool> updateSyncAll() async {
  try {
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

      await updateVehicles(txn);
      print("Veículos atualizados");

      await updateAgriculturalMachines(txn);
      print("Máquinas Agrícolas atualizadas");

      txn.execute(await lastSyncUpdate());
      print("Última sincronização atualizada!");
    });

    return true;
  } catch (err) {
    return false;
  }
}