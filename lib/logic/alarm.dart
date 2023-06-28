import 'package:flutter/foundation.dart';

import '../models/schedule.dart';
import '../services/sqlite.dart';

class AlarmBloc extends ChangeNotifier {
  final _db = SqliteService();
  List<Alarm> _alarms = <Alarm>[];

  AlarmBloc() {
    refresh();
  }

  List<Alarm> get alarms {
    return _alarms;
  }

  Future refresh() async {
    _alarms = await _db.getAlarms();
    _alarms.sort((a, b) =>
        (a.alarmTime.hour * 60 + a.alarmTime.minute) -
        (b.alarmTime.hour * 60 + b.alarmTime.minute));
    notifyListeners();
  }
}
