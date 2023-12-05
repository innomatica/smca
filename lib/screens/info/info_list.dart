import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../logic/drug.dart';
import '../../shared/settings.dart';

class InfoList extends StatefulWidget {
  const InfoList({super.key});

  @override
  State<InfoList> createState() => _InfoListState();
}

class _InfoListState extends State<InfoList> {
  Future<void> _launchDelegate(String target) async {
    double centerX = MediaQuery.of(context).size.width / 2;
    double centerY = MediaQuery.of(context).size.height / 2;
    final drugs = context.read<DrugBloc>().drugs;

    final items = <PopupMenuItem>[];
    for (final drug in drugs) {
      items.add(PopupMenuItem(
        child: Text(drug.drugName),
        onTap: () async {
          if (target == 'recall_alert') {
            await launchUrl(Uri.parse('$urlRecallsSafetyAlerts'
                '?search_api_fulltext= ${drug.drugId}'));
          } else if (target == 'adverse_reactions') {
            Clipboard.setData(ClipboardData(text: drug.drugName)).then((_) {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text('drug name copied to clipboard')));
            });
            await Future.delayed(const Duration(seconds: 2));
            await launchUrl(Uri.parse(urlAdverseReactionDatabaseDirect));
          } else if (target == 'side_effect') {
            Clipboard.setData(ClipboardData(text: drug.drugId)).then((_) {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text('drug DIN copied to clipboard')));
            });
            await Future.delayed(const Duration(seconds: 2));
            await launchUrl(Uri.parse(urlReportSideEffect));
          } else if (target == 'wikipedia') {
            Clipboard.setData(ClipboardData(text: drug.drugName)).then((_) {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text('drug name copied to clipboard')));
            });
            await Future.delayed(const Duration(seconds: 2));
            await launchUrl(Uri.parse(urlWikipedia));
          } else if (target == 'company') {
            if (drug.companyInfo.containsKey('customerServiceUrl')) {
              await launchUrl(Uri.parse(drug.companyInfo['url']));
            } else {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text('This feature is not ready yet')));
            }
          }
        },
      ));
    }

    if (items.isNotEmpty) {
      showMenu(
        context: context,
        position: RelativeRect.fromLTRB(
            centerX - 100, centerY - 100, centerX + 100, centerY + 100),
        initialValue: const PopupMenuItem(child: Text('initial item')),
        items: items,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(10.0))),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            leading: FaIcon(
              FontAwesomeIcons.circleExclamation,
              color: Theme.of(context).colorScheme.secondary,
            ),
            title: Text(
              'Search Recall and Safety Alert',
              style: TextStyle(
                fontSize: 16.0,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            onTap: () async {
              _launchDelegate('recall_alert');
            },
          ),
          ListTile(
            leading: FaIcon(
              FontAwesomeIcons.triangleExclamation,
              color: Theme.of(context).colorScheme.secondary,
            ),
            title: Text(
              'Search Adverse Reactions Database',
              style: TextStyle(
                fontSize: 16.0,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            onTap: () async {
              _launchDelegate('adverse_reactions');
            },
          ),
          ListTile(
            leading: FaIcon(
              FontAwesomeIcons.penToSquare,
              color: Theme.of(context).colorScheme.secondary,
            ),
            title: Text(
              'Report Side Effect',
              style: TextStyle(
                fontSize: 16.0,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            onTap: () async {
              _launchDelegate('side_effect');
            },
          ),
          ListTile(
            leading: FaIcon(
              FontAwesomeIcons.penToSquare,
              color: Theme.of(context).colorScheme.secondary,
            ),
            title: Text(
              'Report Illegal Marketing',
              style: TextStyle(
                fontSize: 16.0,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            onTap: () async {
              await launchUrl(Uri.parse(urlIllegalMarketing));
            },
          ),
          ListTile(
            leading: FaIcon(
              FontAwesomeIcons.wikipediaW,
              size: 20.0,
              color: Theme.of(context).colorScheme.secondary,
            ),
            title: Text(
              'Search Wikipedia',
              style: TextStyle(
                fontSize: 16.0,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            onTap: () async {
              _launchDelegate('wikipedia');
            },
          ),
          ListTile(
            leading: FaIcon(
              FontAwesomeIcons.building,
              color: Theme.of(context).colorScheme.secondary,
            ),
            title: Text(
              'Contact Company',
              style: TextStyle(
                fontSize: 16.0,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            onTap: () async {
              _launchDelegate('company');
            },
          ),
        ],
      ),
    );
  }
}
