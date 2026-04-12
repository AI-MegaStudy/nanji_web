import 'dart:convert';

import 'package:http/http.dart' as http;

class AdminParkingLotItem {
  AdminParkingLotItem({
    required this.id,
    required this.displayName,
    required this.totalSpaces,
    required this.supportsPrediction,
    required this.supportsRealtime,
  });

  final int id;
  final String displayName;
  final int totalSpaces;
  final bool supportsPrediction;
  final bool supportsRealtime;

  factory AdminParkingLotItem.fromJson(Map<String, dynamic> json) {
    return AdminParkingLotItem(
      id: json['p_id'] as int,
      displayName: json['p_display_name'] as String? ?? '-',
      totalSpaces: json['p_total_spaces'] as int? ?? 0,
      supportsPrediction: _asBool(json['p_supports_prediction']),
      supportsRealtime: _asBool(json['p_supports_realtime_congestion']),
    );
  }
}

class AdminCurrentStatusItem {
  AdminCurrentStatusItem({
    required this.parkingLotName,
    required this.hasData,
    required this.availableSpaces,
    required this.occupiedSpaces,
    required this.occupancyRate,
    required this.congestionLevel,
  });

  final String parkingLotName;
  final bool hasData;
  final int availableSpaces;
  final int occupiedSpaces;
  final double occupancyRate;
  final String congestionLevel;

  factory AdminCurrentStatusItem.fromJson(Map<String, dynamic> json) {
    final item = json['item'] as Map<String, dynamic>?;
    return AdminCurrentStatusItem(
      parkingLotName: json['parking_lot_name'] as String? ?? '-',
      hasData: _asBool(json['has_data']),
      availableSpaces: item?['ps_available_spaces'] as int? ?? 0,
      occupiedSpaces: item?['ps_occupied_spaces'] as int? ?? 0,
      occupancyRate: double.tryParse((item?['ps_occupancy_rate'] ?? '0').toString()) ?? 0,
      congestionLevel: item?['ps_congestion_level'] as String? ?? 'unknown',
    );
  }
}

class AdminPredictionItem {
  AdminPredictionItem({
    required this.predictedTime,
    required this.availableSpaces,
    required this.occupancyRate,
    required this.congestionLevel,
  });

  final String predictedTime;
  final int availableSpaces;
  final double occupancyRate;
  final String congestionLevel;

  factory AdminPredictionItem.fromJson(Map<String, dynamic> json) {
    return AdminPredictionItem(
      predictedTime: json['pp_predicted_time'] as String? ?? '',
      availableSpaces: json['pp_predicted_available_spaces'] as int? ?? 0,
      occupancyRate: double.tryParse((json['pp_predicted_occupancy_rate'] ?? '0').toString()) ?? 0,
      congestionLevel: json['pp_predicted_congestion_level'] as String? ?? 'unknown',
    );
  }
}

class AdminDashboardOverviewMetricData {
  AdminDashboardOverviewMetricData({
    required this.key,
    required this.label,
    required this.value,
    required this.displayValue,
  });

  final String key;
  final String label;
  final int value;
  final String displayValue;

  factory AdminDashboardOverviewMetricData.fromJson(Map<String, dynamic> json) {
    return AdminDashboardOverviewMetricData(
      key: json['key'] as String? ?? '',
      label: json['label'] as String? ?? '-',
      value: json['value'] as int? ?? 0,
      displayValue: json['display_value'] as String? ?? '0',
    );
  }
}

class AdminDashboardOverviewParkingData {
  AdminDashboardOverviewParkingData({
    required this.parkingLotId,
    required this.parkingLotName,
    required this.totalSpaces,
    required this.availableSpaces,
    required this.occupiedSpaces,
    required this.occupancyRate,
    required this.congestionLevel,
    required this.hasRealtimeData,
  });

  final int parkingLotId;
  final String parkingLotName;
  final int totalSpaces;
  final int availableSpaces;
  final int occupiedSpaces;
  final double occupancyRate;
  final String congestionLevel;
  final bool hasRealtimeData;

