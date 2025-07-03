// lib/app/app_sizing.dart
import 'package:flutter/material.dart';

class AppSpacing {
  static const double xs = 4.0; // 0.25rem
  static const double sm = 8.0; // 0.5rem
  static const double md = 16.0; // 1rem
  static const double lg = 24.0; // 1.5rem
  // ... and so on

  // You could have a method that returns responsive spacing:
  static double responsive(
    BuildContext context, {
    double mobile = 0.0,
    double tablet = 0.0,
    double desktop = 0.0,
  }) {
    final width = MediaQuery.of(context).size.width;
    if (width >= 1025) return desktop;
    if (width >= 769) return tablet;
    return mobile;
  }
}
