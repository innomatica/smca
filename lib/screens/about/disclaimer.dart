import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../shared/settings.dart';

class Disclaimer extends StatelessWidget {
  const Disclaimer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView(
      shrinkWrap: true,
      physics: const ClampingScrollPhysics(),
      children: [
        ListTile(
          title: Text(
            'No Responsibility',
            style: TextStyle(color: Theme.of(context).colorScheme.primary),
          ),
          subtitle: const Text(" We do not guarantee the"
              " accuracy of the information or the functionality provided"
              " by this app. Please use it at your own risk."
              " (tap me for the full text)"),
          onTap: () {
            launchUrl(Uri.parse(urlDisclaimer));
          },
        ),
        const SizedBox(height: 12, width: 0),
      ],
    );
  }
}
