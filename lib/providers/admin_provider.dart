import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/remote/api_client.dart';
import 'translation_provider.dart';

class BanInfo {
  final String reason;
  final String warningMessage;
  final String? expiresAt;

  BanInfo({this.reason = '', this.warningMessage = '', this.expiresAt});

  DateTime? get expiresAtDate {
    if (expiresAt == null || expiresAt!.isEmpty) return null;
    return DateTime.tryParse(expiresAt!);
  }

  bool get isPermanent => expiresAt == null || expiresAt!.isEmpty;

  static BanInfo? tryParse(Object error) {
    if (error is BanException) {
      return BanInfo(
        reason: error.reason,
        warningMessage: error.warningMessage,
        expiresAt: error.expiresAt,
      );
    }
    return null;
  }
}

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
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> fetchBans() async {
    try {
      final rawList = await _apiClient.fetchBans();
      final bans = rawList.map((e) => BannedEntity(
        value: e['value'] ?? '',
        type: e['type'] ?? 'user',
        reason: e['reason'] ?? '',
        warningMessage: e['warningMessage'] ?? '',
        expiresAt: e['expiresAt'],
      )).toList();
      state = state.copyWith(bans: bans);
    } catch (_) {}
  }

  void dismissIncident(String id) {
    final updatedList = state.incidents.where((item) => item.id != id).toList();
    state = state.copyWith(incidents: updatedList);
  }

  Future<void> addBan(String value, String type, String reason, {String warningMessage = '', String? expiresAt}) async {
    try {
      await _apiClient.addBan(value, type, reason, warningMessage: warningMessage, expiresAt: expiresAt);
      final newBan = BannedEntity(value: value, type: type, reason: reason, warningMessage: warningMessage, expiresAt: expiresAt);
      state = state.copyWith(bans: [...state.bans, newBan]);
    } catch (_) {}
  }

  Future<void> removeBan(String value, String type) async {
    try {
      await _apiClient.removeBan(value, type);
      final updatedBans = state.bans.where((b) => !(b.value == value && b.type == type)).toList();
      state = state.copyWith(bans: updatedBans);
    } catch (_) {}
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
