import 'package:app_brigada_militar/database/db.dart';
import 'package:app_brigada_militar/database/sync/lastSyncUpdate.dart';
import 'package:app_brigada_militar/database/sync/syncAgriculturalMachines.dart';
import 'package:app_brigada_militar/database/sync/syncProperties.dart';
import 'package:app_brigada_militar/database/sync/syncOwners.dart';
import 'package:app_brigada_militar/database/sync/syncPropertyAgriculturalMachines.dart';
import 'package:app_brigada_militar/database/sync/syncPropertyTypes.dart';
import 'package:app_brigada_militar/database/sync/syncPropertyVehicles.dart';
import 'package:app_brigada_militar/database/sync/syncRequests.dart';
import 'package:app_brigada_militar/database/sync/syncUserVisits.dart';
import 'package:app_brigada_militar/database/sync/syncUsers.dart';
import 'package:app_brigada_militar/database/sync/syncVehicles.dart';
import 'package:app_brigada_militar/database/sync/syncVisits.dart';

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

    // Sync Visits
    query = await syncVisits();
    if (query != null) {
      txn.execute(query);
    }

    // Sync User Visits
    query = await syncUserVisits();
    if (query != null) {
      txn.execute(query);
    }

    // Sync Requests
    query = await syncRequests();
    if (query != null) {
      txn.execute(query);
    }

    // Sync Property Vehicles
    query = await syncPropertyVehicles();
    if (query != null) {
      txn.execute(query);
    }

    // Sync Property Agricultural Machines
    query = await syncPropertyAgriculturalMachines();
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

      await updateVisits(txn);
      print("Visitas atualizadas");

      await updateUserVisits(txn);
      print("Visitas dos Usuários atualizadas");

      await updateRequests(txn);
      print("Solicitações atualizadas");

      await updatePropertyVehicles(txn);
      print("Veículos das Propriedades atualizados");

      await updatePropertyAgriculturalMachines(txn);
      print("Máquinas Agrícolas das Propriedades atualizados");

      txn.execute(await lastSyncUpdate());
      print("Última sincronização atualizada!");
    });

    return true;
  } catch (err) {
    return false;
  }
}