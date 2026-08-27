import 'dart:io';
import 'package:flutter/foundation.dart';

class ApiConstants {
  static const String _prodBaseUrl = 'https://translator.clearn.top';

  static String get baseUrl {
    if (kReleaseMode) return _prodBaseUrl;
    if (Platform.isIOS) return _prodBaseUrl; // physical iPhone → production
    if (Platform.isAndroid) return 'http://10.0.2.2:3214';
    return 'http://127.0.0.1:3214';
  }

  static const String translateEndpoint = '/api/translate';
  static const String configEndpoint = '/api/config';
  static const String adminIncidentsEndpoint = '/api/admin/incidents';
  static const String adminAccessControlEndpoint = '/api/admin/access-control';
  static const String adminBansEndpoint = '/api/admin/bans';
  static const String notificationsEndpoint = '/api/notifications';
  static const String notificationsAllEndpoint = '/api/notifications/all';
  static const String notificationsSendEndpoint = '/api/notifications/send';
  static const String banStatusEndpoint = '/api/ban/status';
}
