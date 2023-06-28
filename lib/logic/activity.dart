import 'dart:async';

import 'package:flutter/foundation.dart';

import '../models/activity.dart';
import '../models/schedule.dart';
import '../services/notification.dart';
import '../services/sqlite.dart';
import '../shared/settings.dart';

class ActivityBloc extends ChangeNotifier {
  final _db = SqliteService();
  final _ns = NotificationService();

  List<Activity> _activities = <Activity>[];

  ActivityBloc() {
    refresh();
  }

  List<Activity> get activities {
    return _activities;
  }

  Future refresh() async {
    _activities = await _db.getActivities();
    notifyListeners();
  }

  //
  // Activity
  //
  Future add(Activity activity) async {
    await _db.addActivity(activity);
    refresh();
  }

  Future update(Activity activity) async {
    await _db.updateActivity(activity);
    refresh();
  }

  Future delete(Activity activity) async {
    final schedule = await getSchedule(activity);
    if (schedule != null) {
      await _ns.cancelScheduleNotifications(schedule);
    }
    await _db.deleteScheduleById(activity.id);
    await _db.deleteActivityById(activity.id);
    refresh();
  }

  Future<List<Activity>> getActivities() async {
    final activities = await _db.getActivities();
    return activities;
  }

  //
  // Schedule belongs to activities
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

  Future<Schedule?> getSchedule(Activity activity) async {
    final schedule = await _db.getScheduleById(activity.id);
    return schedule;
  }
}
