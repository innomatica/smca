import 'dart:async';

import 'package:flutter/foundation.dart';

import '../models/log.dart';
import '../services/sqlite.dart';

class LogBloc extends ChangeNotifier {
  final _db = SqliteService();
  List<Log> _logs = <Log>[];

  LogBloc() {
    refresh();
  }

  List<Log> get logs {
    return _logs;
  }

  Future refresh() async {
    final today =
        DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
    _logs = await _db.getLogs(
      query: {
        'where': 'loggedTime > ?',
        'whereArgs': [today.toIso8601String()],
      },
    );
    notifyListeners();
  }

  Future add(Log log) async {
    await _db.addLog(log);
    refresh();
  }

  Future<List<Log>> getLogs({Map<String, dynamic>? query}) async {
    final logs = await _db.getLogs(query: query);
    return logs;
  }
}
