import 'dart:async';

import 'package:esp_smartconfig/esp_smartconfig.dart';
import 'package:flutter/foundation.dart';

import '../models/device.dart';
import '../services/sqlite.dart';
import '../shared/settings.dart';

class DeviceBloc extends ChangeNotifier {
  final _db = SqliteService();
  bool _isProvisioning = false;
  List<Device> _devices = <Device>[];

  DeviceBloc() {
    refresh();
  }

  bool get isProvisioning => _isProvisioning;

  Future refresh() async {
    _devices = await _db.getDevices();
    notifyListeners();
  }

  List<Device> get devices {
    return _devices;
  }

  Future add(Device device) async {
    await _db.addDevice(device);
    refresh();
  }

  Future update(Device device) async {
    await _db.updateDevice(device);
    refresh();
  }

  Future delete(Device device) async {
    await _db.deleteDeviceByMacAddress(device.macAddress);
    refresh();
  }

  Future startProvisioning(String ssid, String bssid, String passwd,
      {int duration = provisionTimeoutSec}) async {
    final provisioner = Provisioner.espTouch();
    provisioner.listen(_onProvisionData,
        onError: _onProvisionError, onDone: _onProvisionDone);

    // start provision
    debugPrint('provisioner.start');
    await provisioner.start(ProvisioningRequest.fromStrings(
        ssid: ssid, bssid: bssid, password: passwd));
    _isProvisioning = true;
    notifyListeners();

    await Future.delayed(Duration(seconds: duration));

    // stop prvision
    debugPrint('provisioner.stop');
    provisioner.stop();
    _isProvisioning = false;
    notifyListeners();
  }

  void _onProvisionData(ProvisioningResponse res) async {
    debugPrint('_onProvisionData: $res');
    await add(Device(
      macAddress: res.bssidText,
      deviceName: 'Surx Device',
      deviceType: 'Secure Pill Dispenser',
      deviceInfo: {
        'ipAddr': res.ipAddressText,
      },
    ));
  }

  void _onProvisionError(e) {
    debugPrint('_onProvisionError: $e');
  }

  void _onProvisionDone() {
    debugPrint('_onProvisionDone');
  }
}
