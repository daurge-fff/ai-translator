import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Top inset for page content.
///
/// On mobile the status bar / Dynamic Island inset is used so readable content
/// stays clear of it, while the background remains edge-to-edge (immersive).
/// On desktop there is no system top inset, so a comfortable margin is added
/// instead so pages don't start flush against the window title bar.
double contentTopInset(BuildContext context, {double mobileExtra = 8, double desktop = 20}) {
  final top = MediaQuery.of(context).padding.top;
  final isDesktop = kIsWeb
      ? false
      : defaultTargetPlatform == TargetPlatform.macOS ||
            defaultTargetPlatform == TargetPlatform.windows ||
            defaultTargetPlatform == TargetPlatform.linux;
  return top + (isDesktop ? desktop : mobileExtra);
}
