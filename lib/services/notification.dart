import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import '../models/activity.dart';
import '../models/schedule.dart';
import '../shared/helpers.dart';
import '../shared/settings.dart';

class NotificationService {
  // singleton class
  NotificationService._internal();
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() {
    return _instance;
  }

  // plugin instance
  final FlutterLocalNotificationsPlugin _notification =
      FlutterLocalNotificationsPlugin();

  // initialization required before use
  Future init() async {
    // be sure to have notification icon(s) in /res/drawable_...
    await _notification.initialize(
      const InitializationSettings(
          android: AndroidInitializationSettings('app_icon')),
      onDidReceiveNotificationResponse: _onDidReceive,
      onDidReceiveBackgroundNotificationResponse: _onDidReceiveBackground,
    );

    // initialize timezone database
    tz.initializeTimeZones();
    // get current timezone name
    final String currentTimeZone = await FlutterTimezone.getLocalTimezone();
    // set my location in the database
    tz.setLocalLocation(tz.getLocation(currentTimeZone));
  }

  // callback during foreground
  void _onDidReceive(NotificationResponse response) async {
    final String? payload = response.payload;
    if (response.payload != null) {
      debugPrint('onDidReceive payload: $payload');
    }
    // https://stackoverflow.com/questions/54137420/flutter-local-notification-plugin-navigate-to-specific-screen-when-the-user-ta
    // await Navigator.push(
    //   context,
    //   MaterialPageRoute<void>(builder: (context) => SecondScreen(payload)),
    // );
  }

  // callback during background
  static void _onDidReceiveBackground(NotificationResponse response) {
    final String? payload = response.payload;
    if (response.payload != null) {
      debugPrint('onDidReceiveBackground payload: $payload');
    }
  }

  String _getNotificationString(Schedule schedule) {
    if (schedule.activityType == ActivityType.medication) {
      return 'Medication Alarm';
    } else {
      return 'SafeMed Alarm';
    }
  }

  String _getNotificationBody(Schedule schedule) {
    if (schedule.activityType == ActivityType.medication) {
      return schedule.scheduleInfo['drugName'].split('(')[0];
    } else {
      return activityData[schedule.activityType]['notification'];
    }
  }

  String _getNotificationPayload(Schedule schedule) {
    // if (schedule.activityType == ActivityType.medication) {
    //   return schedule.scheduleInfo['drugId'];
    // }
    return schedule.activityId.toString();
  }

  DateTimeComponents _getDateTimeMatch(Schedule schedule) {
    if (schedule.alarmMatch == DateTimeMatch.dayOfWeekAndTime) {
      return DateTimeComponents.dayOfWeekAndTime;
    } else if (schedule.alarmMatch == DateTimeMatch.dayOfMonthAndTime) {
      return DateTimeComponents.dayOfMonthAndTime;
    } else if (schedule.alarmMatch == DateTimeMatch.dateAndTime) {
      return DateTimeComponents.dateAndTime;
    } else {
      return DateTimeComponents.time;
    }
  }

  // schedule plain alarms: sound may be disabled by default
  // TODO: when notification touched, show alarm list page
  Future<bool> scheduleNotifications(Schedule schedule) async {
    // this is not necessary since we are going to update existing one
    // await cancelNotifications(schedule);
    // create a new set of notifications from the schedule
    const platformChannelSpecifics = NotificationDetails(
      android: AndroidNotificationDetails(
        notificationChannelId,
        notificationChannelName,
        channelDescription: notificationChannelDescription,
        importance: Importance.max,
        priority: Priority.high,
        sound: RawResourceAndroidNotificationSound('med_alarm'),
        playSound: true,
        enableVibration: true,
        enableLights: true,
        ticker: 'ticker',
      ),
    );

    for (var index = 0; index < schedule.alarmTimes.length; index++) {
      await _notification.zonedSchedule(
        schedule.getAlarmId(index),
        _getNotificationString(schedule),
        _getNotificationBody(schedule),
        tz.TZDateTime.from(schedule.alarmTimes[index], tz.local),
        platformChannelSpecifics,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        matchDateTimeComponents: _getDateTimeMatch(schedule),
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        payload: _getNotificationPayload(schedule),
      );
    }
    return true;
  }

