import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ai_translator/providers/api_client_provider.dart';
import 'package:ai_translator/providers/auth_provider.dart';
import 'package:ai_translator/providers/admin_provider.dart';

void main() {
  testWidgets('provider graph has no circular dependency', (tester) async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    // Constructing these providers used to throw a CircularDependencyError
    // because apiClientProvider depended on authProvider while the auth
    // notifier read apiClientProvider back.
    final api = container.read(apiClientProvider);
    final auth = container.read(authProvider.notifier);
    final admin = container.read(adminProvider.notifier);

    expect(api, isNotNull);
    expect(auth, isNotNull);
    expect(admin, isNotNull);

    // refreshBanStatus must not throw, even when unauthenticated.
    await auth.refreshBanStatus();
  });
}
