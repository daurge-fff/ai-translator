import 'package:dio/dio.dart';
import '../../core/constants/api_constants.dart';

class AppNotification {
  final String id;
  final String title;
  final String body;
  final String? targetEmail;
  final String createdAt;
  final bool isRead;

  AppNotification({
    required this.id,
    required this.title,
    required this.body,
    this.targetEmail,
    required this.createdAt,
    this.isRead = false,
  });

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      body: json['body'] ?? '',
      targetEmail: json['targetEmail'],
      createdAt: json['createdAt'] ?? '',
      isRead: json['isRead'] ?? false,
    );
  }
}

class NotificationService {
  final Dio _dio;

  NotificationService() : _dio = Dio(BaseOptions(
    baseUrl: ApiConstants.baseUrl,
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 15),
    headers: {'Content-Type': 'application/json'},
  ));

  void setToken(String? token) {
    if (token != null) {
      _dio.options.headers['Authorization'] = 'Bearer $token';
    }
  }

  void setDeviceId(String deviceId) {
    _dio.options.headers['x-device-id'] = deviceId;
  }

  Future<List<AppNotification>> getNotifications() async {
    try {
      final response = await _dio.get(ApiConstants.notificationsEndpoint);
      final data = response.data['notifications'] as List? ?? [];
      return data.map((e) => AppNotification.fromJson(e as Map<String, dynamic>)).toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> markAsRead(String id) async {
    try {
      await _dio.post('${ApiConstants.notificationsEndpoint}/$id/read');
    } catch (_) {}
  }

  // Admin: send notification. Returns null on success, error message on failure.
  Future<String?> sendNotification({
    required String title,
    required String body,
    String? targetEmail,
    String? targetDeviceId,
  }) async {
    try {
      await _dio.post(ApiConstants.notificationsSendEndpoint, data: {
        'title': title,
        'body': body,
        if (targetEmail != null) 'targetEmail': targetEmail,
        if (targetDeviceId != null) 'targetDeviceId': targetDeviceId,
      });
      return null;
    } catch (e) {
      if (e is DioException) {
        final code = e.response?.statusCode;
        final body = e.response?.data;
        final serverMsg = body is Map && body['error'] is String && (body['error'] as String).isNotEmpty
            ? body['error'] as String
            : null;
        if (code == 401) return 'Не авторизован. Войдите заново.';
        if (code == 403) {
          if (serverMsg != null) {
            return 'Отказ сервера (403): $serverMsg';
          }
          return 'Нет прав администратора. Проверьте ADMIN_EMAILS на сервере.';
        }
        if (serverMsg != null) return 'Ошибка сервера: $serverMsg';
      }
      final s = e.toString();
      if (s.contains('Connection refused') || s.contains('SocketException')) return 'Сервер недоступен.';
      if (s.contains('TimeoutException') || s.contains('timeout')) return 'Сервер не отвечает. Попробуйте позже.';
      return s.replaceAll('Exception: ', '');
    }
  }

  // Admin: get all notifications. Returns list; empty on error.
  Future<List<AppNotification>> getAllNotifications() async {
    try {
      final response = await _dio.get(ApiConstants.notificationsAllEndpoint);
      final data = response.data['notifications'] as List? ?? [];
      return data.map((e) => AppNotification.fromJson(e as Map<String, dynamic>)).toList();
    } catch (_) {
      return [];
    }
  }

  // Admin: get all notifications, surfacing the error so the UI can show it.
  Future<({List<AppNotification> items, String? error})> getAllNotificationsWithError() async {
    try {
      final response = await _dio.get(ApiConstants.notificationsAllEndpoint);
      final raw = response.data['notifications'];
      final List<AppNotification> items = (raw is List ? raw : const <dynamic>[])
          .map((e) => AppNotification.fromJson(e as Map<String, dynamic>))
          .toList();
      return (items: items, error: null);
    } catch (e) {
      return (items: const <AppNotification>[], error: _describeError(e));
    }
  }

  // Admin: delete notification
  Future<void> deleteNotification(String id) async {
    try {
      await _dio.delete('${ApiConstants.notificationsEndpoint}/$id');
    } catch (_) {}
  }

  String _describeError(Object e) {
    if (e is DioException) {
      final code = e.response?.statusCode;
      final body = e.response?.data;
      final serverMsg = body is Map && body['error'] is String && (body['error'] as String).isNotEmpty
          ? body['error'] as String
          : null;
      if (code == 401) return 'Не авторизован. Войдите заново.';
      if (code == 403) {
        return serverMsg != null
            ? 'Отказ сервера (403): $serverMsg'
            : 'Нет прав администратора. Проверьте ADMIN_EMAILS на сервере.';
      }
      if (serverMsg != null) return 'Ошибка сервера: $serverMsg';
    }
    final s = e.toString();
    if (s.contains('Connection refused') || s.contains('SocketException')) return 'Сервер недоступен.';
    if (s.contains('TimeoutException') || s.contains('timeout')) return 'Сервер не отвечает. Попробуйте позже.';
    return s.replaceAll('Exception: ', '');
  }
}
