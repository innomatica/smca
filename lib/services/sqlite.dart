import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

import '../models/activity.dart';
import '../models/device.dart';
import '../models/drug.dart';
import '../models/log.dart';
import '../models/schedule.dart';
import '../shared/helpers.dart';

const databaseVersion = 3;
const databaseName = 'SafeMed.sqlite3';
const sqlCreateTables = [
  sqlCreateDrugs,
  sqlCreateSchedules,
  sqlCreateActivities,
  sqlCreateLogs,
  sqlCreateDevices,
];
const sqlDropTables = [
  sqlDropDrugs,
  sqlDropSchedules,
  sqlDropActivities,
  sqlDropLogs,
  sqlDropDevices,
];

const tableDrugs = 'drugs';
const tableActivities = 'activities';
const tableSchedules = 'schedules';
const tableLogs = 'logs';
const tableDevices = 'devices';

const sqlCreateDrugs = 'CREATE TABLE $tableDrugs ('
    'id INTEGER PRIMARY KEY'
    ',drugId TEXT'
    ',drugName TEXT'
    ',drugType TEXT'
    ',frequency TEXT'
    ',drugInfo Text'
    ',companyInfo TEXT'
    ',prescriptionInfo TEXT'
    ',recallInfo TEXT'
    ',efficacyInfo TEXT'
    ',dosageInfo TEXT'
    ',warningInfo TEXT'
    ',durInfo TEXT'
    ',consumerInfo TEXT'
    ');';
const sqlCreateActivities = 'CREATE TABLE $tableActivities ('
    'id INTEGER PRIMARY KEY'
    ',activityName TEXT'
    ',activityType INTEGER'
    ',frequency TEXT'
    ',activityInfo TEXT'
    ');';
const sqlCreateSchedules = 'CREATE TABLE $tableSchedules ('
    'id INTEGER PRIMARY KEY'
    ',activityId INTEGER'
    ',activityType INTEGER'
    ',alarmTimes TEXT'
    ',alarmMatch INTEGER'
    ',scheduleInfo TEXT'
    ');';
const sqlCreateLogs = 'CREATE TABLE $tableLogs ('
    'id INTEGER PRIMARY KEY'
    ',activityId INTEGER'
    ',activityType INTEGER'
    ',scheduledTime TEXT'
    ',loggedTime TEXT'
    ',logInfo TEXT'
    ');';
const sqlCreateDevices = 'CREATE TABLE $tableDevices ('
    'macAddress TEXT PRIMARY KEY'
    ',deviceName TEXT'
    ',deviceType TEXT'
    ',deviceInfo TEXT'
    ');';

const sqlDropDrugs = 'DROP TABLE IF EXISTS $tableDrugs';
const sqlDropActivities = 'DROP TABLE IF EXISTS $tableActivities';
const sqlDropSchedules = 'DROP TABLE IF EXISTS $tableSchedules';
const sqlDropLogs = 'DROP TABLE IF EXISTS $tableLogs';
const sqlDropDevices = 'DROP TABLE IF EXISTS $tableDevices';

class SqliteService {
  // singleton class using factory constructor
  SqliteService._internal();
  static final SqliteService _instance = SqliteService._internal();
  factory SqliteService() {
    return _instance;
  }

  Database? _db;

  Future<void> close() async {
    if (_db != null) {
      _db!.close();
    }
  }

  Future<void> open() async {
    var dbPath = await getDatabasesPath();
    String path = join(dbPath, databaseName);

    _db = await openDatabase(
      path,
      version: databaseVersion,
      onCreate: (Database db, int version) async {
        debugPrint('open.onCreate: creating database tables');
        for (final statement in sqlCreateTables) {
          await db.execute(statement);
        }
      },
      onUpgrade: (Database db, int oldVersion, int newVersion) async {
        if (oldVersion == 1) {
          // version 1 database is incompatible
          for (final statement in sqlDropTables) {
            debugPrint('open.onUpgrade: deleting old database tables');
            await db.execute(statement);
          }
          for (final statement in sqlCreateTables) {
            debugPrint('open.onUpgrade: creating database tables');
            await db.execute(statement);
          }
        } else if (oldVersion == 2) {
          // new table added after version 2
          await db.execute(sqlCreateDevices);
        }
      },
    );
  }

