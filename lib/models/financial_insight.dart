import 'package:flutter/material.dart';

enum InsightType {
  positive,
  warning,
  info,
  tip,
}

class FinancialInsight {
  final String title;
  final String description;
  final IconData icon;
  final InsightType type;
  final String? metricValue;

  const FinancialInsight({
    required this.title,
    required this.description,
    required this.icon,
    required this.type,
    this.metricValue,
  });
}
