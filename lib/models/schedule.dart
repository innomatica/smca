import 'dart:convert';

import '../shared/helpers.dart';
import 'activity.dart';

class Schedule {
  int id;
  int activityId;
  ActivityType activityType;
  List<DateTime> alarmTimes;
  DateTimeMatch alarmMatch;
  Map<String, dynamic> scheduleInfo;

  Schedule({
    required this.id,
    required this.activityId,
    required this.activityType,
    required this.alarmTimes,
    required this.alarmMatch,
    required this.scheduleInfo,
  });

  factory Schedule.fromDatabaseJson(Map<String, dynamic> data) {
    final List<dynamic> alarmStrings = jsonDecode(data['alarmTimes']);
    return Schedule(
      id: data['id'],
      activityId: data['activityId'],
      activityType: ActivityType.values.elementAt(data['activityType']),
      alarmTimes: List.generate(
        alarmStrings.length,
        (index) => DateTime.parse(alarmStrings[index]),
      ),
      alarmMatch: DateTimeMatch.values.elementAt(data['alarmMatch']),
      scheduleInfo: jsonDecode(data['scheduleInfo']) ?? {},
    );
  }

  Map<String, dynamic> toDatabaseJson() {
    final List<String> alarmStrings = List.generate(
        alarmTimes.length, (index) => alarmTimes[index].toIso8601String());
    return {
      'id': id,
      'activityId': activityId,
      'activityType': activityType.index,
      'alarmTimes': jsonEncode(alarmStrings),
      'alarmMatch': alarmMatch.index,
      'scheduleInfo': jsonEncode(scheduleInfo),
    };
  }

  int getAlarmId(int index) {
    if ((index < 0) || (index > alarmTimes.length)) {
      return -1;
    } else {
      return int.parse((id + index).toString().substring(2));
    }
  }

  List<int> getAlarmIdList() {
    final res = <int>[];
    for (var index = 0; index < alarmTimes.length; index++) {
      res.add(getAlarmId(index));
    }
    return res;
  }

  @override
  String toString() {
    return toDatabaseJson().toString();
  }
}

class Alarm {
  int id;
  int activityId;
  ActivityType activityType;
  DateTime alarmTime;
  Map<String, dynamic> alarmInfo;

  Alarm({
    required this.id,
    required this.activityId,
    required this.activityType,
    required this.alarmTime,
    required this.alarmInfo,
  });

  @override
  String toString() {
    return {
      'id': id,
      'activityId': activityId,
      'activityTpe': activityType,
      'alarmTime': alarmTime,
      'alarmInfo': alarmInfo,
    }.toString();
  }
}
