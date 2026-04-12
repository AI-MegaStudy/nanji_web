import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../Model/admin_models.dart';
import '../Service/admin_dashboard_api.dart';

class FavoriteRankItem {
  const FavoriteRankItem({
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
}

class ParkingAnalysisViewModel extends ChangeNotifier {
  ParkingAnalysisViewModel({AdminDashboardApi? api}) : _api = api ?? AdminDashboardApi() {
    load();
  }

  final AdminDashboardApi _api;

  bool _isLoading = true;
  String? _errorMessage;
  List<AdminMetric> _metrics = const [];
  List<ParkingAnalysisLotRow> _lotRows = const [];
  List<DistributionItem> _selectionData = const [];
  List<DistributionItem> _mapUsageData = const [];
  List<DistributionItem> _avgDurationData = const [];
  List<WeeklyTrendPoint> _weeklyParkingData = const [];
  List<FavoriteRankItem> _favoriteRanking = const [];

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<AdminMetric> get metrics => _metrics;
  List<ParkingAnalysisLotRow> get lotRows => _lotRows;
  List<DistributionItem> get selectionData => _selectionData;
  List<DistributionItem> get mapUsageData => _mapUsageData;
  List<DistributionItem> get avgDurationData => _avgDurationData;
  List<WeeklyTrendPoint> get weeklyParkingData => _weeklyParkingData;
  List<FavoriteRankItem> get favoriteRanking => _favoriteRanking;

  String get pageTitle => '주차장 분석';
  String get pageSubtitle => '주차장별 선택, 지도 확인, 즐겨찾기 흐름을 분석하는 화면입니다.';

  Future<void> load() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final overview = await _api.fetchParkingAnalysisOverview();

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

      _lotRows = overview.lotRows
          .map(
            (row) => ParkingAnalysisLotRow(
              id: row.id,
              displayName: row.displayName,
              totalSpaces: row.totalSpaces,
              supportsRealtime: row.supportsRealtime,
              supportsPrediction: row.supportsPrediction,
              availableSpaces: row.availableSpaces,
              occupiedSpaces: row.occupiedSpaces,
              occupancyRate: row.occupancyRate,
              statusLabel: row.statusLabel,
              hasRealtimeData: row.hasRealtimeData,
            ),
          )
          .toList();

      _selectionData = overview.selectionData
          .map(
            (item) => DistributionItem(
              label: item.label,
              count: item.count,
              color: _selectionColor(item.label),
            ),
          )
          .toList();

      _mapUsageData = overview.mapUsageData
          .map(
            (item) => DistributionItem(
              label: item.label,
              count: item.count,
              color: item.label == '지도 확인' ? const Color(0xFF6FA05C) : const Color(0xFFE5E7EB),
            ),
          )
          .toList();

      _avgDurationData = overview.avgDurationData
          .map(
            (item) => DistributionItem(
              label: item.label,
              count: item.count,
              color: const Color(0xFFFB923C),
            ),
          )
          .toList();

      _weeklyParkingData = overview.weeklyParkingData
          .map(
            (point) => WeeklyTrendPoint(
              label: point.label,
              primary: point.primary,
              secondary: point.secondary,
              tertiary: point.tertiary,
            ),
          )
          .toList();

      _favoriteRanking = overview.favoriteRanking
          .map(
            (item) => FavoriteRankItem(
              rank: item.rank,
              name: item.name,
              count: item.count,
              trend: item.trend,
              change: item.change,
            ),
          )
          .toList();
    } catch (error) {
      _errorMessage = error.toString();
      _metrics = const [];
      _lotRows = const [];
      _selectionData = const [];
      _mapUsageData = const [];
      _avgDurationData = const [];
      _weeklyParkingData = const [];
      _favoriteRanking = const [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  IconData _metricIcon(String key) {
    switch (key) {
      case 'favorite_total':
        return Icons.star_border_rounded;
      case 'map_usage_rate':
        return Icons.place_outlined;
      case 'top_parking':
        return Icons.visibility_outlined;
      default:
        return Icons.insights_outlined;
    }
  }

  Color _metricColor(String key) {
    switch (key) {
      case 'favorite_total':
        return const Color(0xFFD97706);
      case 'map_usage_rate':
        return const Color(0xFF0891B2);
      case 'top_parking':
        return const Color(0xFF9333EA);
      default:
        return const Color(0xFF6B7280);
    }
  }

  Color _selectionColor(String label) {
    const palette = [
      Color(0xFFB5E0F5),
      Color(0xFF7DD3FC),
      Color(0xFF38BDF8),
      Color(0xFF0EA5E9),
      Color(0xFF0284C7),
    ];
    final index = label.hashCode.abs() % palette.length;
    return palette[index];
  }

  Color badgeColor(String label) {
    switch (label) {
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

  String supportLabel(ParkingAnalysisLotRow row) {
    if (row.supportsRealtime && row.supportsPrediction) {
      return '실시간 + 예측';
    }
    if (row.supportsRealtime) {
      return '실시간';
    }
    if (row.supportsPrediction) {
      return '예측';
    }
    return '기본 정보';
  }
}
