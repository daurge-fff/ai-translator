import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:uuid/uuid.dart';

class DeviceIdManager {
  static const _storage = FlutterSecureStorage();
  static const _key = 'user_device_uuid_key';

  static Future<String> getDeviceId() async {
    try {
      String? existingId = await _storage.read(key: _key);
      if (existingId != null && existingId.isNotEmpty) {
        return existingId;
      }
    } catch (_) {}

    String newId = const Uuid().v4();
    try {
      await _storage.write(key: _key, value: newId);
    } catch (_) {}
    return newId;
  }
}
