import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';

class UserProfile {
  final String email;
  final String displayName;
  final String avatarUrl;
  final bool isAdmin;
  final bool isAuthenticated;

  const UserProfile({
    this.email = '',
    this.displayName = '',
    this.avatarUrl = '',
    this.isAdmin = false,
    this.isAuthenticated = false,
  });

  UserProfile copyWith({
    String? email,
    String? displayName,
    String? avatarUrl,
    bool? isAdmin,
    bool? isAuthenticated,
  }) {
    return UserProfile(
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      isAdmin: isAdmin ?? this.isAdmin,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
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

  final GoogleSignIn _googleSignIn = GoogleSignIn(
    clientId: kIsWeb ? _webClientId : _iosClientId,
  );

  // Emails that are granted administrator access.
  static const Set<String> adminEmails = {'germangpt3@gmail.com'};

  AuthNotifier() : super(const UserProfile());

  /// Returns `null` on success/cancel, otherwise the underlying error message
  /// (e.g. the OAuth failure reason) so the UI can surface it.
  Future<String?> signInWithGoogle() async {
    try {
      final account = await _googleSignIn.signIn();
      if (account == null) return null;
      state = UserProfile(
        email: account.email,
        displayName: (account.displayName != null &&
                account.displayName!.isNotEmpty)
            ? account.displayName!
            : account.email,
        avatarUrl: account.photoUrl ?? '',
        isAdmin: adminEmails.contains(account.email.toLowerCase()),
        isAuthenticated: true,
      );
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
    } catch (_) {
      // Ignore sign-out errors; always clear the local session.
    }
    state = const UserProfile();
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, UserProfile>(
  (ref) => AuthNotifier(),
);
