import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../data/remote/api_client.dart';
import 'api_client_provider.dart';
class UserProfile {
  final String email;
  final String displayName;
  final String avatarUrl;
  final bool isAdmin;
  final bool isAuthenticated;
  final String idToken;
  final BanInfo? ban;

  const UserProfile({
    this.email = '',
    this.displayName = '',
    this.avatarUrl = '',
    this.isAdmin = false,
    this.isAuthenticated = false,
    this.idToken = '',
    this.ban,
  });

  bool get isBanned => ban != null;

  static const Object _unset = Object();

  UserProfile copyWith({
    String? email,
    String? displayName,
    String? avatarUrl,
    bool? isAdmin,
    bool? isAuthenticated,
    String? idToken,
    Object? ban = _unset,
  }) {
    return UserProfile(
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      isAdmin: isAdmin ?? this.isAdmin,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      idToken: idToken ?? this.idToken,
      ban: identical(ban, _unset) ? this.ban : ban as BanInfo?,
    );
  }
}

class AuthNotifier extends StateNotifier<UserProfile> {
  /// Google OAuth 2.0 Web client ID (used on Web platform).
  static const String _webClientId =
      '841057078666-fmstis3g9qm2tlp7bisf0reh69q2173l.apps.googleusercontent.com';

  /// Google OAuth 2.0 iOS/macOS client ID (used on Apple platforms).
  static const String _iosClientId =
      '841057078666-7ro3biov52o9sspkr5p7v1mkaejsbu2l.apps.googleusercontent.com';

  final ApiClient _api;

  AuthNotifier(this._api) : super(const UserProfile()) {
    _googleSignIn = GoogleSignIn(
      clientId: kIsWeb
          ? _webClientId
          : defaultTargetPlatform == TargetPlatform.iOS ||
                  defaultTargetPlatform == TargetPlatform.macOS
              ? _iosClientId
              : null, // Android uses google-services.json default
    );
  }

  late final GoogleSignIn _googleSignIn;

  // Emails that are granted administrator access.
  static const Set<String> adminEmails = {'germangpt3@gmail.com'};

  /// Returns `null` on success/cancel, otherwise the underlying error message
  /// (e.g. the OAuth failure reason) so the UI can surface it.
  Future<String?> signInWithGoogle() async {
    try {
      final account = await _googleSignIn.signIn();
      if (account == null) return null;
      final auth = await account.authentication;
      final idToken = auth.idToken ?? '';
      _api.setIdToken(idToken.isNotEmpty ? idToken : null);
      state = UserProfile(
        email: account.email,
        displayName: (account.displayName != null &&
                account.displayName!.isNotEmpty)
            ? account.displayName!
            : account.email,
        avatarUrl: account.photoUrl ?? '',
        isAdmin: adminEmails.contains(account.email.toLowerCase()),
        isAuthenticated: true,
        idToken: idToken,
      );
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  void setBan(BanInfo? ban) {
    state = state.copyWith(ban: ban);
  }

  /// Re-checks the ban status against the server and updates the local state,
  /// so a removed/expired ban is cleared without restarting the app.
  Future<void> refreshBanStatus() async {
    if (!state.isAuthenticated || state.idToken.isEmpty) return;
    final ban = await _api.fetchBanStatus();
    if (ban != null) {
      state = state.copyWith(ban: ban);
    } else {
      state = state.copyWith(ban: null);
    }
  }

  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
    } catch (_) {
      // Ignore sign-out errors; always clear the local session.
    }
    _api.setIdToken(null);
    state = const UserProfile();
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, UserProfile>(
  (ref) => AuthNotifier(ref.watch(apiClientProvider)),
);
