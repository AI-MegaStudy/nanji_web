import 'package:flutter/material.dart';

class AdminNavItem {
  const AdminNavItem({required this.label, required this.icon});

  final String label;
  final IconData icon;
}

class AdminMetric {
  const AdminMetric({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color color;
}

class ParkingSummaryItem {
  const ParkingSummaryItem({
    required this.label,
    required this.value,
    required this.unit,
  });

  final String label;
  final String value;
  final String unit;
}

class FunnelStepData {
  const FunnelStepData({required this.label, required this.rate, required this.count});

  final String label;
  final int rate;
  final int count;
}

class PlaceholderSection {
  const PlaceholderSection({required this.title, required this.description});

  final String title;
  final String description;
}

class ParkingAnalysisLotRow {
  const ParkingAnalysisLotRow({
    required this.id,
    required this.displayName,
    required this.totalSpaces,
    required this.supportsRealtime,
    required this.supportsPrediction,
    required this.availableSpaces,
    required this.occupiedSpaces,
    required this.occupancyRate,
    required this.statusLabel,
    required this.hasRealtimeData,
  });

  final int id;
  final String displayName;
  final int totalSpaces;
  final bool supportsRealtime;
  final bool supportsPrediction;
  final int availableSpaces;
  final int occupiedSpaces;
  final double occupancyRate;
  final String statusLabel;
  final bool hasRealtimeData;
}

class OperationalInsight {
  const OperationalInsight({
    required this.id,
    required this.type,
    required this.message,
    required this.time,
  });

  final int id;
  final String type;
  final String message;
  final String time;
}

class FeatureUsageSlice {
  const FeatureUsageSlice({
    required this.name,
    required this.value,
    required this.color,
  });

  final String name;
  final int value;
  final Color color;
}

class HourlyUsagePoint {
  const HourlyUsagePoint({
    required this.hour,
    required this.value,
  });

  final int hour;
  final double value;
}

class DistributionItem {
  const DistributionItem({
    required this.label,
    required this.count,
    required this.color,
    this.percentage,
  });

  final String label;
  final int count;
  final Color color;
  final int? percentage;
}

class WeeklyTrendPoint {
  const WeeklyTrendPoint({
    required this.label,
    required this.primary,
    required this.secondary,
    this.tertiary = 0,
  });

  final String label;
  final int primary;
  final int secondary;
  final int tertiary;
}

class NotificationSettingStat {
  const NotificationSettingStat({
    required this.label,
    required this.count,
    required this.percentage,
    required this.icon,
    required this.color,
    required this.background,
  });

  final String label;
  final int count;
  final int percentage;
  final IconData icon;
  final Color color;
  final Color background;
}

class DropOffItem {
  const DropOffItem({
    required this.label,
    required this.rate,
    required this.count,
  });

  final String label;
  final int rate;
  final int count;
}

class AccuracyPoint {
  const AccuracyPoint({
    required this.label,
    required this.accuracy,
    required this.usage,
  });

  final String label;
  final int accuracy;
  final int usage;
}

class PostActionItem {
  const PostActionItem({
    required this.label,
    required this.count,
    required this.rate,
  });

  final String label;
  final int count;
  final double rate;
}

class CongestionPredictionItem {
  const CongestionPredictionItem({
    required this.label,
    required this.prediction,
    required this.noPrediction,
    required this.color,
  });

  final String label;
  final int prediction;
  final int noPrediction;
  final Color color;
}

class ActivityLogItem {
  const ActivityLogItem({
    required this.time,
    required this.action,
    required this.user,
    required this.detail,
    required this.type,
  });

  final String time;
  final String action;
  final String user;
  final String detail;
  final String type;
}

class ActivityFilterItem {
  const ActivityFilterItem({
    required this.value,
    required this.label,
  });

  final String value;
  final String label;
}
