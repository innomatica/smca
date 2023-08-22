import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../shared/settings.dart';

class Privacy extends StatelessWidget {
  const Privacy({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView(
      shrinkWrap: true,
      physics: const ClampingScrollPhysics(),
      children: [
        ListTile(
          title: Text(
            'No Personal Data Collected',
            style: TextStyle(color: Theme.of(context).colorScheme.primary),
          ),
          subtitle: const Text('We do not collect any personal information.'
              ' Data you created during the usage remains in your device'
              ' all the time and will be removed when you uninstall this app.'
              ' (tap for the full text)'),
          onTap: () {
            launchUrl(Uri.parse(urlPrivacyPolicy));
          },
        ),
        const SizedBox(height: 12, width: 0),
      ],
    );
  }
}
