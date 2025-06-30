// lib/app/core/services/layout_service.dart

import 'package:flutter/foundation.dart'; // For kIsWeb and defaultTargetPlatform
import 'package:flutter/material.dart'; // For BuildContext and MediaQuery

// Define an enum to make the layout type explicit and extensible
enum AppLayoutType {
  mobile,
  tablet, // You might introduce a separate tablet layout later
  desktop,
}

class LayoutService {
  // Define your breakpoints. These can be adjusted or even moved to app_config.dart
  // if you want them globally configurable.
  static const double _mobileBreakpoint = 600.0;
  static const double _tabletBreakpoint =
      900.0; // Example for a potential tablet layout

  /// Determines the current AppLayoutType based on the screen width.
  /// This is the primary method for deciding the UI layout.
  static AppLayoutType getLayoutType(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    if (screenWidth < _mobileBreakpoint) {
      return AppLayoutType.mobile;
    } else if (screenWidth >= _mobileBreakpoint &&
        screenWidth < _tabletBreakpoint) {
      // For now, treat tablets similar to desktop if no distinct tablet UI.
      // If you design a specific tablet UI, return AppLayoutType.tablet here.
      return AppLayoutType.desktop;
    } else {
      return AppLayoutType.desktop;
    }
  }

  /// Helper to check if the current UI layout should be mobile-optimized.
  static bool isMobileLayout(BuildContext context) {
    return getLayoutType(context) == AppLayoutType.mobile;
  }

  /// Helper to check if the current UI layout should be desktop/tablet-optimized.
  static bool isDesktopOrTabletLayout(BuildContext context) {
    final layoutType = getLayoutType(context);
    return layoutType == AppLayoutType.desktop ||
        layoutType == AppLayoutType.tablet;
  }

  // --- Optional: Strict Platform Checks (for platform-specific *features/APIs*, not layout) ---
  // Keep these if you need to differentiate behavior based on the *native* platform,
  // e.g., using a native share sheet vs. a web share API.
  static bool get isNativeMobilePlatform =>
      defaultTargetPlatform == TargetPlatform.android ||
      defaultTargetPlatform == TargetPlatform.iOS;

  static bool get isNativeDesktopPlatform =>
      defaultTargetPlatform == TargetPlatform.linux ||
      defaultTargetPlatform == TargetPlatform.macOS ||
      defaultTargetPlatform == TargetPlatform.windows;

  static bool get isWebPlatform => kIsWeb;
}
