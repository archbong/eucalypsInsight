// lib/features/dashboard/domain/models/dashboard_metric.dart
import 'package:flutter/material.dart'; // Make sure Material is imported for IconData

/// Represents a single key metric for display on the dashboard.
class DashboardMetric {
  final String title;
  final String value;
  final IconData icon;
  final List<double>?
  chartData; // Optional data for a mini chart within the card

  const DashboardMetric({
    required this.title,
    required this.value,
    required this.icon,
    this.chartData,
  });
}
