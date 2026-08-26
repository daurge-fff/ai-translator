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
}
