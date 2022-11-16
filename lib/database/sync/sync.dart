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

syncAll(var db, bool? istransaction) async {

  if (istransaction != null && istransaction == true) {
      // Sync Users
      var query = await syncUsers();
      if (query != null) {
        db.execute(query);
      }
      print("Usuários Sincronizados!");

      // Sync Owners
      query = await syncOwners();
      if (query != null) {
        db.execute(query);
      }
      print("Proprietários Sincronizados!");

      // Sync PropertyTypes
      query = await syncPropertyTypes();
      if (query != null) {
        db.execute(query);
      }
      print("Tipos de Propriedades Sincronizadas!");


      // Sync Properties
      query = await syncProperties();
      if (query != null) {
        db.execute(query);
      }
      print("Propriedades Sincronizadas!");


      // Sync Vehicles
      query = await syncVehicles();
      if (query != null) {
        db.execute(query);
      }
      print("Veículos de Propriedades Sincronizadas!");


      // Sync Agricultural Machines
      query = await syncAgriculturalMachines();
      if (query != null) {
        db.execute(query);
      }
      print("Máquinas Agrícolas de Propriedades Sincronizadas!");


      // Sync Visits
      query = await syncVisits();
      if (query != null) {
        db.execute(query);
      }
      print("Visitas Sincronizadas!");


      // Sync User Visits
      query = await syncUserVisits();
      if (query != null) {
        db.execute(query);
      }
      print("Visitas de Usuários Sincronizadas!");


      // Sync Requests
      query = await syncRequests();
      if (query != null) {
        db.execute(query);
      }
      print("Solicitações Sincronizadas!");

      // Sync Property Vehicles
      query = await syncPropertyVehicles();
      if (query != null) {
        db.execute(query);
      }
      print("Veículos das Propriedades Sincronizadas!");


      // Sync Property Agricultural Machines
      query = await syncPropertyAgriculturalMachines();
      if (query != null) {
        db.execute(query);
      }
      print("Máquinas Agrícolas das Propriedades Sincronizadas!");

      db.execute(await lastSyncUpdate());

      print("Banco sincronizado com sucesso!");
  } else {
    await db.transaction((txn) async {
      // Sync Users
      var query = await syncUsers();
      if (query != null) {
        txn.execute(query);
      }
      print("Usuários Sincronizados!");

      // Sync Owners
      query = await syncOwners();
      if (query != null) {
        txn.execute(query);
      }
      print("Proprietários Sincronizados!");

      // Sync PropertyTypes
      query = await syncPropertyTypes();
      if (query != null) {
        txn.execute(query);
      }
      print("Tipos de Propriedades Sincronizadas!");


      // Sync Properties
      query = await syncProperties();
      if (query != null) {
        txn.execute(query);
      }
      print("Propriedades Sincronizadas!");


      // Sync Vehicles
      query = await syncVehicles();
      if (query != null) {
        txn.execute(query);
      }
      print("Veículos de Propriedades Sincronizadas!");


      // Sync Agricultural Machines
      query = await syncAgriculturalMachines();
      if (query != null) {
        txn.execute(query);
      }
      print("Máquinas Agrícolas de Propriedades Sincronizadas!");


      // Sync Visits
      query = await syncVisits();
      if (query != null) {
        txn.execute(query);
      }
      print("Visitas Sincronizadas!");


      // Sync User Visits
      query = await syncUserVisits();
      if (query != null) {
        txn.execute(query);
      }
      print("Visitas de Usuários Sincronizadas!");


      // Sync Requests
      query = await syncRequests();
      if (query != null) {
        txn.execute(query);
      }
      print("Solicitações Sincronizadas!");

      // Sync Property Vehicles
      query = await syncPropertyVehicles();
      if (query != null) {
        txn.execute(query);
      }
      print("Veículos das Propriedades Sincronizadas!");


      // Sync Property Agricultural Machines
      query = await syncPropertyAgriculturalMachines();
      if (query != null) {
        txn.execute(query);
      }
      print("Máquinas Agrícolas das Propriedades Sincronizadas!");

      txn.execute(await lastSyncUpdate());

      print("Banco sincronizado com sucesso!");
    });
  }
}

Future<bool> deleteAll(var db) async {
  await db.delete('users');
  await db.delete('user_visits');
  await db.delete('visits');
  await db.delete('properties');
  await db.delete('owners');
  await db.delete('property_vehicles');
  await db.delete('property_types');
  await db.delete('property_agricultural_machines');
  await db.delete('requests');
  await db.delete('vehicles');
  await db.delete('agricultural_machines');

  return true;
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

      deleteAll(txn);
      syncAll(txn, true);
      print("Todos os dados recebidos novamente!");

      txn.execute(await lastSyncUpdate());
      print("Última sincronização atualizada!");
    });

    return true;
  } catch (err) {
    print(err);
    return false;
  }
}