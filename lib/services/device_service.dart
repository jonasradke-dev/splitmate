import 'package:device_info_plus/device_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';

class DeviceService {
  static Future<String> getDeviceId() async {
    final prefs = await SharedPreferences.getInstance();
    String? storedId = prefs.getString("device_id");

    if (storedId != null) return storedId;

    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    String newId;

    if (Platform.isAndroid) {
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      newId = androidInfo.id; // Unique Android ID
    } else if (Platform.isIOS) {
      IosDeviceInfo iosInfo = await deviceInfo.iosInfo;

      newId = iosInfo.identifierForVendor ?? 'unknown_device';
    } else {
      newId =
          DateTime.now().millisecondsSinceEpoch.toString(); // Generate for web
    }

    await prefs.setString("device_id", newId);
    print("Device ID: $newId");
    return newId;
  }
}
