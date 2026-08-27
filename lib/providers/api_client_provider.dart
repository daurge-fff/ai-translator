import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/remote/api_client.dart';
import 'auth_provider.dart';

/// Global API client. The auth token is synced here so every consumer
/// (translate, admin, notifications) always sends a valid token.
final apiClientProvider = Provider<ApiClient>((ref) {
  final client = ApiClient();
  ref.listen(authProvider, (prev, next) {
    client.setIdToken(next.idToken.isNotEmpty ? next.idToken : null);
  }, fireImmediately: true);
  return client;
});
