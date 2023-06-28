import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../logic/drug.dart';
import '../../models/drug.dart';
import '../../models/schedule.dart';

class DrugAlarm extends StatefulWidget {
  final Drug drug;
  final Schedule schedule;
  const DrugAlarm({
    Key? key,
    required this.drug,
    required this.schedule,
  }) : super(key: key);

  @override
  State<DrugAlarm> createState() => _DrugAlarmState();
}

class _DrugAlarmState extends State<DrugAlarm> {
  final List<DropdownMenuItem<String>> _freqList = standardRegimen.entries
      .map((entry) => DropdownMenuItem<String>(
            value: entry.key,
            child: Text(entry.key),
          ))
      .toList();

  late String _dose;
  late String _frequency;
  late List<DateTime> _alarmTimes;

  @override
  void initState() {
    _dose = widget.drug.dosageInfo['dose'] ?? '1 Dose';
    _frequency = widget.drug.frequency;
    // DONT _alarmTimes = widget.schedule.alarmTimes
    _alarmTimes = [...widget.schedule.alarmTimes];

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final drugBloc = context.read<DrugBloc>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Medication Alarm'),
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
                  widget.drug.drugName.split('(')[0],
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
                    child: Text('Dosage'),
                  ),
                  SizedBox(
                    width: 190.0,
                    child: TextFormField(
                      decoration:
                          const InputDecoration(hintText: '2 pills, 15ml, ...'),
                      initialValue: _dose,
                      onChanged: (value) {
                        setState(() {
                          _dose = value;
                        });
                      },
                    ),
                  ),
                ],
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
                          _alarmTimes = standardRegimen[_frequency]!;
                        });
                      },
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  const SizedBox(
                    width: 100.0,
                  ),
                  SizedBox(
                    width: 190.0,
                    child: ListView.builder(
                      shrinkWrap: true,
                      physics: const ClampingScrollPhysics(),
                      itemCount: _alarmTimes.length,
                      itemBuilder: (context, index) {
                        return SizedBox(
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
                                      DateTime.now().year,
                                      DateTime.now().month,
                                      DateTime.now().day,
                                      selectedTime.hour,
                                      selectedTime.minute);
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
                        );
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 20.0,
              ),
              SizedBox(
                width: 200.0,
                child: OutlinedButton(
                  onPressed: () async {
                    widget.drug.frequency = _frequency;
                    widget.drug.drugInfo['dose'] = _dose;
                    widget.schedule.alarmTimes = [..._alarmTimes];
                    widget.schedule.scheduleInfo['alarmInterval'] =
                        drugAlarmInterval[widget.drug.frequency];
                    await drugBloc.update(widget.drug);
                    await drugBloc.addSchedule(widget.schedule);

                    if (!mounted) return;
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
                    await drugBloc.deleteSchedule(widget.schedule);

                    if (!mounted) return;
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
