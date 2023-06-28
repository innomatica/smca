import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'logic/activity.dart';
import 'logic/alarm.dart';
import 'logic/device.dart';
import 'logic/drug.dart';
import 'logic/log.dart';
import 'screens/home/home.dart';
import 'services/apptheme.dart';
import 'services/notification.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  NotificationService().init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<ActivityBloc>(create: (_) => ActivityBloc()),
        ChangeNotifierProvider<DrugBloc>(create: (_) => DrugBloc()),
        ChangeNotifierProxyProvider2<DrugBloc, ActivityBloc, AlarmBloc>(
          create: (_) => AlarmBloc(),
          update: (_, __, ___, bloc) {
            if (bloc == null) {
              return AlarmBloc();
            } else {
              return bloc..refresh();
            }
          },
        ),
        ChangeNotifierProvider<LogBloc>(create: (_) => LogBloc()),
        ChangeNotifierProvider<DeviceBloc>(create: (_) => DeviceBloc()),
      ],
      child: DynamicColorBuilder(
          builder: (ColorScheme? lightDynamic, ColorScheme? darkDynamic) {
        return MaterialApp(
          title: 'SafeMed',
          theme: AppTheme.lightTheme(lightDynamic),
          darkTheme: AppTheme.darkTheme(darkDynamic),
          home: const Home(),
          debugShowCheckedModeBanner: false,
        );
      }),
    );
  }
}