  factory AdminDashboardOverviewParkingData.fromJson(Map<String, dynamic> json) {
    return AdminDashboardOverviewParkingData(
      parkingLotId: json['parking_lot_id'] as int? ?? 0,
      parkingLotName: json['parking_lot_name'] as String? ?? '-',
      totalSpaces: json['total_spaces'] as int? ?? 0,
      availableSpaces: json['available_spaces'] as int? ?? 0,
      occupiedSpaces: json['occupied_spaces'] as int? ?? 0,
      occupancyRate: double.tryParse((json['occupancy_rate'] ?? '0').toString()) ?? 0,
      congestionLevel: json['congestion_level'] as String? ?? 'unknown',
      hasRealtimeData: _asBool(json['has_realtime_data']),
    );
  }
}

class AdminDashboardOverviewInsightData {
  AdminDashboardOverviewInsightData({
    required this.id,
    required this.type,
    required this.message,
    required this.time,
  });

  final int id;
  final String type;
  final String message;
  final String time;

  factory AdminDashboardOverviewInsightData.fromJson(Map<String, dynamic> json) {
    return AdminDashboardOverviewInsightData(
      id: json['id'] as int? ?? 0,
      type: json['type'] as String? ?? 'info',
      message: json['message'] as String? ?? '-',
      time: json['time'] as String? ?? '-',
    );
  }
}

class AdminDashboardOverviewHourlyData {
  AdminDashboardOverviewHourlyData({required this.hour, required this.value});

  final int hour;
  final int value;

  factory AdminDashboardOverviewHourlyData.fromJson(Map<String, dynamic> json) {
    return AdminDashboardOverviewHourlyData(
      hour: json['hour'] as int? ?? 0,
      value: json['value'] as int? ?? 0,
    );
  }
}

class AdminDashboardOverviewFeatureData {
  AdminDashboardOverviewFeatureData({required this.key, required this.name, required this.value});

  final String key;
  final String name;
  final int value;

  factory AdminDashboardOverviewFeatureData.fromJson(Map<String, dynamic> json) {
    return AdminDashboardOverviewFeatureData(
      key: json['key'] as String? ?? '',
      name: json['name'] as String? ?? '-',
      value: json['value'] as int? ?? 0,
    );
  }
}

class AdminDashboardOverviewFunnelData {
  AdminDashboardOverviewFunnelData({
    required this.key,
    required this.label,
    required this.count,
    required this.rate,
  });

  final String key;
  final String label;
  final int count;
  final int rate;

  factory AdminDashboardOverviewFunnelData.fromJson(Map<String, dynamic> json) {
    return AdminDashboardOverviewFunnelData(
      key: json['key'] as String? ?? '',
      label: json['label'] as String? ?? '-',
      count: json['count'] as int? ?? 0,
      rate: json['rate'] as int? ?? 0,
    );
  }
}

class AdminDashboardOverviewData {
  AdminDashboardOverviewData({
    required this.generatedAt,
    required this.metrics,
    required this.parkingOverview,
    required this.insights,
    required this.hourlyUsage,
    required this.featureUsage,
    required this.funnel,
  });

  final String generatedAt;
  final List<AdminDashboardOverviewMetricData> metrics;
  final AdminDashboardOverviewParkingData parkingOverview;
  final List<AdminDashboardOverviewInsightData> insights;
  final List<AdminDashboardOverviewHourlyData> hourlyUsage;
  final List<AdminDashboardOverviewFeatureData> featureUsage;
  final List<AdminDashboardOverviewFunnelData> funnel;

  factory AdminDashboardOverviewData.fromJson(Map<String, dynamic> json) {
    final metrics = (json['metrics'] as List<dynamic>? ?? [])
        .map((item) => AdminDashboardOverviewMetricData.fromJson(item as Map<String, dynamic>))
        .toList();
    final insights = (json['insights'] as List<dynamic>? ?? [])
        .map((item) => AdminDashboardOverviewInsightData.fromJson(item as Map<String, dynamic>))
        .toList();
    final hourlyUsage = (json['hourly_usage'] as List<dynamic>? ?? [])
        .map((item) => AdminDashboardOverviewHourlyData.fromJson(item as Map<String, dynamic>))
        .toList();
    final featureUsage = (json['feature_usage'] as List<dynamic>? ?? [])
        .map((item) => AdminDashboardOverviewFeatureData.fromJson(item as Map<String, dynamic>))
        .toList();
    final funnel = (json['funnel'] as List<dynamic>? ?? [])
        .map((item) => AdminDashboardOverviewFunnelData.fromJson(item as Map<String, dynamic>))
        .toList();

    return AdminDashboardOverviewData(
      generatedAt: json['generated_at'] as String? ?? '',
      metrics: metrics,
      parkingOverview: AdminDashboardOverviewParkingData.fromJson(
        (json['parking_overview'] as Map<String, dynamic>?) ?? const <String, dynamic>{},
      ),
      insights: insights,
      hourlyUsage: hourlyUsage,
      featureUsage: featureUsage,
      funnel: funnel,
    );
  }
}

