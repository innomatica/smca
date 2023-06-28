import 'dart:convert';

import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../shared/helpers.dart';

enum ActivityType {
  medication,
  measureBloodGlucoseLevel,
  measureBloodOxygenLevel,
  measureBloodPressureLevel,
  measureBodyTemperature,
  measureBodyWeight,
  exerciseWalking,
  exerciseHiking,
  exerciseSwimming,
  exerciseBicycling,
  activityOther,
}

List<ActivityType> measurementActivityTypes = [
  ActivityType.measureBloodGlucoseLevel,
  ActivityType.measureBloodOxygenLevel,
  ActivityType.measureBloodPressureLevel,
  ActivityType.measureBodyTemperature,
  ActivityType.measureBodyWeight,
];

List<ActivityType> exerciseActivityTypes = [
  ActivityType.exerciseWalking,
  ActivityType.exerciseHiking,
  ActivityType.exerciseSwimming,
  ActivityType.exerciseBicycling,
];

class Activity {
  int id;
  String activityName;
  ActivityType activityType;
  String frequency;
  Map<String, dynamic>? activityInfo;

  Activity({
    required this.id,
    required this.activityName,
    required this.activityType,
    required this.frequency,
    this.activityInfo,
  });

  factory Activity.fromDatabaseJson(Map<String, dynamic> data) {
    return Activity(
      id: data['id'],
      activityName: data['activityName'],
      activityType: ActivityType.values.elementAt(data['activityType']),
      frequency: data['frequency'],
      activityInfo: jsonDecode(data['activityInfo']),
    );
  }

  factory Activity.fromDocument(Map<String, dynamic> document) {
    return Activity(
      id: getDatabaseId(),
      activityName: document['activityName'],
      activityType: document['activityType'],
      frequency: document['frequency'],
      activityInfo: document['activityInfo'] ??
          activityData[document['activityType']]['info'],
    );
  }

  Map<String, dynamic> toDatabaseJson() {
    return {
      'id': id,
      'activityName': activityName,
      'activityType': activityType.index,
      'frequency': frequency,
      'activityInfo':
          activityInfo != null ? jsonEncode(activityInfo) : jsonEncode({}),
    };
  }

  @override
  String toString() {
    return toDatabaseJson().toString();
  }
}

Map<ActivityType, dynamic> activityData = {
  // ActivityType.medication: {
  //   'menu': 'Taking a medication',
  //   'notification': 'Time to take a medication',
  // 'icon': const FaIcon(FontAwesomeIcons.pills),
  // },
  ActivityType.measureBloodPressureLevel: {
    'menu': 'Measure Blood Pressure',
    'notification': 'Time to measure blood pressure',
    'icon': const FaIcon(FontAwesomeIcons.heartPulse),
    'unit': 'mmHg',
    'unitName': 'blood pressure(mmHg)',
    'hint': '120,80',
    'info': <String, dynamic>{
      'test': 'test data',
    },
  },
  ActivityType.measureBodyTemperature: {
    'menu': 'Measure Body Temperature',
    'notification': 'Time to measure body temperature',
    'icon': const FaIcon(FontAwesomeIcons.thermometer),
    'unit': '\u2103',
    'unitName': 'body temperature(\u2103)',
    'hint': '36.5',
    'info': <String, dynamic>{
      'test': 'test data',
    },
  },
  ActivityType.measureBodyWeight: {
    'menu': 'Measure Body Weight',
    'notification': 'Time to measure body weight',
    'icon': const FaIcon(FontAwesomeIcons.weightScale),
    'unit': 'Kg',
    'unitName': 'body weight(Kg)',
    'hint': '75.3',
    'info': <String, dynamic>{
      'test': 'test data',
    },
  },
  ActivityType.measureBloodGlucoseLevel: {
    'menu': 'Measure Blood Glucose Level',
    'notification': 'Time to measure blood glucose level',
    'icon': const FaIcon(FontAwesomeIcons.briefcaseMedical),
    'unit': 'mg/dl',
    'unitName': 'blood glucose level(mg/dl)',
    'hint': '100',
    'info': <String, dynamic>{
      'test': 'test data',
    },
  },
  ActivityType.exerciseWalking: {
    'menu': 'Taking a walk',
    'notification': 'Time to go out',
    'icon': const FaIcon(FontAwesomeIcons.personWalking),
    'uint': '',
    'unitName': '',
    'hint': '',
    'info': <String, dynamic>{
      'test': 'test data',
    },
  },
  ActivityType.exerciseHiking: {
    'menu': 'Hiking',
    'notification': 'Time to get to the mountain',
    'icon': const FaIcon(FontAwesomeIcons.personHiking),
    'uint': '',
    'unitName': '',
    'hint': '',
    'info': <String, dynamic>{
      'test': 'test data',
    },
  },
  ActivityType.exerciseSwimming: {
    'menu': 'Swimming',
    'notification': 'Time to get to the pool',
    'icon': const FaIcon(FontAwesomeIcons.personSwimming),
    'uint': '',
    'unitName': '',
    'hint': '',
    'info': <String, dynamic>{
      'test': 'test data',
    },
  },
  ActivityType.exerciseBicycling: {
    'menu': 'Bicycling',
    'notification': 'Time to ride a bicycle',
    'icon': const FaIcon(FontAwesomeIcons.personBiking),
    'uint': '',
    'unitName': '',
    'hint': '',
    'info': <String, dynamic>{
      'test': 'test data',
    },
  },
  ActivityType.activityOther: {
    'menu': 'Other Activity',
    'notification': 'Time to do something',
    'icon': const FaIcon(FontAwesomeIcons.personSkiingNordic),
    'uint': '',
    'unitName': '',
    'hint': '',
    'info': <String, dynamic>{
      'test': 'test data',
    },
  },
};

