import 'dart:io';

class ApiConstants {
  // Determine base URL dynamically based on platform
  static String get baseUrl {
    if (Platform.isAndroid) {
      return 'http://10.0.2.2:3000'; // Android emulator localhost alias
    }
    return 'http://127.0.0.1:3000'; // iOS Simulator & Desktop localhost
  }

  static const String translateEndpoint = '/api/translate';
  static const String adminIncidentsEndpoint = '/api/admin/incidents';
  static const String adminConfigEndpoint = '/api/admin/config';
  static const String adminAccessControlEndpoint = '/api/admin/access-control';
  static const String adminBansEndpoint = '/api/admin/bans';
}
