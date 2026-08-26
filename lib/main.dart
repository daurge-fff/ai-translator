import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/l10n/app_strings.dart';
import 'core/l10n/locale_provider.dart';
import 'core/theme/app_theme.dart';
import 'presentation/auth/auth_screen.dart';
import 'presentation/contexts/contexts_screen.dart';
import 'presentation/history/history_screen.dart';
import 'presentation/profile/profile_screen.dart';
import 'presentation/translate/translate_screen.dart';
import 'presentation/widgets/liquid_glass_navigation_bar.dart';
import 'providers/auth_provider.dart';
import 'providers/theme_provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    const ProviderScope(
      child: ContextualTranslatorApp(),
    ),
  );
}

class _NoScrollbarBehavior extends ScrollBehavior {
  @override
  Widget buildScrollbar(BuildContext context, Widget child, ScrollableDetails details) {
    return child;
  }
}

class ContextualTranslatorApp extends ConsumerWidget {
  const ContextualTranslatorApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeState = ref.watch(themeProvider);
    final locale = ref.watch(localeProvider);
    return MaterialApp(
      title: 'Contextual Translator',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeState.themeMode,
      locale: locale,
      supportedLocales: const [Locale('en'), Locale('ru')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      scrollBehavior: _NoScrollbarBehavior(),
      home: const RootAuthRouter(),
    );
  }
}

class RootAuthRouter extends ConsumerWidget {
  const RootAuthRouter({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider);
    if (!user.isAuthenticated) return const AuthScreen();
    return const MainNavigationShell();
  }
}

class MainNavigationShell extends ConsumerStatefulWidget {
  const MainNavigationShell({super.key});

  @override
  ConsumerState<MainNavigationShell> createState() => _MainNavigationShellState();
}

class _MainNavigationShellState extends ConsumerState<MainNavigationShell> {
  int _currentIndex = 0;
  bool _navDimmed = false;

  Color get _bottomFade => Theme.of(context).scaffoldBackgroundColor;

  bool _onScrollNotification(ScrollNotification notification) {
    if (notification.metrics.axis != Axis.vertical) return false;
    final dimmed = notification.metrics.pixels > 32;
    if (dimmed != _navDimmed) {
      setState(() => _navDimmed = dimmed);
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      const TranslateScreen(),
      const ContextsScreen(),
      const HistoryScreen(),
      const ProfileScreen(),
    ];

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: NotificationListener<ScrollNotification>(
        onNotification: _onScrollNotification,
        child: Stack(
          children: [
            Positioned.fill(
              child: IndexedStack(
                index: _currentIndex >= screens.length ? 0 : _currentIndex,
                children: screens,
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              height: 140,
              child: IgnorePointer(
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOutCubic,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        _bottomFade.withValues(alpha: 0),
                        _bottomFade.withValues(alpha: 0.45),
                        _bottomFade.withValues(alpha: 0.98),
                      ],
                      stops: const [0.0, 0.6, 1.0],
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: LiquidGlassNavigationBar(
                currentIndex:
                    _currentIndex >= screens.length ? 0 : _currentIndex,
                dimmed: _navDimmed,
                onIndexChanged: (index) {
                  setState(() {
                    _currentIndex = index;
                    _navDimmed = false;
                  });
                },
                items: [
                  NavigationItem(
                    icon: CupertinoIcons.captions_bubble,
                    activeIcon: CupertinoIcons.captions_bubble_fill,
                    label: context.l.navTranslate,
                  ),
                  NavigationItem(
                    icon: CupertinoIcons.bookmark,
                    activeIcon: CupertinoIcons.bookmark_fill,
                    label: context.l.navContexts,
                  ),
                  NavigationItem(
                    icon: CupertinoIcons.clock,
                    activeIcon: CupertinoIcons.clock_fill,
                    label: context.l.navHistory,
                  ),
                  NavigationItem(
                    icon: CupertinoIcons.person,
                    activeIcon: CupertinoIcons.person_fill,
                    label: context.l.navProfile,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