  // schedule inbox style alarms: sound enabled by default
  Future<bool> scheduleInboxNotifications(Schedule schedule) async {
    // this is not necessary since we are going to update existing one
    // await cancelNotifications(schedule);
    // create new notifications from the schedule
    for (var index = 0; index < schedule.alarmTimes.length; index++) {
      final platformChannelSpecifics = NotificationDetails(
        android: AndroidNotificationDetails(
          notificationChannelId,
          notificationChannelName,
          channelDescription: notificationChannelDescription,
          importance: Importance.max,
          priority: Priority.high,
          playSound: true,
          sound: const RawResourceAndroidNotificationSound('med_alarm'),
          enableVibration: true,
          enableLights: true,
          styleInformation: InboxStyleInformation(
            [_getNotificationBody(schedule)],
            htmlFormatLines: true,
            contentTitle: '<b>${_getNotificationString(schedule)}</b>',
            htmlFormatContentTitle: true,
            summaryText: 'alarm',
            htmlFormatSummaryText: true,
          ),
        ),
      );

      // debugPrint('zonedSchedule:${schedule.alarmTimes}');
      await _notification.zonedSchedule(
        // construct notificationId by adding index as leading digits
        schedule.getAlarmId(index),
        _getNotificationString(schedule),
        _getNotificationBody(schedule),
        tz.TZDateTime.from(schedule.alarmTimes[index], tz.local),
        platformChannelSpecifics,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        // androidAllowWhileIdle: true,
        matchDateTimeComponents: _getDateTimeMatch(schedule),
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        payload: _getNotificationPayload(schedule),
      );
    }
    return true;
  }

  // cancel all notifications for the schedule
  Future<bool> cancelScheduleNotifications(Schedule schedule) async {
    // get pending notifications
    final List<PendingNotificationRequest> pendingNotificationRequests =
        await _notification.pendingNotificationRequests();
    for (final pnr in pendingNotificationRequests) {
      if (schedule.getAlarmIdList().contains(pnr.id)) {
        await _notification.cancel(pnr.id);
      }
    }
    return true;
  }

  // cancel notification for the particular alarm
  Future<bool> cancelAlarmNotification(Alarm alarm) async {
    // get pending notifications
    final List<PendingNotificationRequest> pendingNotificationRequests =
        await _notification.pendingNotificationRequests();
    for (final pnr in pendingNotificationRequests) {
      if (alarm.id == pnr.id) {
        await _notification.cancel(pnr.id);
      }
    }
    return true;
  }

  // plain notification: sound might not be enabled by default
  Future<bool> showNotification({
    int notificationId = 0,
    String title = 'Tylenol',
    String body = 'take 2 pills',
    String? payload,
  }) async {
    const platformChannelSpecifics = NotificationDetails(
      android: AndroidNotificationDetails(
        notificationChannelId,
        notificationChannelName,
        channelDescription: notificationChannelDescription,
        importance: Importance.max,
        priority: Priority.high,
        playSound: true,
        enableVibration: true,
        enableLights: true,
        ticker: 'ticker',
      ),
    );

    await _notification.show(
      notificationId,
      title,
      body,
      platformChannelSpecifics,
      payload: payload,
    );
    return true;
  }

  // Inbox style notification: sound enabled by default
  Future<bool> showInboxNotification({
    int notificationId = 0,
    String summary = 'alarm',
    String title = 'Tylenol',
    List<String> content = const ['take 2 pills'],
    String? payload,
  }) async {
    final platformChannelSpecifics = NotificationDetails(
      android: AndroidNotificationDetails(
        notificationChannelId,
        notificationChannelName,
        channelDescription: notificationChannelDescription,
        importance: Importance.max,
        priority: Priority.high,
        playSound: true,
        sound: const RawResourceAndroidNotificationSound('med_alarm'),
        enableVibration: true,
        enableLights: true,
        styleInformation: InboxStyleInformation(
          content,
          htmlFormatLines: true,
          contentTitle: '<b>$title</b',
          htmlFormatContentTitle: true,
          summaryText: summary,
          htmlFormatSummaryText: true,
        ),
      ),
    );

    await _notification.show(
      notificationId,
      title,
      content[0],
      platformChannelSpecifics,
      payload: payload,
    );
    return true;
  }
}