Map<String, dynamic> activityTimes = {
  'Once a Day': {
    'timeStamps': [
      DateTime(
          DateTime.now().year, DateTime.now().month, DateTime.now().day, 9),
    ],
    'timeMatch': DateTimeMatch.time,
  },
  'Twice a Day': {
    'timeStamps': [
      DateTime(
          DateTime.now().year, DateTime.now().month, DateTime.now().day, 9),
      DateTime(
          DateTime.now().year, DateTime.now().month, DateTime.now().day, 21),
    ],
    'timeMatch': DateTimeMatch.time,
  },
  '3 Times a Day': {
    'timeStamps': [
      DateTime(
          DateTime.now().year, DateTime.now().month, DateTime.now().day, 9),
      DateTime(
          DateTime.now().year, DateTime.now().month, DateTime.now().day, 14),
      DateTime(
          DateTime.now().year, DateTime.now().month, DateTime.now().day, 21),
    ],
    'timeMatch': DateTimeMatch.time,
  },
  'Once a Week': {
    'timeStamps': [
      DateTime(
        // monday
        DateTime.now().add(Duration(days: 1 - DateTime.now().weekday)).year,
        DateTime.now().add(Duration(days: 1 - DateTime.now().weekday)).month,
        DateTime.now().add(Duration(days: 1 - DateTime.now().weekday)).day,
        9,
      ),
    ],
    'timeMatch': DateTimeMatch.dayOfWeekAndTime,
  },
  'Twice a Week': {
    'timeStamps': [
      DateTime(
        // monday
        DateTime.now().add(Duration(days: 1 - DateTime.now().weekday)).year,
        DateTime.now().add(Duration(days: 1 - DateTime.now().weekday)).month,
        DateTime.now().add(Duration(days: 1 - DateTime.now().weekday)).day,
        9,
      ),
      DateTime(
        // thursday
        DateTime.now().add(Duration(days: 4 - DateTime.now().weekday)).year,
        DateTime.now().add(Duration(days: 4 - DateTime.now().weekday)).month,
        DateTime.now().add(Duration(days: 4 - DateTime.now().weekday)).day,
        9,
      ),
    ],
    'timeMatch': DateTimeMatch.dayOfWeekAndTime,
  },
  '3 Times a Week': {
    'timeStamps': [
      DateTime(
        // monday
        DateTime.now().add(Duration(days: 1 - DateTime.now().weekday)).year,
        DateTime.now().add(Duration(days: 1 - DateTime.now().weekday)).month,
        DateTime.now().add(Duration(days: 1 - DateTime.now().weekday)).day,
        9,
      ),
      DateTime(
        // wednesday
        DateTime.now().add(Duration(days: 3 - DateTime.now().weekday)).year,
        DateTime.now().add(Duration(days: 3 - DateTime.now().weekday)).month,
        DateTime.now().add(Duration(days: 3 - DateTime.now().weekday)).day,
        9,
      ),
      DateTime(
        // friday
        DateTime.now().add(Duration(days: 5 - DateTime.now().weekday)).year,
        DateTime.now().add(Duration(days: 5 - DateTime.now().weekday)).month,
        DateTime.now().add(Duration(days: 5 - DateTime.now().weekday)).day,
        9,
      ),
    ],
    'timeMatch': DateTimeMatch.dayOfWeekAndTime,
  },
  'Once a Month': {
    'timeStamps': [
      DateTime(DateTime.now().year, DateTime.now().month, 1, 9),
    ],
    'timeMatch': DateTimeMatch.dayOfMonthAndTime,
  },
  'Twice a Month': {
    'timeStamps': [
      DateTime(DateTime.now().year, DateTime.now().month, 1, 9),
      DateTime(DateTime.now().year, DateTime.now().month, 15, 9),
    ],
    'timeMatch': DateTimeMatch.dayOfMonthAndTime,
  },
  '3 Times a Month': {
    'timeStamps': [
      DateTime(DateTime.now().year, DateTime.now().month, 1, 9),
      DateTime(DateTime.now().year, DateTime.now().month, 11, 9),
      DateTime(DateTime.now().year, DateTime.now().month, 21, 9),
    ],
    'timeMatch': DateTimeMatch.dayOfMonthAndTime,
  },
};

Map<String, int> activityAlarmInterval = {
  'Once a Day': 24,
  'Twice a Day': 12,
  '3 Times a Day': 8,
  'Once a Week': 168,
  'Twice a Week': 84,
  '3 Times a Week': 56,
  'Once a Month': 720,
  'Twice a Month': 360,
  '3 Times a Month': 240,
};

List<String> weekdayNames = [
  'Sunday',
  'Monday',
  'Tuesday',
  'Wednesday',
  'Thursday',
  'Friday',
  'Saturday',
];
