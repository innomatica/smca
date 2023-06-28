import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../shared/settings.dart';

class SourceList extends StatelessWidget {
  const SourceList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView(
      shrinkWrap: true,
      physics: const ClampingScrollPhysics(),
      children: [
        ListTile(
          title: Text(
            'Health Canada',
            style: TextStyle(color: Theme.of(context).colorScheme.primary),
          ),
          subtitle: const Text('Drug Product Online Database\n'
              'Licenced Natural Health Product Database'),
          onTap: () async {
            await launchUrl(Uri.parse(urlDpdWeb));
          },
        ),
        ListTile(
          title: Text(
            'MedlinePlus Connect',
            style: TextStyle(color: Theme.of(context).colorScheme.primary),
          ),
          subtitle: const Text('MedlinePlus Drug Information\n'
              'National Cancer Institute\n'
              'National Institute of Health'),
          onTap: () async {
            await launchUrl(Uri.parse(urlMedlinePlus));
          },
        ),
      ],
    );
  }
}
