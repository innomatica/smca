import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../logic/activity.dart';
import '../../models/activity.dart';
import '../../models/schedule.dart';
import '../../shared/helpers.dart';

class ActivityAlarm extends StatefulWidget {
  final Activity activity;
  final Schedule schedule;
  const ActivityAlarm({
    required this.activity,
    required this.schedule,
    super.key,
  });

  @override
  State<ActivityAlarm> createState() => _ActivityAlarmState();
}

class _ActivityAlarmState extends State<ActivityAlarm> {
  final List<DropdownMenuItem<String>> _freqList = activityTimes.entries
      .map((entry) => DropdownMenuItem<String>(
            value: entry.key,
            child: Text(entry.key),
          ))
      .toList();

  late String _frequency;
  late List<DateTime> _alarmTimes;
  late DateTimeMatch _alarmMatch;

  @override
  void initState() {
    _frequency = widget.activity.frequency;
    _alarmTimes = [...widget.schedule.alarmTimes];
    _alarmMatch = widget.schedule.alarmMatch;
    super.initState();
  }

  String _getMwdText(index) {
    if (_alarmMatch == DateTimeMatch.time) {
      return 'Everyday';
    } else if (_alarmMatch == DateTimeMatch.dayOfWeekAndTime) {
      return weekdayNames[_alarmTimes[index].weekday];
    } else if (_alarmMatch == DateTimeMatch.dayOfMonthAndTime) {
      return 'Day ${_alarmTimes[index].day}';
    } else {
      return 'Every  ${_alarmTimes[index].month}th Month ${_alarmTimes[index].day}th Day';
    }
  }

  @override
  Widget build(BuildContext context) {
    final activityBloc = context.read<ActivityBloc>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Activity Alarm'),
      ),
      body: SizedBox.expand(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              const SizedBox(
                height: 20.0,
              ),
              LimitedBox(
                maxWidth: 360.0,
                child: Text(
                  widget.activity.activityName,
                  style: const TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                    overflow: TextOverflow.fade,
                  ),
                  maxLines: 3,
                ),
              ),
              const SizedBox(
                height: 10.0,
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(
                    width: 100.0,
                    child: Text('Frequency'),
                  ),
                  SizedBox(
                    width: 190.0,
                    child: DropdownButton<String>(
                      value: _frequency,
                      items: _freqList,
                      onChanged: (String? newValue) {
                        setState(() {
                          _frequency = newValue!;
                          _alarmMatch = activityTimes[_frequency]['timeMatch'];
                          _alarmTimes = activityTimes[_frequency]['timeStamps'];
                        });
                      },
                    ),
                  ),
                ],
              ),
              ListView.builder(
                shrinkWrap: true,
                physics: const ClampingScrollPhysics(),
                itemCount: _alarmTimes.length,
                itemBuilder: (context, index) {
                  return Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 100.0,
                        height: 48.0,
                        child: GestureDetector(
                          onTap: () async {
                            final now = DateTime.now();
                            DateTime? firstDate;
                            DateTime? initialDate;
                            DateTime? lastDate;
                            DateTime? selectedDate;

                            if (_alarmMatch == DateTimeMatch.time) {
                              return;
                            } else if (_alarmMatch ==
                                DateTimeMatch.dayOfWeekAndTime) {
                              // sunday
                              firstDate = now.add(Duration(days: -now.weekday));
                              // saturday
                              lastDate = firstDate.add(const Duration(days: 6));
                              initialDate = firstDate.add(
                                  Duration(days: _alarmTimes[index].weekday));
                            } else if (_alarmMatch ==
                                DateTimeMatch.dayOfMonthAndTime) {
                              // first day of the month
                              firstDate = now.add(Duration(days: 1 - now.day));
                              // at least last day of month
                              lastDate =
                                  firstDate.add(const Duration(days: 31));
                              initialDate = firstDate.add(
                                  Duration(days: _alarmTimes[index].day - 1));
                            }

                            selectedDate = await showDatePicker(
                              context: context,
                              initialDate: initialDate!,
                              firstDate: firstDate!,
                              lastDate: lastDate!,
                            );

                            if (selectedDate != null) {
                              setState(() {
                                _alarmTimes[index] = DateTime(
                                  selectedDate!.year,
                                  selectedDate.month,
                                  selectedDate.day,
                                  _alarmTimes[index].hour,
                                  _alarmTimes[index].minute,
                                );
                              });
                            }
                          },
                          child: Card(
                            child: Center(
                              child: Text(
                                _getMwdText(index),
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 190.0,
                        height: 48.0,
                        child: GestureDetector(
                          onTap: () async {
                            TimeOfDay? selectedTime = await showTimePicker(
                              context: context,
                              initialTime: TimeOfDay(
                                  hour: _alarmTimes[index].hour,
                                  minute: _alarmTimes[index].minute),
                            );
                            if (selectedTime != null) {
                              setState(() {
                                _alarmTimes[index] = DateTime(
                                  _alarmTimes[index].year,
                                  _alarmTimes[index].month,
                                  _alarmTimes[index].day,
                                  selectedTime.hour,
                                  selectedTime.minute,
                                );
                              });
                            }
                          },
                          child: Card(
                            child: Center(
                              child: Text(
                                _alarmTimes[index]
                                    .toIso8601String()
                                    .substring(11, 16),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(
                height: 20.0,
              ),
              SizedBox(
                width: 200.0,
                child: OutlinedButton(
                  onPressed: () async {
                    widget.schedule.alarmTimes = [..._alarmTimes];
                    widget.schedule.alarmMatch = _alarmMatch;
                    widget.activity.frequency = _frequency;
                    await activityBloc.update(widget.activity);
                    await activityBloc.addSchedule(widget.schedule);

                    if (!context.mounted) return;
                    Navigator.pop(context);
                  },
                  child: const Text('Update Alarm Settings'),
                ),
              ),
              const SizedBox(
                height: 10.0,
              ),
              SizedBox(
                width: 200.0,
                child: OutlinedButton(
                  onPressed: () async {
                    await activityBloc.deleteSchedule(widget.schedule);

                    if (!context.mounted) return;
                    Navigator.pop(context);
                  },
                  child: const Text('Cancel Alarms'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
