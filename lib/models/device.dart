import 'dart:convert';

class Device {
  String macAddress;
  String deviceName;
  String deviceType;
  Map<String, dynamic> deviceInfo;

  Device({
    required this.macAddress,
    required this.deviceName,
    required this.deviceType,
    required this.deviceInfo,
  });

  factory Device.fromDatabaseJson(Map<String, dynamic> data) {
    return Device(
      macAddress: data['macAddress'],
      deviceName: data['deviceName'],
      deviceType: data['deviceType'],
      deviceInfo: jsonDecode(data['deviceInfo']),
    );
  }

  Map<String, dynamic> toDatabaseJson() {
    return {
      'macAddress': macAddress,
      'deviceName': deviceName,
      'deviceType': deviceType,
      'deviceInfo': jsonEncode(deviceInfo),
    };
  }

  @override
  String toString() {
    return toDatabaseJson().toString();
  }

  //--------------------------------------------

  // factory Device.fromKeyValue(String key, Map value) {
  //   return Device(
  //     macAddress: key,
  //     deviceName: value['deviceName'],
  //     deviceType: value['deviceType'],
  //     deviceInfo: value['devicInfo'],
  //   );
  // }

  // Map<String, dynamic> toDocument() {
  //   return {
  //     'macAddress': macAddress,
  //     'deviceName': deviceName,
  //     'deviceType': deviceType,
  //     // 'company': company,
  //   };
  // }
}
