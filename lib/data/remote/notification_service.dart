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

  // Admin: send notification
  Future<bool> sendNotification({
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
      return true;
    } catch (_) {
      return false;
    }
  }

  // Admin: get all notifications
  Future<List<AppNotification>> getAllNotifications() async {
    try {
      final response = await _dio.get(ApiConstants.notificationsAllEndpoint);
      final data = response.data['notifications'] as List? ?? [];
      return data.map((e) => AppNotification.fromJson(e as Map<String, dynamic>)).toList();
    } catch (_) {
      return [];
    }
  }

  // Admin: delete notification
  Future<void> deleteNotification(String id) async {
    try {
      await _dio.delete('${ApiConstants.notificationsEndpoint}/$id');
    } catch (_) {}
  }
}
