import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../Model/admin_models.dart';
import '../Service/admin_dashboard_api.dart';

class AdminDashboardViewModel extends ChangeNotifier {
  AdminDashboardViewModel({AdminDashboardApi? api}) : _api = api ?? AdminDashboardApi() {
    load();
  }

  final AdminDashboardApi _api;

  bool _isLoading = true;
  String? _errorMessage;
  List<AdminMetric> _metrics = const [];
  List<ParkingSummaryItem> _parkingSummary = const [];
  List<FunnelStepData> _funnelSteps = const [];
  List<OperationalInsight> _insights = const [];
  List<HourlyUsagePoint> _hourlyUsage = const [];
  List<FeatureUsageSlice> _featureUsage = const [];
  String _parkingTitle = '난지 메인 주차장 현황';
  String _realtimeStatus = '정보 준비 중';
  double _realtimeOccupancy = 0;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<AdminMetric> get metrics => _metrics;
  List<ParkingSummaryItem> get parkingSummary => _parkingSummary;
  List<FunnelStepData> get funnelSteps => _funnelSteps;
  List<OperationalInsight> get insights => _insights;
  List<HourlyUsagePoint> get hourlyUsage => _hourlyUsage;
  List<FeatureUsageSlice> get featureUsage => _featureUsage;
  String get pageTitle => '대시보드';
  String get pageSubtitle => '서비스 운영 현황과 핵심 지표를 한눈에 확인할 수 있어요.';
  String get parkingTitle => _parkingTitle;
  String get realtimeStatus => _realtimeStatus;
  double get realtimeOccupancy => _realtimeOccupancy;

  Future<void> load() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final overview = await _api.fetchDashboardOverview();

      final parking = overview.parkingOverview;
      _parkingTitle = parking.parkingLotName.replaceAll(' 메인', '');
      _realtimeStatus = _localizedCongestion(parking.congestionLevel, parking.hasRealtimeData);
      _realtimeOccupancy = parking.totalSpaces > 0
          ? (parking.occupiedSpaces / parking.totalSpaces).clamp(0, 1)
          : 0;

      _parkingSummary = [
        ParkingSummaryItem(label: '총 주차면', value: '${parking.totalSpaces}', unit: '대'),
        ParkingSummaryItem(label: '남은 자리', value: '${parking.availableSpaces}', unit: '대'),
        ParkingSummaryItem(label: '현재 주차', value: '${parking.occupiedSpaces}', unit: '대'),
        ParkingSummaryItem(label: '사용률', value: '${parking.occupancyRate.round()}', unit: '%'),
      ];

      _metrics = overview.metrics
          .map(
            (metric) => AdminMetric(
              label: metric.label,
              value: metric.displayValue,
              icon: _metricIcon(metric.key),
              color: _metricColor(metric.key),
            ),
          )
          .toList();

      _insights = overview.insights
          .map(
            (insight) => OperationalInsight(
              id: insight.id,
              type: insight.type,
              message: insight.message,
              time: insight.time,
            ),
          )
          .toList();

      _hourlyUsage = overview.hourlyUsage
          .map((point) => HourlyUsagePoint(hour: point.hour, value: point.value.toDouble()))
          .toList();

      _featureUsage = overview.featureUsage
          .map(
            (slice) => FeatureUsageSlice(
              name: slice.name,
              value: slice.value,
              color: _featureColor(slice.key),
            ),
          )
          .toList();

      _funnelSteps = overview.funnel
          .map(
            (item) => FunnelStepData(
              label: item.label,
              rate: item.rate,
              count: item.count,
            ),
          )
          .toList();
    } catch (error) {
      _errorMessage = error.toString();
      _metrics = const [];
      _parkingSummary = const [];
      _funnelSteps = const [];
      _insights = const [];
      _hourlyUsage = const [];
      _featureUsage = const [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  IconData _metricIcon(String key) {
    switch (key) {
      case 'today_visitors':
        return Icons.people_outline_rounded;
      case 'congestion_views':
        return Icons.visibility_outlined;
      case 'prediction_views':
        return Icons.trending_up_rounded;
      case 'departure_timing_views':
        return Icons.schedule_rounded;
      case 'map_views':
        return Icons.place_outlined;
      case 'favorites':
        return Icons.star_border_rounded;
      default:
        return Icons.insights_outlined;
    }
  }

  Color _metricColor(String key) {
    switch (key) {
      case 'today_visitors':
        return const Color(0xFF2563EB);
      case 'congestion_views':
        return const Color(0xFF9333EA);
      case 'prediction_views':
        return const Color(0xFFEA580C);
      case 'departure_timing_views':
        return const Color(0xFF22C55E);
      case 'map_views':
        return const Color(0xFF0891B2);
      case 'favorites':
        return const Color(0xFFD97706);
      default:
        return const Color(0xFF6B7280);
    }
  }

  Color _featureColor(String key) {
    switch (key) {
      case 'congestion_view':
        return const Color(0xFFB5E0F5);
      case 'prediction_view':
        return const Color(0xFF7DD3FC);
      case 'departure_timing_view':
        return const Color(0xFFFB923C);
      case 'map_view':
        return const Color(0xFF6FA05C);
      case 'favorite_add':
        return const Color(0xFFFDE68A);
      default:
        return const Color(0xFFD1D5DB);
    }
  }

  Color realtimeColor() {
    switch (_realtimeStatus) {
      case '여유':
        return const Color(0xFF6FA05C);
      case '보통':
        return const Color(0xFFE59548);
      case '혼잡':
      case '만차':
        return const Color(0xFFC85A54);
      default:
        return const Color(0xFF9CA3AF);
    }
  }

  String _localizedCongestion(String value, bool hasData) {
    if (!hasData) return '정보 준비 중';
    switch (value) {
      case 'free':
        return '여유';
      case 'normal':
        return '보통';
      case 'busy':
        return '혼잡';
      case 'full':
        return '만차';
      default:
        return '정보 준비 중';
    }
  }
}
