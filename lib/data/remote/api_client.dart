import 'package:dio/dio.dart';
import '../../core/constants/api_constants.dart';
import '../../core/device/device_id.dart';

class ApiClient {
  late final Dio _dio;

  ApiClient() {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 30),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer mock-token',
        },
      ),
    );

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final deviceId = await DeviceIdManager.getDeviceId();
          options.headers['x-device-id'] = deviceId;
          return handler.next(options);
        },
        onError: (DioException e, handler) {
          return handler.next(e);
        },
      ),
    );
  }

  Future<Map<String, dynamic>> translate({
    required String sourceText,
    required String sourceLang,
    required String targetLang,
    String? userContext,
    String? regionalVariant,
  }) async {
    final response = await _dio.post(
      ApiConstants.translateEndpoint,
      data: {
        'sourceText': sourceText,
        'sourceLang': sourceLang,
        'targetLang': targetLang,
        'userContext': userContext ?? '',
        'regionalVariant': regionalVariant ?? '',
      },
    );
    return response.data;
  }

  Future<List<dynamic>> fetchAdminIncidents() async {
    final response = await _dio.get(ApiConstants.adminIncidentsEndpoint);
    return response.data['incidents'] ?? [];
  }

  Future<List<Map<String, dynamic>>> fetchBans() async {
    final response = await _dio.get(ApiConstants.adminAccessControlEndpoint);
    final data = response.data;
    final List<Map<String, dynamic>> all = [];
    final users = data['bannedUsers'] ?? {};
    final devices = data['bannedDevices'] ?? {};
    final ips = data['bannedIPs'] ?? {};
    if (users is Map) users.forEach((k, v) => all.add({...Map<String, dynamic>.from(v), 'type': 'user'}));
    if (devices is Map) devices.forEach((k, v) => all.add({...Map<String, dynamic>.from(v), 'type': 'device'}));
    if (ips is Map) ips.forEach((k, v) => all.add({...Map<String, dynamic>.from(v), 'type': 'ip'}));
    return all;
  }

  Future<void> addBan(String value, String type, String reason, {String warningMessage = '', String? expiresAt}) async {
    await _dio.post(ApiConstants.adminBansEndpoint, data: {
      'value': value,
      'type': type,
      'reason': reason,
      'warningMessage': warningMessage,
      'expiresAt': expiresAt,
    });
  }

  Future<void> removeBan(String value, String type) async {
    await _dio.delete('${ApiConstants.adminBansEndpoint}/$type/$value');
  }
}
