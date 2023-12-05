import 'package:community_charts_flutter/community_charts_flutter.dart'
    as charts;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../logic/activity.dart';
import '../../logic/log.dart';
import '../../models/activity.dart';
import '../../models/log.dart';
import '../../services/sqlite.dart';
import 'activity_chart.dart';

enum ViewType {
  listAll,
  listOneYear,
  listSixMonth,
  listOneMonth,
  listTwoWeeks,
  listOneWeek,
  chartAll,
  chartOneYear,
  chartSixMonth,
  chartOneMonth,
  chartTwoWeeks,
  chartOneWeek,
}

class ActivityDetails extends StatefulWidget {
  final Activity activity;
  const ActivityDetails({required this.activity, super.key});

  @override
  State<ActivityDetails> createState() => _ActivityDetailsState();
}

class _ActivityDetailsState extends State<ActivityDetails> {
  ViewType _viewType = ViewType.chartOneWeek;

  Future _createSampleData() async {
    final sqlite = SqliteService();
    await sqlite.addSampleLogs(
        widget.activity.activityType, widget.activity.id);
  }

  Widget _buildContent() {
    final logBloc = context.read<LogBloc>();
    final query = {
      'where': 'activityId = ?',
      'whereArgs': <dynamic>[widget.activity.id]
    };
    final today = DateTime(
      DateTime.now().year,
      DateTime.now().month,
      DateTime.now().day,
    );

    if (_viewType == ViewType.chartOneWeek) {
      query['where'] = '${query['where']} AND loggedTime > ? ';
      (query['whereArgs'] as List<dynamic>)
          .add(today.add(const Duration(days: -7)).toIso8601String());
    } else if (_viewType == ViewType.chartTwoWeeks) {
      query['where'] = '${query['where']} AND loggedTime > ? ';
      (query['whereArgs'] as List<dynamic>)
          .add(today.add(const Duration(days: -14)).toIso8601String());
    } else if (_viewType == ViewType.chartOneMonth) {
      query['where'] = '${query['where']} AND loggedTime > ? ';
      (query['whereArgs'] as List<dynamic>)
          .add(today.add(const Duration(days: -31)).toIso8601String());
    } else if (_viewType == ViewType.chartSixMonth) {
      query['where'] = '${query['where']} AND loggedTime > ? ';
      (query['whereArgs'] as List<dynamic>)
          .add(today.add(const Duration(days: -183)).toIso8601String());
    } else if (_viewType == ViewType.chartOneYear) {
      query['where'] = '${query['where']} AND loggedTime > ? ';
      (query['whereArgs'] as List<dynamic>)
          .add(today.add(const Duration(days: -365)).toIso8601String());
    } else if (_viewType == ViewType.listAll) {
      return FutureBuilder<List<Log>>(
        future: logBloc.getLogs(query: query),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final logs = snapshot.data!;
            final unit = activityData[widget.activity.activityType]['unit'];
            return ListView.builder(
              shrinkWrap: true,
              physics: const ClampingScrollPhysics(),
              itemCount: logs.length,
              itemBuilder: (context, index) => ListTile(
                leading: Text('${logs[index].loggedTime.year}'
                    '.${logs[index].loggedTime.month}'
                    '.${logs[index].loggedTime.day}'),
                title: Text(
                  '${logs[index].logInfo!['measurement']} $unit',
                  style:
                      TextStyle(color: Theme.of(context).colorScheme.secondary),
                ),
                subtitle: logs[index].logInfo != null &&
                        logs[index].logInfo!.containsKey('note')
                    ? Text(logs[index].logInfo!['note'].length > 30
                        ? logs[index].logInfo!['note'].substring(0, 30)
                        : logs[index].logInfo!['note'])
                    : const SizedBox(width: 0, height: 0),
              ),
            );
          } else {
            return const SizedBox(
              width: 0,
              height: 0,
            );
          }
        },
      );
    } else {
      return const SizedBox(width: 0, height: 0);
    }

    // all charts handled here
    return FutureBuilder<List<Log>>(
      future: logBloc.getLogs(query: query),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final data = snapshot.data!;
          // for (final item in data) {
          //   debugPrint('item: ${item.toString()}');
          // }
          final seriesList = [
            charts.Series<Log, DateTime>(
              id: widget.activity.activityName,
              colorFn: (_, __) => charts.MaterialPalette.blue.shadeDefault,
              domainFn: (Log log, _) => log.loggedTime,
              measureFn: (Log log, _) =>
                  double.parse(log.logInfo!['measurement'].split(',')[0]),
              data: data,
            )
          ];

          if (widget.activity.activityType ==
              ActivityType.measureBloodPressureLevel) {
            seriesList.add(charts.Series<Log, DateTime>(
              id: widget.activity.activityName,
              colorFn: (_, __) => charts.MaterialPalette.yellow.shadeDefault,
              domainFn: (Log log, _) => log.loggedTime,
              measureFn: (Log log, _) =>
                  (log.logInfo!['measurement'] as String).contains(',')
                      ? double.parse(log.logInfo!['measurement'].split(',')[1])
                      : 0,
              data: data,
            ));
          }

          return SizedBox(
            height: 400, // without hight restriction, it will break
            child: ActivityChart(
              seriesList,
              animate: true,
            ),
          );
        } else {
          return const SizedBox(width: 0, height: 0);
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final activityBloc = context.read<ActivityBloc>();
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.activity.activityName),
        actions: [
          TextButton.icon(
            onPressed: () async {
              activityBloc.delete(widget.activity);
              Navigator.pop(context);
            },
            icon:
                Icon(Icons.delete, color: Theme.of(context).colorScheme.error),
            label: Text(
              'Delete',
              style: TextStyle(
                  color: Theme.of(context).colorScheme.secondaryContainer),
            ),
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListView(
          children: [
            kReleaseMode
                ? const SizedBox(width: 0, height: 0)
                : TextButton(
                    child: const Text('create sample data'),
                    onPressed: () async {
                      await _createSampleData();
                    },
                  ),
            Center(
              child: DropdownButton<ViewType>(
                value: _viewType,
                underline: Container(color: const Color(0x00ffffff)),
                items: const [
                  DropdownMenuItem<ViewType>(
                    value: ViewType.chartOneWeek,
                    child: Text('Last Week'),
                  ),
                  DropdownMenuItem<ViewType>(
                    value: ViewType.chartOneMonth,
                    child: Text('Last Month'),
                  ),
                  DropdownMenuItem<ViewType>(
                    value: ViewType.chartSixMonth,
                    child: Text('Last 6 Months'),
                  ),
                  DropdownMenuItem<ViewType>(
                    value: ViewType.chartOneYear,
                    child: Text('Last Year'),
                  ),
                  DropdownMenuItem<ViewType>(
                    value: ViewType.listAll,
                    child: Text('All Records in List'),
                  ),
                ],
                onChanged: (value) {
                  setState(() {
                    _viewType = value ?? ViewType.chartOneWeek;
                  });
                },
              ),
            ),
            _buildContent(),
          ],
        ),
      ),
    );
  }
}