  Future<Database> getDatabase() async {
    if (_db == null) {
      await open();
    }
    return _db!;
  }

  // Drug ----------------------------------------------------------
  Future<List<Drug>> getDrugs({Map<String, dynamic>? query}) async {
    final db = await getDatabase();
    final res = <Drug>[];
    final snapshot = await db.query(
      tableDrugs,
      where: query?['where'],
      whereArgs: query?['whereArgs'],
    );

    for (final element in snapshot) {
      res.add(Drug.fromDatabaseJson(element));
    }
    return res;
  }

  Future<int> addDrug(Drug drug) async {
    final db = await getDatabase();
    final res = await db.insert(
      tableDrugs,
      drug.toDatabaseJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    return res;
  }

  Future<int> updateDrug(Drug drug) async {
    final db = await getDatabase();
    final res = await db.update(
      tableDrugs,
      drug.toDatabaseJson(),
      where: 'id = ?',
      whereArgs: [drug.id],
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    return res;
  }

  Future<int> deleteDrugById(int id) async {
    final db = await getDatabase();
    final res = await db.delete(tableDrugs, where: 'id = ?', whereArgs: [id]);
    return res;
  }

  // Schedule and Alarm ---------------------------------------------
  Future<List<Alarm>> getAlarms({Map<String, dynamic>? query}) async {
    final alarms = <Alarm>[];
    final db = await getDatabase();
    final snapshot = await db.query(
      tableSchedules,
      where: query?['where'],
      whereArgs: query?['whereArgs'],
    );
    for (final element in snapshot) {
      if (element.containsKey('alarmTimes')) {
        final schedule = Schedule.fromDatabaseJson(element);
        for (var index = 0; index < schedule.alarmTimes.length; index++) {
          final now = DateTime.now();
          final alarmTime = schedule.alarmTimes[index];
          final alarmMatch = schedule.alarmMatch;

          if ((alarmMatch == DateTimeMatch.time) ||
              ((alarmMatch == DateTimeMatch.dayOfWeekAndTime) &&
                  (now.weekday == alarmTime.weekday)) ||
              ((alarmMatch == DateTimeMatch.dayOfMonthAndTime) &&
                  (now.day == alarmTime.day)) ||
              ((alarmMatch == DateTimeMatch.dateAndTime) &&
                  (now.month == alarmTime.month) &&
                  (now.day == alarmTime.day))) {
            alarms.add(Alarm(
              id: schedule.getAlarmId(index),
              activityId: schedule.activityId,
              activityType: schedule.activityType,
              alarmTime: alarmTime,
              alarmInfo: {
                ...schedule.scheduleInfo,
              },
            ));
          }
        }
      }
    }
    return alarms;
  }

  Future<int> addSchedule(Schedule schedule) async {
    final db = await getDatabase();
    final res = db.insert(
      tableSchedules,
      schedule.toDatabaseJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    return res;
  }

  Future<Schedule?> getScheduleById(int id) async {
    final db = await getDatabase();
    final snapshot = await db.query(
      tableSchedules,
      where: 'id = ?',
      whereArgs: [id],
    );
    if (snapshot.isNotEmpty) {
      return Schedule.fromDatabaseJson(snapshot[0]);
    } else {
      return null;
    }
  }

  Future<int> updateSchedule(Schedule schedule) async {
    final db = await getDatabase();
    final res = db.update(
      tableSchedules,
      schedule.toDatabaseJson(),
      where: 'id = ?',
      whereArgs: [schedule.id],
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    return res;
  }

  Future<int> deleteScheduleById(int id) async {
    final db = await getDatabase();
    final res = await db.delete(
      tableSchedules,
      where: 'id = ?',
      whereArgs: [id],
    );
    return res;
  }

  // Log ---------------------------------------------------------
  Future<List<Log>> getLogs({Map<String, dynamic>? query}) async {
    final db = await getDatabase();
    final res = <Log>[];
    final snapshot = await db.query(
      tableLogs,
      where: query?['where'],
      whereArgs: query?['whereArgs'],
    );

    for (final element in snapshot) {
      res.add(Log.fromDatabaseJson(element));
    }
    return res;
  }

  Future<int> addLog(Log log) async {
    final db = await getDatabase();
    final res = await db.insert(
      tableLogs,
      log.toDatabaseJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    return res;
  }

  Future addSampleLogs(ActivityType activityType, int activityId) async {
    final db = await getDatabase();
    // insert 60 data points to the table
    final now = DateTime.now();
    final random = Random();
    final scheduledTime = DateTime(now.year, now.month - 2, now.day, 12);
    for (var index = 0; index < 60; index++) {
      var loggedTime = scheduledTime.add(Duration(days: index));
      var log = Log(
        // note this will overwrite existing data created at the same day
        id: loggedTime.millisecondsSinceEpoch,
        activityId: activityId,
        activityType: activityType,
        scheduledTime: scheduledTime,
        loggedTime: loggedTime,
        logInfo: {
          'measurement': activityType == ActivityType.measureBloodPressureLevel
              ? '${100 + random.nextInt(40)} , ${60 + random.nextInt(40)}'
              : random.nextInt(100).toString(),
          'note': 'random notes ... ${random.nextInt(10)}'
        },
      );
      await db.insert(
        tableLogs,
        log.toDatabaseJson(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    debugPrint('60 sample data points inserted with ActivityId: $activityId');
    return;
  }

  // Activity ----------------------------------------------------
  Future<List<Activity>> getActivities({Map<String, dynamic>? query}) async {
    final db = await getDatabase();
    final res = <Activity>[];
    final snapshot = await db.query(
      tableActivities,
      where: query?['where'],
      whereArgs: query?['whereArgs'],
    );

    for (final element in snapshot) {
      res.add(Activity.fromDatabaseJson(element));
    }
    return res;
  }

  Future<int> addActivity(Activity activity) async {
    final db = await getDatabase();
    final res = await db.insert(
      tableActivities,
      activity.toDatabaseJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    return res;
  }

  Future<Activity?> getActivityById(int id) async {
    final db = await getDatabase();
    final snapshot = await db.query(
      tableActivities,
      where: 'id = ?',
      whereArgs: [id],
    );
    if (snapshot.isNotEmpty) {
      return Activity.fromDatabaseJson(snapshot[0]);
    } else {
      return null;
    }
  }

  Future<int> updateActivity(Activity activity) async {
    final db = await getDatabase();
    final res = db.update(
      tableActivities,
      activity.toDatabaseJson(),
      where: 'id = ?',
      whereArgs: [activity.id],
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    return res;
  }

  Future<int> deleteActivityById(int id) async {
    final db = await getDatabase();
    final res = await db.delete(
      tableActivities,
      where: 'id = ?',
      whereArgs: [id],
    );
    return res;
  }

  // Device ----------------------------------------------------
  Future<List<Device>> getDevices({Map<String, dynamic>? query}) async {
    final db = await getDatabase();
    final res = <Device>[];
    final snapshot = await db.query(
      tableDevices,
      where: query?['where'],
      whereArgs: query?['whereArgs'],
    );

    for (final element in snapshot) {
      res.add(Device.fromDatabaseJson(element));
    }
    return res;
  }

  Future<int> addDevice(Device device) async {
    final db = await getDatabase();
    final res = await db.insert(
      tableDevices,
      device.toDatabaseJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    return res;
  }

  Future<Device?> getDeviceByMacAddress(String macAddress) async {
    final db = await getDatabase();
    final snapshot = await db.query(
      tableDevices,
      where: 'macAddress = ?',
      whereArgs: [macAddress],
    );
    if (snapshot.isNotEmpty) {
      return Device.fromDatabaseJson(snapshot[0]);
    } else {
      return null;
    }
  }

  Future<int> updateDevice(Device device) async {
    final db = await getDatabase();
    final res = db.update(
      tableDevices,
      device.toDatabaseJson(),
      where: 'macAddress = ?',
      whereArgs: [device.macAddress],
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    return res;
  }

  Future<int> deleteDeviceByMacAddress(String macAddress) async {
    final db = await getDatabase();
    final res = await db.delete(
      tableDevices,
      where: 'macAddress = ?',
      whereArgs: [macAddress],
    );
    return res;
  }
}
