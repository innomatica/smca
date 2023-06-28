import 'package:flutter/material.dart';

import 'app_info.dart';
import 'attribution.dart';
import 'disclaimer.dart';
import 'privacy.dart';
import 'sources.dart';

class About extends StatefulWidget {
  const About({Key? key}) : super(key: key);

  @override
  State<About> createState() => _AboutState();
}

class _AboutState extends State<About> {
  final List<bool> _expandedFlag = [
    false,
    false,
    false,
    false,
    false,
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.chevron_left),
          onPressed: () => Navigator.pop(context, true),
        ),
        title: const Text('About'),
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.symmetric(
            vertical: 10.0,
            horizontal: 10.0,
          ),
          child: ExpansionPanelList(
            expansionCallback: (int index, bool isExpanded) {
              setState(() {
                _expandedFlag[index] = !isExpanded;
              });
            },
            children: [
              ExpansionPanel(
                headerBuilder: (context, isExpanded) {
                  return const ListTile(title: Text('App Info'));
                },
                body: const AppInfo(),
                isExpanded: _expandedFlag[0],
                canTapOnHeader: true,
              ),
              ExpansionPanel(
                headerBuilder: (context, isExpanded) {
                  return const ListTile(title: Text('Attributions'));
                },
                body: const Attribution(),
                isExpanded: _expandedFlag[1],
                canTapOnHeader: true,
              ),
              ExpansionPanel(
                headerBuilder: (context, isExpanded) {
                  return const ListTile(title: Text('Disclaimer'));
                },
                body: const Disclaimer(),
                isExpanded: _expandedFlag[2],
                canTapOnHeader: true,
              ),
              ExpansionPanel(
                headerBuilder: (context, isExpanded) {
                  return const ListTile(title: Text('Information Sources'));
                },
                body: const SourceList(),
                isExpanded: _expandedFlag[3],
                canTapOnHeader: true,
              ),
              ExpansionPanel(
                headerBuilder: (context, isExpanded) {
                  return const ListTile(title: Text('Privacy Policy'));
                },
                body: const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Privacy(),
                ),
                isExpanded: _expandedFlag[4],
                canTapOnHeader: true,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
