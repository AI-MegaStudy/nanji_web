import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../Model/admin_models.dart';
import '../Service/admin_dashboard_api.dart';

class PredictionAnalysisViewModel extends ChangeNotifier {
  PredictionAnalysisViewModel({AdminDashboardApi? api}) : _api = api ?? AdminDashboardApi() {
    load();
  }

  final AdminDashboardApi _api;

  bool _isLoading = true;
  String? _errorMessage;
  List<AdminMetric> _metrics = const [];
  List<DistributionItem> _predictionByHour = const [];
  List<DistributionItem> _departureTiming = const [];
  List<WeeklyTrendPoint> _hourlyPattern = const [];
  List<WeeklyTrendPoint> _weeklyPrediction = const [];
  List<AccuracyPoint> _accuracyTrend = const [];
  List<PostActionItem> _postActions = const [];
  List<CongestionPredictionItem> _congestionPrediction = const [];
  String _predictionInsight = '데이터를 불러오는 중입니다.';
  String _departureInsight = '데이터를 불러오는 중입니다.';
  String _hourlyInsight = '데이터를 불러오는 중입니다.';
  String _congestionInsight = '데이터를 불러오는 중입니다.';

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<AdminMetric> get metrics => _metrics;
  List<DistributionItem> get predictionByHour => _predictionByHour;
  List<DistributionItem> get departureTiming => _departureTiming;
  List<WeeklyTrendPoint> get hourlyPattern => _hourlyPattern;
  List<WeeklyTrendPoint> get weeklyPrediction => _weeklyPrediction;
  List<AccuracyPoint> get accuracyTrend => _accuracyTrend;
  List<PostActionItem> get postActions => _postActions;
  List<CongestionPredictionItem> get congestionPrediction => _congestionPrediction;

  String get pageTitle => '예측 분석';
  String get pageSubtitle => '예측 결과, 정확도, 시간대별 패턴을 확인하는 화면입니다.';
  String get predictionInsight => _predictionInsight;
  String get departureInsight => _departureInsight;
  String get hourlyInsight => _hourlyInsight;
  String get congestionInsight => _congestionInsight;

  Future<void> load() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final overview = await _api.fetchPredictionAnalysisOverview();

      _metrics = overview.metrics
          .map(
            (metric) => AdminMetric(
              label: metric.label,
              value: metric.value,
              icon: _metricIcon(metric.key),
              color: _metricColor(metric.key),
            ),
          )
          .toList();

      _predictionByHour = overview.predictionByHour
          .map(
            (item) => DistributionItem(
              label: item.label,
              count: item.count,
              color: _distributionColor(item.label),
            ),
          )
          .toList();

      _departureTiming = overview.departureTiming
          .map(
            (item) => DistributionItem(
              label: item.label,
              count: item.count,
              color: _departureColor(item.label),
            ),
          )
          .toList();

      _hourlyPattern = overview.hourlyPattern
          .map(
            (item) => WeeklyTrendPoint(
              label: item.label,
              primary: item.primary,
              secondary: item.secondary,
              tertiary: item.tertiary,
            ),
          )
          .toList();

      _weeklyPrediction = overview.weeklyPrediction
          .map(
            (item) => WeeklyTrendPoint(
              label: item.label,
              primary: item.primary,
              secondary: item.secondary,
              tertiary: item.tertiary,
            ),
          )
          .toList();

      _accuracyTrend = overview.accuracyTrend
          .map(
            (item) => AccuracyPoint(
              label: item.label,
              accuracy: item.accuracy,
              usage: item.usage,
            ),
          )
          .toList();

      _postActions = overview.postActions
          .map(
            (item) => PostActionItem(
              label: item.label,
              count: item.count,
              rate: item.rate,
            ),
          )
          .toList();

      _congestionPrediction = overview.congestionPrediction
          .map(
            (item) => CongestionPredictionItem(
              label: item.label,
              prediction: item.prediction,
              noPrediction: item.noPrediction,
              color: _congestionColor(item.label),
            ),
          )
          .toList();

      _predictionInsight = overview.predictionInsight;
      _departureInsight = overview.departureInsight;
      _hourlyInsight = overview.hourlyInsight;
      _congestionInsight = overview.congestionInsight;
    } catch (error) {
      _errorMessage = error.toString();
      _metrics = const [];
      _predictionByHour = const [];
      _departureTiming = const [];
      _hourlyPattern = const [];
      _weeklyPrediction = const [];
      _accuracyTrend = const [];
      _postActions = const [];
      _congestionPrediction = const [];
      _predictionInsight = '데이터를 불러오지 못했습니다.';
      _departureInsight = '데이터를 불러오지 못했습니다.';
      _hourlyInsight = '데이터를 불러오지 못했습니다.';
      _congestionInsight = '데이터를 불러오지 못했습니다.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  IconData _metricIcon(String key) {
    switch (key) {
      case 'prediction_views':
        return Icons.trending_up_rounded;
      case 'top_horizon':
        return Icons.ads_click_rounded;
      case 'departure_views':
        return Icons.schedule_rounded;
      case 'prediction_accuracy':
        return Icons.calendar_month_rounded;
      default:
        return Icons.insights_outlined;
    }
  }

  Color _metricColor(String key) {
    switch (key) {
      case 'prediction_views':
        return const Color(0xFF2563EB);
      case 'top_horizon':
        return const Color(0xFFEA580C);
      case 'departure_views':
        return const Color(0xFF16A34A);
      case 'prediction_accuracy':
        return const Color(0xFF9333EA);
      default:
        return const Color(0xFF6B7280);
    }
  }

  Color _distributionColor(String label) {
    final hour = int.tryParse(label.replaceAll('시', '').trim());
    if (hour == null) return const Color(0xFF0284C7);
    if (hour < 8) return const Color(0xFFBFDBFE);
    if (hour < 12) return const Color(0xFF93C5FD);
    if (hour < 18) return const Color(0xFF60A5FA);
    if (hour < 22) return const Color(0xFF3B82F6);
    return const Color(0xFF1D4ED8);
  }

  Color _departureColor(String label) {
    if (label.startsWith('30분')) return const Color(0xFF6FA05C);
    if (label.startsWith('1시간')) return const Color(0xFF84CC16);
    if (label.startsWith('2시간')) return const Color(0xFFA3E635);
    return const Color(0xFFD9F99D);
  }

  Color _congestionColor(String label) {
    switch (label) {
      case '여유':
        return const Color(0xFF6FA05C);
      case '보통':
        return const Color(0xFFE59548);
      case '혼잡':
        return const Color(0xFFC85A54);
      default:
        return const Color(0xFF9CA3AF);
    }
  }
}
