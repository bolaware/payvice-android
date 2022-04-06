

import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:device_info/device_info.dart';
import 'package:payvice_app/services/cache.dart';

class DeviceInfo{

  final DeviceInfoPlugin _deviceInfoPlugin = DeviceInfoPlugin();
  final Cache _cache = Cache();

  Future<String> getDeviceInfo() async {
    final oldDeviceInfo = await _cache.getDeviceId();
    if(oldDeviceInfo == null) {
      print("fetching new");
      return getFreshDeviceInfo();
    } else {
      print("fetching old");
      return oldDeviceInfo;
    }
  }

  void setDeviceInfo() async {
    getDeviceInfo();
  }

  Future<String> getFreshDeviceInfo() async {
    String deviceId, name, os, osVersion, pushToken = "TO-BE-FILLED";
    //_printDebugInfo();
    if(Platform.isAndroid) {
      var deviceInfo =  await _deviceInfoPlugin.androidInfo;
      deviceId =
      "${deviceInfo.id}-"
          "${deviceInfo.androidId}-"
          "${deviceInfo.fingerprint}-"
          "${deviceInfo.display}";
      name = "${deviceInfo.manufacturer} ${deviceInfo.model}";
      os = "Android";
      osVersion = "${deviceInfo.version.release}";
    } else {
      var deviceInfo =  await _deviceInfoPlugin.iosInfo;
      deviceId = "${deviceInfo.identifierForVendor}";
      name = deviceInfo.name;
      os = "iOS";
      osVersion = deviceInfo.systemVersion;
    }

    String credentials = "$deviceId${getRandomString(14)}||$name||$os||$osVersion||$pushToken";
    Codec<String, String> stringToBase64 = utf8.fuse(base64);
    String encoded = stringToBase64.encode(credentials);
    //String decoded = stringToBase64.decode(encoded);
    await _cache.saveDeviceId(encoded);
    return encoded;
  }
  
  void _printDebugInfo() async {
    if(Platform.isAndroid) {
      var deviceInfo =  await _deviceInfoPlugin.androidInfo;
      
      var androidresult = <String, dynamic>{
        'version.securityPatch': deviceInfo.version.securityPatch,
        'version.sdkInt': deviceInfo.version.sdkInt,
        'version.release': deviceInfo.version.release,
        'version.previewSdkInt': deviceInfo.version.previewSdkInt,
        'version.incremental': deviceInfo.version.incremental,
        'version.codename': deviceInfo.version.codename,
        'version.baseOS': deviceInfo.version.baseOS,
        'board': deviceInfo.board,
        'bootloader': deviceInfo.bootloader,
        'brand': deviceInfo.brand,
        'device': deviceInfo.device,
        'display': deviceInfo.display,
        'fingerprint': deviceInfo.fingerprint,
        'hardware': deviceInfo.hardware,
        'host': deviceInfo.host,
        'id': deviceInfo.id,
        'manufacturer': deviceInfo.manufacturer,
        'model': deviceInfo.model,
        'product': deviceInfo.product,
        'supported32BitAbis': deviceInfo.supported32BitAbis,
        'supported64BitAbis': deviceInfo.supported64BitAbis,
        'supportedAbis': deviceInfo.supportedAbis,
        'tags': deviceInfo.tags,
        'type': deviceInfo.type,
        'isPhysicalDevice': deviceInfo.isPhysicalDevice,
        'androidId': deviceInfo.androidId,
        'systemFeatures': deviceInfo.systemFeatures,
      };
      print(androidresult);
    } else {
      var deviceInfo =  await _deviceInfoPlugin.iosInfo;

      var iosResult =  <String, dynamic>{
        'name': deviceInfo.name,
        'systemName': deviceInfo.systemName,
        'systemVersion': deviceInfo.systemVersion,
        'model': deviceInfo.model,
        'localizedModel': deviceInfo.localizedModel,
        'identifierForVendor': deviceInfo.identifierForVendor,
        'isPhysicalDevice': deviceInfo.isPhysicalDevice,
        'utsname.sysname:': deviceInfo.utsname.sysname,
        'utsname.nodename:': deviceInfo.utsname.nodename,
        'utsname.release:': deviceInfo.utsname.release,
        'utsname.version:': deviceInfo.utsname.version,
        'utsname.machine:': deviceInfo.utsname.machine,
      };
      print(iosResult);
    }
  }



  String _chars = 'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
  Random _rnd = Random();

  String getRandomString(int length) => String.fromCharCodes(Iterable.generate(
      length, (_) => _chars.codeUnitAt(_rnd.nextInt(_chars.length))));
}