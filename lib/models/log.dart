import 'dart:convert';

import '../shared/helpers.dart';
import 'activity.dart';

class Log {
  int id;
  int activityId;
  ActivityType activityType;
  DateTime scheduledTime;
  DateTime loggedTime;
  Map<String, dynamic>? logInfo;

  Log({
    required this.id,
    required this.activityId,
    required this.activityType,
    required this.scheduledTime,
    required this.loggedTime,
    this.logInfo,
  });

  factory Log.fromDatabaseJson(Map<String, dynamic> data) {
    return Log(
      id: data['id'],
      activityId: data['activityId'],
      activityType: ActivityType.values.elementAt(data['activityType']),
      scheduledTime: DateTime.parse(data['scheduledTime']),
      loggedTime: DateTime.parse(data['loggedTime']),
      logInfo: jsonDecode(data['logInfo']),
    );
  }

  factory Log.fromDocument(Map<String, dynamic> document) {
    return Log(
      id: getDatabaseId(),
      activityId: document['activityId'],
      activityType: document['activityType'],
      scheduledTime: document['scheduledTime'],
      loggedTime: document['loggedTime'],
      logInfo: document['logInfo'],
    );
  }

  Map<String, dynamic> toDatabaseJson() {
    return {
      'id': id,
      'activityId': activityId,
      'activityType': activityType.index,
      'scheduledTime': scheduledTime.toIso8601String(),
      'loggedTime': loggedTime.toIso8601String(),
      'logInfo': logInfo != null ? jsonEncode(logInfo) : jsonEncode({}),
    };
  }

  @override
  String toString() {
    return toDatabaseJson().toString();
  }
}
