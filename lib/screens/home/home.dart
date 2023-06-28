import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';

import '../../logic/device.dart';
import '../../shared/settings.dart';
import '../about/about.dart';
import '../activities/activity_list.dart';
import '../alarms/alarm_list.dart';
import '../devices/device_list.dart';
import '../drugs/drug_list.dart';
import '../info/info_list.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> with TickerProviderStateMixin {
  final _tabData = <Map<String, dynamic>>[];
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _buildTabData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _buildTabData() {
    _tabData.clear();
    _tabData.add({
      'tab': FontAwesomeIcons.bell,
      'view': const AlarmList(),
    });
    _tabData.add({
      'tab': FontAwesomeIcons.capsules,
      'view': const DrugList(),
    });
    _tabData.add({
      'tab': FontAwesomeIcons.heartPulse,
      'view': const ActivityList(),
    });
    _tabData.add({
      'tab': FontAwesomeIcons.circleQuestion,
      'view': const InfoList(),
    });
    if (enableExperimentalFeatures) {
      _tabData.add({
        'tab': FontAwesomeIcons.briefcaseMedical,
        'view': const DeviceList(),
      });
    }
    _tabController = TabController(length: _tabData.length, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    final logic = context.watch<DeviceBloc>();
    return IgnorePointer(
      ignoring: logic.isProvisioning,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('SafeMed'),
          actions: <Widget>[
            TextButton(
              child: Text(
                'About',
                style: TextStyle(color: Theme.of(context).colorScheme.tertiary),
              ),
              onPressed: () async {
                final refresh = await Navigator.push(context,
                    MaterialPageRoute(builder: (context) => const About()));
                if (refresh) {
                  setState(() {
                    _buildTabData();
                  });
                }
              },
            )
          ],
          bottom: TabBar(
            indicatorColor: Theme.of(context).colorScheme.tertiary,
            controller: _tabController,
            tabs: List.generate(
              _tabData.length,
              (index) => Tab(
                child: FaIcon(
                  _tabData[index]['tab'],
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: List.generate(
              _tabData.length, (index) => _tabData[index]['view']),
        ),
      ),
    );
  }
}
