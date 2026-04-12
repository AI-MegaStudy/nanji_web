import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../Model/admin_models.dart';
import '../Service/admin_dashboard_api.dart';

class UserBehaviorViewModel extends ChangeNotifier {
  UserBehaviorViewModel({AdminDashboardApi? api}) : _api = api ?? AdminDashboardApi() {
    load();
  }

  final AdminDashboardApi _api;

  bool _isLoading = true;
  String? _errorMessage;
  List<AdminMetric> _metrics = const [];
  List<FunnelStepData> _funnelSteps = const [];
  List<DistributionItem> _sessionDurations = const [];
  List<DistributionItem> _returnPatterns = const [];
  List<WeeklyTrendPoint> _weeklyActiveUsers = const [];
  List<DistributionItem> _featureFrequency = const [];
  List<NotificationSettingStat> _notificationStats = const [];
  List<DropOffItem> _dropOff = const [];
  String _activeUserInsight = '-';
  String _sessionInsight = '-';
  String _returnInsight = '-';

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<AdminMetric> get metrics => _metrics;
  List<FunnelStepData> get funnelSteps => _funnelSteps;
  List<DistributionItem> get sessionDurations => _sessionDurations;
  List<DistributionItem> get returnPatterns => _returnPatterns;
  List<WeeklyTrendPoint> get weeklyActiveUsers => _weeklyActiveUsers;
  List<DistributionItem> get featureFrequency => _featureFrequency;
  List<NotificationSettingStat> get notificationStats => _notificationStats;
  List<DropOffItem> get dropOff => _dropOff;

  String get pageTitle => '사용자 행동';
  String get pageSubtitle => '재방문, 기능 전환율, 사용자 흐름을 살펴보는 화면입니다.';

  String get totalActiveUsersText {
    final metric = _metrics.where((item) => item.label == '총 활성 사용자').cast<AdminMetric?>().firstWhere((item) => item != null, orElse: () => null);
    return metric?.value ?? '0';
  }

  String get returnRateText {
    final metric = _metrics.where((item) => item.label == '재방문율').cast<AdminMetric?>().firstWhere((item) => item != null, orElse: () => null);
    return metric?.value ?? '0.0%';
  }

  String get activeUserInsight => _activeUserInsight;
  String get sessionInsight => _sessionInsight;
  String get returnInsight => _returnInsight;

  Future<void> load() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final overview = await _api.fetchUserBehaviorOverview();
      _metrics = overview.metrics
          .map(
            (item) => AdminMetric(
              label: item.label,
              value: item.value,
              icon: _metricIcon(item.key),
              color: _metricColor(item.key),
            ),
          )
          .toList();
      _funnelSteps = overview.funnelSteps
          .map((item) => FunnelStepData(label: item.label, count: item.count, rate: item.rate))
          .toList();
      _sessionDurations = overview.sessionDurations
          .map((item) => DistributionItem(label: item.label, count: item.count, color: _sessionDurationColor(item.label), percentage: item.percentage))
          .toList();
      _returnPatterns = overview.returnPatterns
          .map((item) => DistributionItem(label: item.label, count: item.count, color: _returnPatternColor(item.label), percentage: item.percentage))
          .toList();
      _weeklyActiveUsers = overview.weeklyActiveUsers
          .map((item) => WeeklyTrendPoint(label: item.label, primary: item.primary, secondary: item.secondary))
          .toList();
      _featureFrequency = overview.featureFrequency
          .map((item) => DistributionItem(label: item.label, count: item.count, color: _featureColor(item.label), percentage: item.percentage))
          .toList();
      _notificationStats = overview.notificationStats
          .map(
            (item) => NotificationSettingStat(
              label: item.label,
              count: item.count,
              percentage: item.percentage,
              icon: _notificationIcon(item.iconKey),
              color: _notificationColor(item.iconKey),
              background: _notificationBackground(item.iconKey),
            ),
          )
          .toList();
      _dropOff = overview.dropOff
          .map((item) => DropOffItem(label: item.label, count: item.count, rate: item.rate))
          .toList();
      _activeUserInsight = overview.activeUserInsight;
      _sessionInsight = overview.sessionInsight;
      _returnInsight = overview.returnInsight;
    } catch (error) {
      _errorMessage = error.toString();
      _metrics = const [];
      _funnelSteps = const [];
      _sessionDurations = const [];
      _returnPatterns = const [];
      _weeklyActiveUsers = const [];
      _featureFrequency = const [];
      _notificationStats = const [];
      _dropOff = const [];
      _activeUserInsight = '-';
      _sessionInsight = '-';
      _returnInsight = '-';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  IconData _metricIcon(String key) {
    switch (key) {
      case 'active_users':
        return Icons.people_outline_rounded;
      case 'return_rate':
        return Icons.refresh_rounded;
      case 'avg_session_time':
        return Icons.schedule_rounded;
      case 'notification_rate':
        return Icons.notifications_none_rounded;
      default:
        return Icons.analytics_outlined;
    }
  }

  Color _metricColor(String key) {
    switch (key) {
      case 'active_users':
        return const Color(0xFF2563EB);
      case 'return_rate':
        return const Color(0xFF16A34A);
      case 'avg_session_time':
        return const Color(0xFF9333EA);
      case 'notification_rate':
        return const Color(0xFFEA580C);
      default:
        return const Color(0xFF6B7280);
    }
  }

  Color _sessionDurationColor(String label) {
    switch (label) {
      case '< 1분':
        return const Color(0xFFE5E7EB);
      case '1-3분':
        return const Color(0xFFB5E0F5);
      case '3-5분':
        return const Color(0xFF7DD3FC);
      case '5-10분':
        return const Color(0xFF38BDF8);
      default:
        return const Color(0xFF0284C7);
    }
  }

  Color _returnPatternColor(String label) {
    switch (label) {
      case '신규 사용자':
        return const Color(0xFF9CA3AF);
      case '재방문 (1회)':
        return const Color(0xFF6FA05C);
      case '재방문 (2-5회)':
        return const Color(0xFF84CC16);
      default:
        return const Color(0xFFA3E635);
    }
  }

  Color _featureColor(String label) {
    switch (label) {
      case '혼잡도 조회':
        return const Color(0xFFB5E0F5);
      case '예측 조회':
        return const Color(0xFF7DD3FC);
      case '지도 보기':
        return const Color(0xFF6FA05C);
      case '출발 타이밍':
        return const Color(0xFFFB923C);
      default:
        return const Color(0xFFFDE68A);
    }
  }

  IconData _notificationIcon(String key) {
    switch (key) {
      case 'schedule':
        return Icons.schedule_rounded;
      case 'route':
        return Icons.route_outlined;
      default:
        return Icons.notifications_active_outlined;
    }
  }

  Color _notificationColor(String key) {
    switch (key) {
      case 'schedule':
        return const Color(0xFFEA580C);
      case 'route':
        return const Color(0xFF16A34A);
      default:
        return const Color(0xFF2563EB);
    }
  }

  Color _notificationBackground(String key) {
    switch (key) {
      case 'schedule':
        return const Color(0xFFFFF7ED);
      case 'route':
        return const Color(0xFFF0FDF4);
      default:
        return const Color(0xFFEFF6FF);
    }
  }
}
