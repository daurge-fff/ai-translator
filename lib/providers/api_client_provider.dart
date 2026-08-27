import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/remote/api_client.dart';

/// Global API client, shared by every consumer (translate, admin,
/// notifications). The auth token is pushed onto this shared instance by
/// [AuthNotifier] after sign-in, so all consumers always send a valid token.
///
/// This provider intentionally does NOT depend on [authProvider] (it would
/// create a circular dependency because the auth notifier needs the client
/// to re-check ban status).
final apiClientProvider = Provider<ApiClient>((ref) => ApiClient());
