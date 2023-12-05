import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../../logic/alarm.dart';
import '../../logic/log.dart';
import '../../models/activity.dart';
import '../../models/log.dart';
import '../../models/schedule.dart';
import '../../shared/constants.dart';

class AlarmList extends StatefulWidget {
  const AlarmList({super.key});

  @override
  State<AlarmList> createState() => _AlarmListState();
}

class _AlarmListState extends State<AlarmList> with WidgetsBindingObserver {
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    // update screen when resumed
    if (state == AppLifecycleState.resumed) {
      // debugPrint('reminder:Current state = $state');
      setState(() {});
    }
  }

  //
  // Instruction
  //
  Widget _buildInstruction() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Text(
            'You have no alarm schedule.  Go to',
            style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 18.0),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // const Text('    \u2731   '),
              FaIcon(
                FontAwesomeIcons.capsules,
                size: 22.0,
                color: Theme.of(context).colorScheme.secondary,
              ),
              const Text('  page for medication alarms'),
            ],
          ),
          const SizedBox(height: 8.0),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // const Text('    \u2731   '),
              FaIcon(
                FontAwesomeIcons.heartPulse,
                size: 22.0,
                color: Theme.of(context).colorScheme.secondary,
              ),
              const Text('  page for activity alarms'),
            ],
          ),
        ],
      ),
    );
  }

  //
  // Create Log
  //
  Future _createLog(Alarm alarm) async {
    final logBloc = context.read<LogBloc>();
    final now = DateTime.now();
    String? measurementValue;
    String? measurementNote;
    var logInfo = {'message': 'checked at ${now.hour}:${now.minute}'};

    if (measurementActivityTypes.contains(alarm.activityType)) {
      // show modal bottom sheet when masurement activity is checked
      await showModalBottomSheet(
        isScrollControlled: true,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
        context: context,
        builder: (context) {
          return StatefulBuilder(builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                top: 10.0,
                left: 40.0,
                right: 40.0,
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      onChanged: (value) {
                        measurementValue = value;
                      },
                      decoration: InputDecoration(
                        label:
                            Text(activityData[alarm.activityType]['unitName']),
                        hintText: activityData[alarm.activityType]['hint'],
                      ),
                      validator: (String? value) {
                        if (value != null) {
                          if (alarm.activityType ==
                              ActivityType.measureBloodPressureLevel) {
                            // blood presure measurement comes as x,y format
                            if (value.contains(',')) {
                              if (double.tryParse(value.split(',')[0]) ==
                                  null) {
                                // first number is invalid
                                return 'invalid number';
                              } else {
                                if (double.tryParse(value.split(',')[1]) ==
                                    null) {
                                  // second number is invalid
                                  return 'invalid number';
                                }
                              }
                            } else {
                              // must have two values separated by a comma
                              return 'enter two numbers in 120, 80 fasion';
                            }
                          } else {
                            // other measurements are just numbers
                            if (double.tryParse(value) == null) {
                              return 'invalid number';
                            }
                          }
                        }
                        return null;
                      },
                      keyboardType: TextInputType.number,
                    ),
                    TextFormField(
                      onChanged: (value) {
                        measurementNote = value;
                      },
                      decoration: const InputDecoration(
                        label: Text('Note'),
                        hintText: 'write down anything to remember',
                      ),
                      keyboardType: TextInputType.text,
                      maxLines: 2,
                    ),
                    const SizedBox(height: 10.0),
                    SizedBox(
                      width: 200.0,
                      child: OutlinedButton(
                        onPressed: () async {
                          if (_formKey.currentState!.validate()) {
                            logInfo['measurement'] = measurementValue ?? '';
                            logInfo['note'] = measurementNote ?? '';
                            await logBloc.add(
                              Log.fromDocument({
                                'activityId': alarm.activityId,
                                'activityType': alarm.activityType,
                                'scheduledTime': DateTime(
                                  now.year,
                                  now.month,
                                  now.day,
                                  alarm.alarmTime.hour,
                                  alarm.alarmTime.minute,
                                ),
                                'loggedTime': now,
                                'logInfo': logInfo,
                              }),
                            );
                            measurementValue = null;
                            measurementNote == null;

                            if (!mounted) return;
                            Navigator.pop(context);
                          } else {
                            debugPrint('failed to validate');
                          }
                        },
                        child: const Text('Confirm'),
                      ),
                    ),
                    const SizedBox(height: 20.0),
                  ],
                ),
              ),
            );
          });
        },
      );
    } else {
      // simple activity requires no data to enter
      await logBloc.add(
        Log.fromDocument({
          'activityId': alarm.activityId,
          'activityType': alarm.activityType,
          'scheduledTime': DateTime(
            now.year,
            now.month,
            now.day,
            alarm.alarmTime.hour,
            alarm.alarmTime.minute,
          ),
          'loggedTime': now,
          'logInfo': logInfo,
        }),
      );
    }
  }

  //
  // Alarm List Tile
  //
  Widget _buildAlarmCard(Alarm alarm, List<Log> logs) {
    final currentTime = DateTime.now();
    final alarmTime = DateTime(
      currentTime.year,
      currentTime.month,
      currentTime.day,
      alarm.alarmTime.hour,
      alarm.alarmTime.minute,
    );
    // time to/after alarm
    final alarmDistance = alarmTime.hour * 60 +
        alarmTime.minute -
        currentTime.hour * 60 -
        currentTime.minute;
    // in the alarm zone
    final inTheZone = (alarmDistance).abs() < 30;
    // alarm is checked
    bool checked = false;
    // with message
    String logMessage = '';
    // go over the logs to check
    for (final log in logs) {
      if ((log.activityId == alarm.activityId) &&
          (log.scheduledTime.hour == alarmTime.hour) &&
          (log.scheduledTime.minute == alarmTime.minute)) {
        checked = true;
        logMessage = log.logInfo!['message'];
        break;
      }
    }

    // subtitle shows log message if checked otherwise time difference
    String subTitle =
        checked ? logMessage : timeago.format(alarmTime, allowFromNow: true);
    // leading color
    Color leadingColor = checked
        ? colorNotInTheZone
        : inTheZone
            ? Theme.of(context).colorScheme.primary
            : colorNotInTheZone;
    // trailing button
    Widget? trailingButton = checked || !inTheZone
        ? null
        : IconButton(
            icon: Icon(
              Icons.done,
              color: Theme.of(context).colorScheme.tertiary,
            ),
            onPressed: () async {
              await _createLog(alarm);
              setState(() {});
            },
          );

    return Card(
      elevation: inTheZone ? 8.0 : 1.0,
      child: ListTile(
        // time
        leading: Text(
          alarmTime
              .toIso8601String()
              .split('T')[1]
              .split('.')[0]
              .substring(0, 5),
          style: TextStyle(
            fontSize: 18.0,
            fontWeight: FontWeight.bold,
            color: leadingColor,
          ),
        ),
        // drug name
        title: Text(
          alarm.activityType == ActivityType.medication
              ? alarm.alarmInfo['drugName'].split('(')[0]
              : alarm.alarmInfo['activityName'],
          style: TextStyle(
            fontWeight: inTheZone ? FontWeight.w700 : FontWeight.w400,
          ),
        ),
        // subtitle
        subtitle: Text(
          subTitle,
          style: TextStyle(color: Theme.of(context).colorScheme.secondary),
        ),
        trailing: trailingButton,
        // long press override the alarm zone condition as long as it is
        // either overdue alarm (negative alarmDistance) or
        // future alarm but less than half way to the next alarm
        onLongPress: () async {
          if (alarm.alarmInfo.keys.contains('alarmInterval') &&
              alarmDistance < alarm.alarmInfo['alarmInterval'] * 30) {
            // you are allowed to check even if it is out of the zone
            showDialog(
              context: context,
              builder: (context) {
                return SimpleDialog(
                  title: const Center(
                    child: Text(
                      'Check this alarm now?',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  backgroundColor: const Color.fromRGBO(0xff, 0xff, 0xff, 0.2),
                  children: [
                    TextButton(
                      onPressed: () async {
                        await _createLog(alarm);
                        setState(() {});
                        if (!mounted) return;
                        Navigator.pop(context);
                      },
                      child: Text(
                        'YES',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.error),
                      ),
                    ),
                  ],
                );
              },
            );
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final alarms = context.watch<AlarmBloc>().alarms;
    final logs = context.watch<LogBloc>().logs;

    return alarms.isNotEmpty
        ? Padding(
            padding: const EdgeInsets.all(8.0),
            child: RefreshIndicator(
              onRefresh: () async {
                setState(() {});
              },
              child: ListView.builder(
                itemCount: alarms.length,
                itemBuilder: (context, index) =>
                    _buildAlarmCard(alarms[index], logs),
              ),
            ),
          )
        : _buildInstruction();
  }
}
