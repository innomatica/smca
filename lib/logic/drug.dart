import 'dart:async';

import 'package:flutter/foundation.dart';

import '../models/drug.dart';
import '../models/schedule.dart';
import '../services/health_canada.dart';
import '../services/notification.dart';
import '../services/sqlite.dart';
import '../shared/settings.dart';

class DrugBloc extends ChangeNotifier {
  final _db = SqliteService();
  final _ns = NotificationService();

  List<Drug> _drugs = <Drug>[];

  DrugBloc() {
    refresh();
  }

  List<Drug> get drugs {
    return _drugs;
  }

  Future refresh() async {
    _drugs = await _db.getDrugs();
    notifyListeners();
  }

  //
  // Drug
  //
  // this is a multi step process
  Future add(Drug drug) async {
    List<dynamic>? res;
    // create a drug entry using minimal information
    await _db.addDrug(drug);
    update(drug);

    // fetch additional data from the server
    if (drug.drugType == 'DIN') {
      res = await DpdApiService.getProductInfo(drug, 'activeingredient');
      if (res != null) {
        drug.drugInfo['activeingredient'] = res;
      }
      res = await DpdApiService.getProductInfo(drug, 'form');
      if (res != null) {
        drug.dosageInfo['form'] = res;
      }
      res = await DpdApiService.getProductInfo(drug, 'packaging');
      if (res != null) {
        drug.drugInfo['packaging'] = res;
      }
      res = await DpdApiService.getProductInfo(drug, 'pharmaceuticalstd');
      if (res != null) {
        drug.drugInfo['standard'] = res;
      }
      res = await DpdApiService.getProductInfo(drug, 'route');
      if (res != null) {
        drug.dosageInfo['route'] = res;
      }
      res = await DpdApiService.getProductInfo(drug, 'schedule');
      if (res != null) {
        drug.drugInfo['schedule'] = res;
      }
      res = await DpdApiService.getProductInfo(drug, 'status');
      if (res != null) {
        drug.drugInfo['status'] = res;
      }
      res = await DpdApiService.getProductInfo(drug, 'therapeuticclass');
      if (res != null) {
        drug.drugInfo['class'] = res;
      }

      // company endpoint is not usable
      // res = await _dpd.getProductInfo(drug, 'company');

      // we are not dealing with vet products
      // res = await _dpd.getProductInfo(drug, 'veterinaryspecies');
      // if ((res != null) && (res.isNotEmpty)) {}

      update(drug);
    } else {
      res = await LnhpdApiService.getProductInfo(drug, 'medicinalingredient');
      if (res != null) {
        if (res.isNotEmpty) {
          drug.drugInfo['medicinalingredient'] = res[0]['data'];
        } else {
          drug.drugInfo['medicinalingredient'] = [];
        }
      }
      res =
          await LnhpdApiService.getProductInfo(drug, 'nonmedicinalingredient');
      if (res != null) {
        drug.drugInfo['nonmedicinalingredient'] = res;
      }
      res = await LnhpdApiService.getProductInfo(drug, 'productdose');
      if (res != null) {
        drug.dosageInfo['productdose'] = res;
      }
      res = await LnhpdApiService.getProductInfo(drug, 'productlicence');
      if (res != null) {
        drug.drugInfo['productlicence'] = res;
      }
      res = await LnhpdApiService.getProductInfo(drug, 'productpurpose');
      if (res != null) {
        if (res.isNotEmpty) {
          drug.consumerInfo['productpurpose'] = res[0]['data'];
        } else {
          drug.consumerInfo['productpurpose'] = [];
        }
      }
      res = await LnhpdApiService.getProductInfo(drug, 'productrisk');
      if (res != null) {
        if (res.isNotEmpty) {
          drug.consumerInfo['productrisk'] = res[0]['data'];
        } else {
          drug.consumerInfo['productrisk'] = [];
        }
      }
      res = await LnhpdApiService.getProductInfo(drug, 'productroute');
      if (res != null) {
        drug.dosageInfo['productroute'] = res;
      }
      update(drug);
    }
    refresh();
  }

  Future update(Drug drug) async {
    await _db.updateDrug(drug);
    refresh();
  }

  Future delete(Drug drug) async {
    final schedule = await getSchedule(drug);
    if (schedule != null) {
      await _ns.cancelScheduleNotifications(schedule);
    }
    await _db.deleteScheduleById(drug.id);
    await _db.deleteDrugById(drug.id);
    refresh();
  }

  Future<List<Drug>> getDrugs() async {
    final drugs = await _db.getDrugs();
    return drugs;
  }

  //
  // Schedule belongs to drugs
  //
  Future addSchedule(Schedule schedule) async {
    await _db.addSchedule(schedule);
    useInboxNotification
        ? await _ns.scheduleInboxNotifications(schedule)
        : await _ns.scheduleNotifications(schedule);
    refresh();
  }

  Future updateSchedule(Schedule schedule) async {
    await _db.updateSchedule(schedule);
    useInboxNotification
        ? await _ns.scheduleInboxNotifications(schedule)
        : await _ns.scheduleNotifications(schedule);
    refresh();
  }

  Future deleteSchedule(Schedule schedule) async {
    await _ns.cancelScheduleNotifications(schedule);
    await _db.deleteScheduleById(schedule.id);
    refresh();
  }

  Future<Schedule?> getSchedule(Drug drug) async {
    final schedule = await _db.getScheduleById(drug.id);
    return schedule;
  }
}
