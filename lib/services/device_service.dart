import 'package:device_info_plus/device_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';

//获取设备唯一ID
class DeviceService {
  static String? _deviceId;

  static Future<String> getDeviceId() async {
    if (_deviceId != null) return _deviceId!;

    // 先从本地缓存读
    final prefs = await SharedPreferences.getInstance();
    final cached = prefs.getString('device_id');
    if (cached != null) { _deviceId = cached; return cached; }

    // 没有则获取设备 ID
    final info = DeviceInfoPlugin();
    String id;
    if (Platform.isAndroid) {
      final d = await info.androidInfo;
      id = d.id;
    } else if (Platform.isIOS) {
      final d = await info.iosInfo;
      id = d.identifierForVendor ?? DateTime.now().toString();
    } else {
      id = DateTime.now().millisecondsSinceEpoch.toString();
    }

    await prefs.setString('device_id', id);
    _deviceId = id;
    return id;
  }
}