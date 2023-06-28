import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../shared/settings.dart';

class Attribution extends StatelessWidget {
  const Attribution({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView(
      shrinkWrap: true,
      physics: const ClampingScrollPhysics(),
      children: [
        ListTile(
          title: Text(
            'App Icons',
            style: TextStyle(color: Theme.of(context).colorScheme.primary),
          ),
          subtitle: const Text("Medicine icons created by Freepik - Flaticon"),
          onTap: () {
            launchUrl(Uri.parse(urlMedicineIcons));
          },
        ),
        ListTile(
          title: Text(
            'Store Background Image',
            style: TextStyle(color: Theme.of(context).colorScheme.primary),
          ),
          subtitle: const Text("Image created by Anshu A - unsplash.com"),
          onTap: () {
            launchUrl(Uri.parse(urlBackgroundImage));
          },
        ),
      ],
    );
  }
}
