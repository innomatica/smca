import 'package:flutter/material.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

import '../../logic/device.dart';
import '../../models/device.dart';

class DeviceList extends StatefulWidget {
  const DeviceList({super.key});

  @override
  State<DeviceList> createState() => _DeviceListState();
}

class _DeviceListState extends State<DeviceList> {
  final _pswController = TextEditingController();
  final info = NetworkInfo();
  String? ssid = '';
  String? bssid = '';

  @override
  void initState() {
    super.initState();
    _pswController.text = '';
  }

  @override
  void dispose() {
    _pswController.dispose();
    super.dispose();
  }

  //
  // Add New Device
  //
  void _addDevice() async {
    final logic = context.read<DeviceBloc>();
    final titleStyle = TextStyle(
        fontSize: 16.0,
        fontWeight: FontWeight.w500,
        color: Theme.of(context).colorScheme.primary);
    if (await Permission.locationWhenInUse.isGranted) {
      ssid = await info.getWifiName();
      bssid = await info.getWifiBSSID();
      // https://github.com/fluttercommunity/plus_plugins/issues/1326
      ssid = ssid?.replaceAll('"', '');
    }

    if (!mounted) return;

    if (ssid != null &&
        ssid!.isNotEmpty &&
        bssid != null &&
        bssid!.isNotEmpty) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(
            'Enter WiFi password to scan',
            style: titleStyle,
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                initialValue: ssid,
                readOnly: true,
                decoration: const InputDecoration(
                  labelText: 'Access Point (2.4GHz only)',
                ),
              ),
              TextFormField(
                autofocus: true,
                obscureText: true,
                controller: _pswController,
                decoration: InputDecoration(
                  labelText: 'Password',
                  suffixIcon: IconButton(
                    onPressed: () async {
                      Navigator.of(context).pop();
                      if (ssid != null &&
                          ssid!.isNotEmpty &&
                          bssid != null &&
                          bssid!.isNotEmpty &&
                          _pswController.text.isNotEmpty) {
                        await logic.startProvisioning(
                            ssid!, bssid!, _pswController.text);
                      }
                      // if (mounted) {
                      // }
                    },
                    icon: const Icon(Icons.check),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Permission not granted!')));
    }
  }

  //
  // Instruction
  //
  Widget _buildInstruction() {
    final logic = context.watch<DeviceBloc>();
    const textStyle = TextStyle(fontWeight: FontWeight.w500, fontSize: 16.0);

    return FutureBuilder<bool>(
      future: Permission.locationWhenInUse.request().isGranted,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          if (snapshot.data!) {
            return Center(
              child: logic.isProvisioning
                  ? const Text('Searching device(s)', style: textStyle)
                  : const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('1. Power on the device', style: textStyle),
                        Text('2. Wait until the LED is blinking,',
                            style: textStyle),
                        Text('3. Tap + button and Enter WiFi credential',
                            style: textStyle),
                      ],
                    ),
            );
          } else {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Permission is denied', style: textStyle),
                  const SizedBox(height: 16.0),
                  OutlinedButton(
                    onPressed: () => openAppSettings(),
                    child: const Text('Open App Settings '),
                  ),
                  const SizedBox(height: 16.0),
                  const Text('And allow Location permission manully',
                      style: textStyle),
                ],
              ),
            );
          }
        }
        return const Center(
          child: SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(),
          ),
        );
      },
    );
  }

  //
  // Device Tile
  //
  Widget _buildDeviceTile(Device device) {
    final logic = context.read<DeviceBloc>();
    return Card(
      child: ListTile(
        title: Text(device.deviceName),
        subtitle: Text(device.macAddress),
        trailing: IconButton(
          icon: Icon(
            Icons.delete,
            color: Theme.of(context).colorScheme.error,
          ),
          onPressed: () {
            logic.delete(device);
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final logic = context.watch<DeviceBloc>();
    final devices = logic.devices;

    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: devices.isEmpty
              ? _buildInstruction()
              : ListView.builder(
                  itemCount: devices.length,
                  itemBuilder: (context, index) =>
                      _buildDeviceTile(devices[index]),
                ),
        ),
        logic.isProvisioning
            ? const Center(
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(),
                ),
              )
            : Container(),
        Positioned.fill(
          bottom: 16.0,
          child: Align(
            alignment: Alignment.bottomCenter,
            child: FloatingActionButton(
              onPressed: _addDevice,
              child: const Text(
                '+',
                style: TextStyle(fontWeight: FontWeight.w500, fontSize: 20.0),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
