import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../logic/drug.dart';
import '../../models/activity.dart';
import '../../models/drug.dart';
import '../../models/schedule.dart';
import '../../services/health_canada.dart';
import '../../shared/helpers.dart';
import 'drug_alarm.dart';
import 'drug_details.dart';

class DrugList extends StatefulWidget {
  const DrugList({super.key});

  @override
  State<DrugList> createState() => _DrugListState();
}

class _DrugListState extends State<DrugList> {
  final _formKey = GlobalKey<FormState>();

  //
  // Add Drug Bottomsheet
  //
  void _addDrug() async {
    String drugType = 'DIN';
    String drugNo = '';
    final drugBloc = context.read<DrugBloc>();

    await showModalBottomSheet<String?>(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          padding: EdgeInsets.only(
            top: 10.0,
            left: 10.0,
            bottom: MediaQuery.of(context).viewInsets.bottom + 10,
          ),
          // it is necessary to limit the height of the widget
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              StatefulBuilder(builder: (context, setState) {
                return Form(
                  key: _formKey,
                  child: Row(
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          if (drugType == 'DIN') {
                            drugType = 'NPN';
                          } else if (drugType == 'NPN') {
                            drugType = 'DIN-HM';
                          } else {
                            drugType = 'DIN';
                          }
                          setState(() {});
                        },
                        child: Text(drugType),
                      ),
                      const SizedBox(width: 12),
                      Flexible(
                        child: TextFormField(
                          decoration: const InputDecoration(
                            labelText: 'Select drug type then enter numbe',
                            hintText: '00012345',
                          ),
                          keyboardType: TextInputType.number,
                          // onChanged: (value) {
                          //   drugNo = value.toUpperCase();
                          // },
                          validator: (value) {
                            if (value != null) {
                              if (int.tryParse(value) == null) {
                                return 'Invalid number';
                              } else if (value.trim().length != 8) {
                                return 'Drug number should be 8 digit';
                              } else {
                                drugNo = value;
                                return null;
                              }
                            } else {
                              return 'Select drug type then enter number';
                            }
                          },
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.check),
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            Navigator.pop(context);
                          }
                        },
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
        );
      },
    );

    if (drugNo.isNotEmpty) {
      debugPrint('drugId: $drugNo');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            duration: Duration(seconds: 30),
            content: Text("connecting drug database...")),
      );

      final res = drugType == 'DIN'
          ? await DpdApiService.searchProducts({'din': drugNo})
          : await LnhpdApiService.searchProducts({'id': drugNo});

      debugPrint('res: ${res.toString()}');
      if (!mounted) return;
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      if (res == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("failed to connect database")),
        );
      } else if (res.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("no data found for the drug")),
        );
      } else {
        if (res.length > 1) {
          _showSelectDrugDialog(res, drugType);
        } else {
          drugType == 'DIN'
              ? drugBloc.add(Drug.fromDpdApi(res[0]))
              : drugBloc.add(Drug.fromLnhpdApi(res[0], drugType));
        }
      }
    }
  }

  //
  // Drug Selection Dialog
  //
  Future<void> _showSelectDrugDialog(
    List searchResults,
    String drugType,
  ) async {
    final drugBloc = context.read<DrugBloc>();
    await showDialog(
      context: context,
      builder: (context) {
        return SimpleDialog(
          title: const Text('Select your drug'),
          children: [
            SizedBox(
              height: 400,
              width: 400,
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: searchResults.length,
                itemBuilder: (context, index) {
                  return Card(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 8.0,
                      vertical: 4.0,
                    ),
                    color: const Color(0x60ffffff),
                    child: ListTile(
                      title: Text(
                        drugType == 'DIN'
                            ? searchResults[index]['brand_name']
                            : searchResults[index]['product_name'],
                      ),
                      subtitle: Text(
                        drugType == 'DIN'
                            ? searchResults[index]['drug_identification_number']
                            : searchResults[index]['licence_number'],
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                      ),
                      onTap: () {
                        drugType == 'DIN'
                            ? drugBloc
                                .add(Drug.fromDpdApi(searchResults[index]))
                            : drugBloc.add(Drug.fromLnhpdApi(
                                searchResults[index], drugType));
                        Navigator.pop(context);
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  //
  // generate default schedule
  //
  Schedule _getDefaultSchedule(Drug drug) {
    return Schedule(
      id: drug.id,
      activityId: drug.id,
      activityType: ActivityType.medication,
      scheduleInfo: {
        'drugId': drug.drugId,
        'drugName': drug.drugName,
        'alarmInterval': drugAlarmInterval[drug.frequency],
      },
      alarmTimes: standardRegimen[drug.frequency] ?? [],
      alarmMatch: DateTimeMatch.time,
    );
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
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Press ',
                style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.w500),
              ),
              Icon(
                Icons.add_circle,
                size: 26.0,
                color: Theme.of(context).colorScheme.secondary,
              ),
              const Text(
                '  and enter DIN, NPN, or DIN-HN',
                style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.w500),
              ),
            ],
          ),
          const SizedBox(height: 18.0),
          const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('    \u2731   '),
              Text('Tap on the drug name for details'),
            ],
          ),
          const SizedBox(height: 8.0),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('    \u2731   '),
              const Text('Set up an notification with '),
              Icon(
                Icons.alarm,
                size: 22.0,
                color: Theme.of(context).colorScheme.secondary,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Offset _tapOffset = Offset.zero;

  _onTapDown(TapDownDetails details) {
    _tapOffset = details.globalPosition;
  }

  //
  // Drug Card
  //
  Widget _buildDrugCard(Drug drug) {
    final drugBloc = context.read<DrugBloc>();
    // gesture detector is used to get the coordinate for the popup
    return GestureDetector(
      onTapDown: (TapDownDetails details) => _onTapDown(details),
      // onTap: () {},
      onLongPress: () {
        showMenu(
          color: const Color(0x40ffffff),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(8.0)),
          ),
          context: context,
          position: RelativeRect.fromLTRB(
              _tapOffset.dx, _tapOffset.dy, _tapOffset.dx, _tapOffset.dy),
          items: [
            PopupMenuItem(
              onTap: () => drugBloc.delete(drug),
              child: Row(
                children: [
                  Icon(
                    Icons.delete,
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                  const Text('  Delete'),
                ],
              ),
            ),
          ],
        );
      },
      child: Card(
        // elevation: 8.0,
        child: ListTile(
          leading: drug.getIcon(),
          title: Text(drug.drugName),
          subtitle: Text(drug.drugId),
          trailing: IconButton(
            icon: Icon(Icons.alarm,
                color: Theme.of(context).colorScheme.secondary),
            onPressed: () async {
              final schedule =
                  await drugBloc.getSchedule(drug) ?? _getDefaultSchedule(drug);

              if (!mounted) return;
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      DrugAlarm(drug: drug, schedule: schedule),
                ),
              );
            },
          ),
          onTap: () async {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => DrugDetails(drug: drug),
              ),
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final drugs = context.watch<DrugBloc>().drugs;

    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: drugs.isEmpty
              ? _buildInstruction()
              : ListView.builder(
                  itemCount: drugs.length,
                  itemBuilder: (context, index) => _buildDrugCard(drugs[index]),
                ),
        ),
        Positioned.fill(
          bottom: 16.0,
          child: Align(
            alignment: Alignment.bottomCenter,
            child: FloatingActionButton(
              onPressed: _addDrug,
              child: const Text(
                '+',
                style: TextStyle(fontWeight: FontWeight.w500, fontSize: 20.0),
              ),
            ),
          ),
        )
      ],
    );
  }
}
