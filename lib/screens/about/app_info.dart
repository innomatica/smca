import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../shared/constants.dart';
import '../../shared/settings.dart';

class AppInfo extends StatefulWidget {
  const AppInfo({super.key});

  @override
  State<AppInfo> createState() => _AppInfoState();
}

class _AppInfoState extends State<AppInfo> {
  String? _getStoreUrl() {
    if (Platform.isAndroid) {
      return urlPlayStore;
    } else if (Platform.isIOS) {
      return urlAppStore;
    }
    return urlHomePage;
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      shrinkWrap: true,
      physics: const ClampingScrollPhysics(),
      children: [
        ListTile(
          title: Text('Version',
              style: TextStyle(color: Theme.of(context).colorScheme.primary)),
          subtitle: const Text(appVersion),
        ),
        ListTile(
          title: Text(
            'Visit Our App Store',
            style: TextStyle(color: Theme.of(context).colorScheme.primary),
          ),
          subtitle: const Text('Review App, Report Bugs, Share Your Thoughts'),
          onTap: () {
            final url = _getStoreUrl();
            if (url != null) {
              launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
            }
          },
        ),
        ListTile(
          title: Text(
            'Recommend to Others',
            style: TextStyle(color: Theme.of(context).colorScheme.primary),
          ),
          subtitle: const Text('Show QR Code'),
          onTap: () {
            showDialog(
              context: context,
              builder: (context) {
                return SimpleDialog(
                  title: Center(
                    child: Text(
                      'Visit our store',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Image.asset(playStoreUrlQrCode),
                    ),
                  ],
                );
              },
            );
          },
        ),
        ListTile(
          title: Text('About Us',
              style: TextStyle(color: Theme.of(context).colorScheme.primary)),
          subtitle: const Text(urlHomePage),
          onTap: () {
            launchUrl(Uri.parse(urlHomePage),
                mode: LaunchMode.externalApplication);
          },
        ),
        SwitchListTile(
          title: Text('Try experimental features',
              style: TextStyle(color: Theme.of(context).colorScheme.secondary)),
          subtitle: const Text('This feature requires '
              'compatible hardware'),
          value: enableExperimentalFeatures,
          onChanged: (bool value) {
            setState(() {
              enableExperimentalFeatures = value;
            });
          },
        ),
      ],
    );
  }
}