class AdminParkingAnalysisMetricData {
  AdminParkingAnalysisMetricData({required this.key, required this.label, required this.value});

  final String key;
  final String label;
  final String value;

  factory AdminParkingAnalysisMetricData.fromJson(Map<String, dynamic> json) {
    return AdminParkingAnalysisMetricData(
      key: json['key'] as String? ?? '',
      label: json['label'] as String? ?? '-',
      value: json['value'] as String? ?? '0',
    );
  }
}

class AdminParkingAnalysisLotRowData {
  AdminParkingAnalysisLotRowData({
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

  factory AdminParkingAnalysisLotRowData.fromJson(Map<String, dynamic> json) {
    return AdminParkingAnalysisLotRowData(
      id: json['id'] as int? ?? 0,
      displayName: json['display_name'] as String? ?? '-',
      totalSpaces: json['total_spaces'] as int? ?? 0,
      supportsRealtime: _asBool(json['supports_realtime']),
      supportsPrediction: _asBool(json['supports_prediction']),
      availableSpaces: json['available_spaces'] as int? ?? 0,
      occupiedSpaces: json['occupied_spaces'] as int? ?? 0,
      occupancyRate: double.tryParse((json['occupancy_rate'] ?? '0').toString()) ?? 0,
      statusLabel: json['status_label'] as String? ?? '정보 준비 중',
      hasRealtimeData: _asBool(json['has_realtime_data']),
    );
  }
}

class AdminParkingAnalysisDistributionData {
  AdminParkingAnalysisDistributionData({required this.label, required this.count});

  final String label;
  final int count;

  factory AdminParkingAnalysisDistributionData.fromJson(Map<String, dynamic> json) {
    return AdminParkingAnalysisDistributionData(
      label: json['label'] as String? ?? '-',
      count: json['count'] as int? ?? 0,
    );
  }
}

class AdminParkingAnalysisFavoriteRankData {
  AdminParkingAnalysisFavoriteRankData({
    required this.rank,
    required this.name,
    required this.count,
    required this.trend,
    required this.change,
  });

  final int rank;
  final String name;
  final int count;
  final String trend;
  final int change;

  factory AdminParkingAnalysisFavoriteRankData.fromJson(Map<String, dynamic> json) {
    return AdminParkingAnalysisFavoriteRankData(
      rank: json['rank'] as int? ?? 0,
      name: json['name'] as String? ?? '-',
      count: json['count'] as int? ?? 0,
      trend: json['trend'] as String? ?? 'same',
      change: json['change'] as int? ?? 0,
    );
  }
}

class AdminParkingAnalysisWeeklyTrendData {
  AdminParkingAnalysisWeeklyTrendData({
    required this.label,
    required this.primary,
    required this.secondary,
    required this.tertiary,
  });

  final String label;
  final int primary;
  final int secondary;
  final int tertiary;

  factory AdminParkingAnalysisWeeklyTrendData.fromJson(Map<String, dynamic> json) {
    return AdminParkingAnalysisWeeklyTrendData(
      label: json['label'] as String? ?? '-',
      primary: json['primary'] as int? ?? 0,
      secondary: json['secondary'] as int? ?? 0,
      tertiary: json['tertiary'] as int? ?? 0,
    );
  }
}

class AdminParkingAnalysisOverviewData {
  AdminParkingAnalysisOverviewData({
    required this.generatedAt,
    required this.metrics,
    required this.lotRows,
    required this.selectionData,
    required this.mapUsageData,
    required this.avgDurationData,
    required this.weeklyParkingData,
    required this.favoriteRanking,
  });

  final String generatedAt;
  final List<AdminParkingAnalysisMetricData> metrics;
  final List<AdminParkingAnalysisLotRowData> lotRows;
  final List<AdminParkingAnalysisDistributionData> selectionData;
  final List<AdminParkingAnalysisDistributionData> mapUsageData;
  final List<AdminParkingAnalysisDistributionData> avgDurationData;
  final List<AdminParkingAnalysisWeeklyTrendData> weeklyParkingData;
  final List<AdminParkingAnalysisFavoriteRankData> favoriteRanking;

  factory AdminParkingAnalysisOverviewData.fromJson(Map<String, dynamic> json) {
    return AdminParkingAnalysisOverviewData(
      generatedAt: json['generated_at'] as String? ?? '',
      metrics: (json['metrics'] as List<dynamic>? ?? [])
          .map((item) => AdminParkingAnalysisMetricData.fromJson(item as Map<String, dynamic>))
          .toList(),
      lotRows: (json['lot_rows'] as List<dynamic>? ?? [])
          .map((item) => AdminParkingAnalysisLotRowData.fromJson(item as Map<String, dynamic>))
          .toList(),
      selectionData: (json['selection_data'] as List<dynamic>? ?? [])
          .map((item) => AdminParkingAnalysisDistributionData.fromJson(item as Map<String, dynamic>))
          .toList(),
      mapUsageData: (json['map_usage_data'] as List<dynamic>? ?? [])
          .map((item) => AdminParkingAnalysisDistributionData.fromJson(item as Map<String, dynamic>))
          .toList(),
      avgDurationData: (json['avg_duration_data'] as List<dynamic>? ?? [])
          .map((item) => AdminParkingAnalysisDistributionData.fromJson(item as Map<String, dynamic>))
          .toList(),
      weeklyParkingData: (json['weekly_parking_data'] as List<dynamic>? ?? [])
          .map((item) => AdminParkingAnalysisWeeklyTrendData.fromJson(item as Map<String, dynamic>))
          .toList(),
      favoriteRanking: (json['favorite_ranking'] as List<dynamic>? ?? [])
          .map((item) => AdminParkingAnalysisFavoriteRankData.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }
}

class AdminPredictionAnalysisMetricData {
  AdminPredictionAnalysisMetricData({required this.key, required this.label, required this.value});

  final String key;
  final String label;
  final String value;

  factory AdminPredictionAnalysisMetricData.fromJson(Map<String, dynamic> json) {
    return AdminPredictionAnalysisMetricData(
      key: json['key'] as String? ?? '',
      label: json['label'] as String? ?? '-',
      value: json['value'] as String? ?? '0',
    );
  }
}

class AdminPredictionAnalysisDistributionData {
  AdminPredictionAnalysisDistributionData({required this.label, required this.count});

  final String label;
  final int count;

  factory AdminPredictionAnalysisDistributionData.fromJson(Map<String, dynamic> json) {
    return AdminPredictionAnalysisDistributionData(
      label: json['label'] as String? ?? '-',
      count: json['count'] as int? ?? 0,
    );
  }
}

class AdminPredictionAnalysisWeeklyTrendData {
  AdminPredictionAnalysisWeeklyTrendData({
    required this.label,
    required this.primary,
    required this.secondary,
    required this.tertiary,
  });

  final String label;
  final int primary;
  final int secondary;
  final int tertiary;

  factory AdminPredictionAnalysisWeeklyTrendData.fromJson(Map<String, dynamic> json) {
    return AdminPredictionAnalysisWeeklyTrendData(
      label: json['label'] as String? ?? '-',
      primary: json['primary'] as int? ?? 0,
      secondary: json['secondary'] as int? ?? 0,
      tertiary: json['tertiary'] as int? ?? 0,
    );
  }
}

class AdminPredictionAnalysisAccuracyData {
  AdminPredictionAnalysisAccuracyData({required this.label, required this.accuracy, required this.usage});

  final String label;
  final int accuracy;
  final int usage;

  factory AdminPredictionAnalysisAccuracyData.fromJson(Map<String, dynamic> json) {
    return AdminPredictionAnalysisAccuracyData(
      label: json['label'] as String? ?? '-',
      accuracy: json['accuracy'] as int? ?? 0,
      usage: json['usage'] as int? ?? 0,
    );
  }
}

class AdminPredictionAnalysisPostActionData {
  AdminPredictionAnalysisPostActionData({required this.label, required this.count, required this.rate});

  final String label;
  final int count;
  final double rate;

  factory AdminPredictionAnalysisPostActionData.fromJson(Map<String, dynamic> json) {
    return AdminPredictionAnalysisPostActionData(
      label: json['label'] as String? ?? '-',
      count: json['count'] as int? ?? 0,
      rate: double.tryParse((json['rate'] ?? '0').toString()) ?? 0,
    );
  }
}

class AdminPredictionAnalysisCongestionData {
  AdminPredictionAnalysisCongestionData({required this.label, required this.prediction, required this.noPrediction});

  final String label;
  final int prediction;
  final int noPrediction;

  factory AdminPredictionAnalysisCongestionData.fromJson(Map<String, dynamic> json) {
    return AdminPredictionAnalysisCongestionData(
      label: json['label'] as String? ?? '-',
      prediction: json['prediction'] as int? ?? 0,
      noPrediction: json['no_prediction'] as int? ?? 0,
    );
  }
}

class AdminPredictionAnalysisOverviewData {
  AdminPredictionAnalysisOverviewData({
    required this.generatedAt,
    required this.metrics,
    required this.predictionByHour,
    required this.departureTiming,
    required this.hourlyPattern,
    required this.weeklyPrediction,
    required this.accuracyTrend,
    required this.postActions,
    required this.congestionPrediction,
    required this.predictionInsight,
    required this.departureInsight,
    required this.hourlyInsight,
    required this.congestionInsight,
  });

  final String generatedAt;
  final List<AdminPredictionAnalysisMetricData> metrics;
  final List<AdminPredictionAnalysisDistributionData> predictionByHour;
  final List<AdminPredictionAnalysisDistributionData> departureTiming;
  final List<AdminPredictionAnalysisWeeklyTrendData> hourlyPattern;
  final List<AdminPredictionAnalysisWeeklyTrendData> weeklyPrediction;
  final List<AdminPredictionAnalysisAccuracyData> accuracyTrend;
  final List<AdminPredictionAnalysisPostActionData> postActions;
  final List<AdminPredictionAnalysisCongestionData> congestionPrediction;
  final String predictionInsight;
  final String departureInsight;
  final String hourlyInsight;
  final String congestionInsight;

  factory AdminPredictionAnalysisOverviewData.fromJson(Map<String, dynamic> json) {
    return AdminPredictionAnalysisOverviewData(
      generatedAt: json['generated_at'] as String? ?? '',
      metrics: (json['metrics'] as List<dynamic>? ?? [])
          .map((item) => AdminPredictionAnalysisMetricData.fromJson(item as Map<String, dynamic>))
          .toList(),
      predictionByHour: (json['prediction_by_hour'] as List<dynamic>? ?? [])
          .map((item) => AdminPredictionAnalysisDistributionData.fromJson(item as Map<String, dynamic>))
          .toList(),
      departureTiming: (json['departure_timing'] as List<dynamic>? ?? [])
          .map((item) => AdminPredictionAnalysisDistributionData.fromJson(item as Map<String, dynamic>))
          .toList(),
      hourlyPattern: (json['hourly_pattern'] as List<dynamic>? ?? [])
          .map((item) => AdminPredictionAnalysisWeeklyTrendData.fromJson(item as Map<String, dynamic>))
          .toList(),
      weeklyPrediction: (json['weekly_prediction'] as List<dynamic>? ?? [])
          .map((item) => AdminPredictionAnalysisWeeklyTrendData.fromJson(item as Map<String, dynamic>))
          .toList(),
      accuracyTrend: (json['accuracy_trend'] as List<dynamic>? ?? [])
          .map((item) => AdminPredictionAnalysisAccuracyData.fromJson(item as Map<String, dynamic>))
          .toList(),
      postActions: (json['post_actions'] as List<dynamic>? ?? [])
          .map((item) => AdminPredictionAnalysisPostActionData.fromJson(item as Map<String, dynamic>))
          .toList(),
      congestionPrediction: (json['congestion_prediction'] as List<dynamic>? ?? [])
          .map((item) => AdminPredictionAnalysisCongestionData.fromJson(item as Map<String, dynamic>))
          .toList(),
      predictionInsight: json['prediction_insight'] as String? ?? '',
      departureInsight: json['departure_insight'] as String? ?? '',
      hourlyInsight: json['hourly_insight'] as String? ?? '',
      congestionInsight: json['congestion_insight'] as String? ?? '',
    );
  }
}

class AdminActivityCountData {
  AdminActivityCountData({required this.key, required this.label, required this.count});

  final String key;
  final String label;
  final int count;

  factory AdminActivityCountData.fromJson(Map<String, dynamic> json) {
    return AdminActivityCountData(
      key: json['key'] as String? ?? '',
      label: json['label'] as String? ?? '-',
      count: json['count'] as int? ?? 0,
    );
  }
}

class AdminActivityLogData {
  AdminActivityLogData({
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

  factory AdminActivityLogData.fromJson(Map<String, dynamic> json) {
    return AdminActivityLogData(
      time: json['time'] as String? ?? '-',
      action: json['action'] as String? ?? '-',
      user: json['user'] as String? ?? '-',
      detail: json['detail'] as String? ?? '-',
      type: json['type'] as String? ?? 'other',
    );
  }
}

class AdminActivityInsightData {
  AdminActivityInsightData({required this.title, required this.value, required this.detail});

  final String title;
  final String value;
  final String detail;

  factory AdminActivityInsightData.fromJson(Map<String, dynamic> json) {
    return AdminActivityInsightData(
      title: json['title'] as String? ?? '-',
      value: json['value'] as String? ?? '-',
      detail: json['detail'] as String? ?? '-',
    );
  }
}


class AdminUserBehaviorMetricData {
  AdminUserBehaviorMetricData({required this.key, required this.label, required this.value});

  final String key;
  final String label;
  final String value;

  factory AdminUserBehaviorMetricData.fromJson(Map<String, dynamic> json) {
    return AdminUserBehaviorMetricData(
      key: json['key'] as String? ?? '',
      label: json['label'] as String? ?? '-',
      value: json['value'] as String? ?? '-',
    );
  }
}

class AdminUserBehaviorFunnelData {
  AdminUserBehaviorFunnelData({required this.label, required this.count, required this.rate});

  final String label;
  final int count;
  final int rate;

  factory AdminUserBehaviorFunnelData.fromJson(Map<String, dynamic> json) {
    return AdminUserBehaviorFunnelData(
      label: json['label'] as String? ?? '-',
      count: json['count'] as int? ?? 0,
      rate: json['rate'] as int? ?? 0,
    );
  }
}

class AdminUserBehaviorDistributionData {
  AdminUserBehaviorDistributionData({
    required this.label,
    required this.count,
    this.percentage,
  });

  final String label;
  final int count;
  final int? percentage;

  factory AdminUserBehaviorDistributionData.fromJson(Map<String, dynamic> json) {
    return AdminUserBehaviorDistributionData(
      label: json['label'] as String? ?? '-',
      count: json['count'] as int? ?? 0,
      percentage: json['percentage'] as int?,
    );
  }
}

class AdminUserBehaviorWeeklyTrendData {
  AdminUserBehaviorWeeklyTrendData({required this.label, required this.primary, required this.secondary});

  final String label;
  final int primary;
  final int secondary;

  factory AdminUserBehaviorWeeklyTrendData.fromJson(Map<String, dynamic> json) {
    return AdminUserBehaviorWeeklyTrendData(
      label: json['label'] as String? ?? '-',
      primary: json['primary'] as int? ?? 0,
      secondary: json['secondary'] as int? ?? 0,
    );
  }
}

class AdminUserBehaviorNotificationStatData {
  AdminUserBehaviorNotificationStatData({
    required this.label,
    required this.count,
    required this.percentage,
    required this.iconKey,
  });

  final String label;
  final int count;
  final int percentage;
  final String iconKey;

  factory AdminUserBehaviorNotificationStatData.fromJson(Map<String, dynamic> json) {
    return AdminUserBehaviorNotificationStatData(
      label: json['label'] as String? ?? '-',
      count: json['count'] as int? ?? 0,
      percentage: json['percentage'] as int? ?? 0,
      iconKey: json['icon_key'] as String? ?? 'notifications',
    );
  }
}

class AdminUserBehaviorDropOffData {
  AdminUserBehaviorDropOffData({required this.label, required this.count, required this.rate});

  final String label;
  final int count;
  final int rate;

  factory AdminUserBehaviorDropOffData.fromJson(Map<String, dynamic> json) {
    return AdminUserBehaviorDropOffData(
      label: json['label'] as String? ?? '-',
      count: json['count'] as int? ?? 0,
      rate: json['rate'] as int? ?? 0,
    );
  }
}

class AdminUserBehaviorOverviewData {
  AdminUserBehaviorOverviewData({
    required this.generatedAt,
    required this.metrics,
    required this.funnelSteps,
    required this.sessionDurations,
    required this.returnPatterns,
    required this.weeklyActiveUsers,
    required this.featureFrequency,
    required this.notificationStats,
    required this.dropOff,
    required this.activeUserInsight,
    required this.sessionInsight,
    required this.returnInsight,
  });

  final String generatedAt;
  final List<AdminUserBehaviorMetricData> metrics;
  final List<AdminUserBehaviorFunnelData> funnelSteps;
  final List<AdminUserBehaviorDistributionData> sessionDurations;
  final List<AdminUserBehaviorDistributionData> returnPatterns;
  final List<AdminUserBehaviorWeeklyTrendData> weeklyActiveUsers;
  final List<AdminUserBehaviorDistributionData> featureFrequency;
  final List<AdminUserBehaviorNotificationStatData> notificationStats;
  final List<AdminUserBehaviorDropOffData> dropOff;
  final String activeUserInsight;
  final String sessionInsight;
  final String returnInsight;

  factory AdminUserBehaviorOverviewData.fromJson(Map<String, dynamic> json) {
    return AdminUserBehaviorOverviewData(
      generatedAt: json['generated_at'] as String? ?? '',
      metrics: (json['metrics'] as List<dynamic>? ?? [])
          .map((item) => AdminUserBehaviorMetricData.fromJson(item as Map<String, dynamic>))
          .toList(),
      funnelSteps: (json['funnel_steps'] as List<dynamic>? ?? [])
          .map((item) => AdminUserBehaviorFunnelData.fromJson(item as Map<String, dynamic>))
          .toList(),
      sessionDurations: (json['session_durations'] as List<dynamic>? ?? [])
          .map((item) => AdminUserBehaviorDistributionData.fromJson(item as Map<String, dynamic>))
          .toList(),
      returnPatterns: (json['return_patterns'] as List<dynamic>? ?? [])
          .map((item) => AdminUserBehaviorDistributionData.fromJson(item as Map<String, dynamic>))
          .toList(),
      weeklyActiveUsers: (json['weekly_active_users'] as List<dynamic>? ?? [])
          .map((item) => AdminUserBehaviorWeeklyTrendData.fromJson(item as Map<String, dynamic>))
          .toList(),
      featureFrequency: (json['feature_frequency'] as List<dynamic>? ?? [])
          .map((item) => AdminUserBehaviorDistributionData.fromJson(item as Map<String, dynamic>))
          .toList(),
      notificationStats: (json['notification_stats'] as List<dynamic>? ?? [])
          .map((item) => AdminUserBehaviorNotificationStatData.fromJson(item as Map<String, dynamic>))
          .toList(),
      dropOff: (json['drop_off'] as List<dynamic>? ?? [])
          .map((item) => AdminUserBehaviorDropOffData.fromJson(item as Map<String, dynamic>))
          .toList(),
      activeUserInsight: json['active_user_insight'] as String? ?? '-',
      sessionInsight: json['session_insight'] as String? ?? '-',
      returnInsight: json['return_insight'] as String? ?? '-',
    );
  }
}

class AdminActivityLogOverviewData {
  AdminActivityLogOverviewData({
    required this.generatedAt,
    required this.totalCount,
    required this.counts,
    required this.activities,
    required this.insights,
  });

  final String generatedAt;
  final int totalCount;
  final List<AdminActivityCountData> counts;
  final List<AdminActivityLogData> activities;
  final List<AdminActivityInsightData> insights;

  factory AdminActivityLogOverviewData.fromJson(Map<String, dynamic> json) {
    return AdminActivityLogOverviewData(
      generatedAt: json['generated_at'] as String? ?? '',
      totalCount: json['total_count'] as int? ?? 0,
      counts: (json['counts'] as List<dynamic>? ?? [])
          .map((item) => AdminActivityCountData.fromJson(item as Map<String, dynamic>))
          .toList(),
      activities: (json['activities'] as List<dynamic>? ?? [])
          .map((item) => AdminActivityLogData.fromJson(item as Map<String, dynamic>))
          .toList(),
      insights: (json['insights'] as List<dynamic>? ?? [])
          .map((item) => AdminActivityInsightData.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }
}

class AdminDashboardApi {
  AdminDashboardApi({http.Client? client}) : _client = client ?? http.Client();

  static const String baseUrl = 'http://127.0.0.1:8000';
  final http.Client _client;

  Future<AdminDashboardOverviewData> fetchDashboardOverview() async {
    final response = await _client.get(Uri.parse('$baseUrl/api/v1/admin/dashboard/overview'));
    _ensureSuccess(response);
    final decoded = jsonDecode(response.body) as Map<String, dynamic>;
    return AdminDashboardOverviewData.fromJson(decoded);
  }

  Future<AdminParkingAnalysisOverviewData> fetchParkingAnalysisOverview() async {
    final response = await _client.get(Uri.parse('$baseUrl/api/v1/admin/parking-analysis/overview'));
    _ensureSuccess(response);
    final decoded = jsonDecode(response.body) as Map<String, dynamic>;
    return AdminParkingAnalysisOverviewData.fromJson(decoded);
  }

  Future<AdminPredictionAnalysisOverviewData> fetchPredictionAnalysisOverview() async {
    final response = await _client.get(Uri.parse('$baseUrl/api/v1/admin/prediction-analysis/overview'));
    _ensureSuccess(response);
    final decoded = jsonDecode(response.body) as Map<String, dynamic>;
    return AdminPredictionAnalysisOverviewData.fromJson(decoded);
  }


  Future<AdminUserBehaviorOverviewData> fetchUserBehaviorOverview() async {
    final response = await _client.get(Uri.parse('$baseUrl/api/v1/admin/user-behavior/overview'));
    _ensureSuccess(response);
    final decoded = jsonDecode(response.body) as Map<String, dynamic>;
    return AdminUserBehaviorOverviewData.fromJson(decoded);
  }

  Future<AdminActivityLogOverviewData> fetchActivityLogOverview() async {
    final response = await _client.get(Uri.parse('$baseUrl/api/v1/admin/activity-log/overview'));
    _ensureSuccess(response);
    final decoded = jsonDecode(response.body) as Map<String, dynamic>;
    return AdminActivityLogOverviewData.fromJson(decoded);
  }

  Future<List<AdminParkingLotItem>> fetchParkingLots() async {
    final response = await _client.get(Uri.parse('$baseUrl/api/v1/parking/lots'));
    _ensureSuccess(response);
    final decoded = jsonDecode(response.body) as Map<String, dynamic>;
    final items = decoded['items'] as List<dynamic>? ?? [];
    return items.map((item) => AdminParkingLotItem.fromJson(item as Map<String, dynamic>)).toList();
  }

  Future<AdminCurrentStatusItem> fetchCurrentStatus({int parkingLotId = 1}) async {
    final response = await _client.get(Uri.parse('$baseUrl/api/v1/parking/current/$parkingLotId'));
    _ensureSuccess(response);
    final decoded = jsonDecode(response.body) as Map<String, dynamic>;
    return AdminCurrentStatusItem.fromJson(decoded);
  }

  Future<List<AdminPredictionItem>> fetchPredictions({int parkingLotId = 1, int limit = 24}) async {
    final response = await _client.get(Uri.parse('$baseUrl/api/v1/predictions/$parkingLotId?limit=$limit'));
    _ensureSuccess(response);
    final decoded = jsonDecode(response.body) as Map<String, dynamic>;
    final items = decoded['items'] as List<dynamic>? ?? [];
    return items.map((item) => AdminPredictionItem.fromJson(item as Map<String, dynamic>)).toList();
  }

  void _ensureSuccess(http.Response response) {
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('API 요청 실패: ${response.statusCode}');
    }
  }
}

bool _asBool(dynamic value) {
  if (value is bool) return value;
  if (value is int) return value != 0;
  if (value is String) {
    final lower = value.toLowerCase();
    return lower == 'true' || lower == '1';
  }
  return false;
}
