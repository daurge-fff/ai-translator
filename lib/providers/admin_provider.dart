import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../data/remote/api_client.dart';
import 'api_client_provider.dart';

class SecurityIncident {
  final String id;
  final String timestamp;
  final String user;
  final String deviceId;
  final String ip;
  final String snippet;
  final String pattern;
  final String severity;

  SecurityIncident({
    required this.id,
    required this.timestamp,
    required this.user,
    required this.deviceId,
    required this.ip,
    required this.snippet,
    required this.pattern,
    required this.severity,
  });

  factory SecurityIncident.fromJson(Map<String, dynamic> json) {
    return SecurityIncident(
      id: json['id'] ?? '',
      timestamp: json['timestamp'] ?? '',
      user: json['user'] ?? 'anonymous',
      deviceId: json['deviceId'] ?? 'unknown',
      ip: json['ip'] ?? '127.0.0.1',
      snippet: json['snippet'] ?? '',
      pattern: json['pattern'] ?? '',
      severity: json['severity'] ?? 'low',
    );
  }
}

class BannedEntity {
  final String value;
  final String type; // 'user', 'device', 'ip'
  final String reason;
  final String warningMessage;
  final String? expiresAt;

  BannedEntity({required this.value, required this.type, required this.reason, this.warningMessage = '', this.expiresAt});
}

class AdminState {
  final List<SecurityIncident> incidents;
  final List<BannedEntity> bans;
  final bool isLoading;
  final String? error;

  AdminState({
    this.incidents = const [],
    this.bans = const [],
    this.isLoading = false,
    this.error,
  });

  AdminState copyWith({
    List<SecurityIncident>? incidents,
    List<BannedEntity>? bans,
    bool? isLoading,
    String? error,
  }) {
    return AdminState(
      incidents: incidents ?? this.incidents,
      bans: bans ?? this.bans,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class AdminNotifier extends StateNotifier<AdminState> {
  final ApiClient _apiClient;

  AdminNotifier(this._apiClient) : super(AdminState());

  Future<void> fetchIncidents() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final rawList = await _apiClient.fetchAdminIncidents();
      final incidents = rawList.map((e) => SecurityIncident.fromJson(e)).toList();
      state = state.copyWith(incidents: incidents, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: _errMsg(e));
    }
  }

  /// Returns true when the ban list was refreshed successfully.
  Future<bool> fetchBans() async {
    try {
      final rawList = await _apiClient.fetchBans();
      final bans = rawList.map((e) => BannedEntity(
        value: e['value'] ?? '',
        type: e['type'] ?? 'user',
        reason: e['reason'] ?? '',
        warningMessage: e['warningMessage'] ?? '',
        expiresAt: e['expiresAt'],
      )).toList();
      state = state.copyWith(bans: bans, error: null);
      return true;
    } catch (e) {
      state = state.copyWith(error: _errMsg(e));
      return false;
    }
  }

  Future<void> refreshAll() async {
    state = state.copyWith(isLoading: true, error: null);
    await Future.wait([fetchIncidents(), fetchBans()]);
    state = state.copyWith(isLoading: false);
  }

  void dismissIncident(String id) {
    final updatedList = state.incidents.where((item) => item.id != id).toList();
    state = state.copyWith(incidents: updatedList);
  }

  Future<bool> addBan(String value, String type, String reason, {String warningMessage = '', String? expiresAt}) async {
    try {
      await _apiClient.addBan(value, type, reason, warningMessage: warningMessage, expiresAt: expiresAt);
      state = state.copyWith(error: null);
      await fetchBans();
      return true;
    } catch (e) {
      final msg = _errMsg(e);
      state = state.copyWith(error: msg);
      return false;
    }
  }

  Future<bool> removeBan(String value, String type) async {
    try {
      await _apiClient.removeBan(value, type);
      await fetchBans();
      return true;
    } catch (e) {
      state = state.copyWith(error: _errMsg(e));
      return false;
    }
  }

  String _errMsg(Object e) {
    if (e is DioException) {
      final code = e.response?.statusCode;
      final body = e.response?.data;
      final serverMsg = body is Map && body['error'] is String && (body['error'] as String).isNotEmpty
          ? body['error'] as String
          : null;
      if (code == 403) {
        return serverMsg != null
            ? 'Отказано в доступе (403): $serverMsg'
            : 'Нет прав администратора. Проверьте ADMIN_EMAILS на сервере.';
      }
      if (code == 401) return 'Не авторизован. Войдите заново.';
      if (serverMsg != null) return serverMsg;
    }
    final s = e.toString();
    if (s.contains('Connection refused') || s.contains('SocketException')) return 'Сервер недоступен.';
    return s.replaceAll('Exception: ', '');
  }

  bool isBlocked(String userEmail, String deviceId, String ip) {
    return state.bans.any((b) =>
        (b.type == 'user' && b.value.toLowerCase() == userEmail.toLowerCase()) ||
        (b.type == 'device' && b.value == deviceId) ||
        (b.type == 'ip' && b.value == ip));
  }
}

final adminProvider = StateNotifierProvider<AdminNotifier, AdminState>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return AdminNotifier(apiClient);
});
