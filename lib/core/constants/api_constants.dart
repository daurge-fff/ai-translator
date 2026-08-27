import 'dart:io';
import 'package:flutter/foundation.dart';

class ApiConstants {
  static const String _prodBaseUrl = 'https://translator.clearn.top';

  /// In release mode, use production server.
  /// In debug mode, use localhost (platform-specific).
  static String get baseUrl {
    if (kReleaseMode) return _prodBaseUrl;
    if (Platform.isAndroid) return 'http://10.0.2.2:3214';
    return 'http://127.0.0.1:3214';
  }

  static const String translateEndpoint = '/api/translate';
  static const String adminIncidentsEndpoint = '/api/admin/incidents';
  static const String adminConfigEndpoint = '/api/admin/config';
  static const String adminAccessControlEndpoint = '/api/admin/access-control';
  static const String adminBansEndpoint = '/api/admin/bans';
  static const String notificationsEndpoint = '/api/notifications';
}
