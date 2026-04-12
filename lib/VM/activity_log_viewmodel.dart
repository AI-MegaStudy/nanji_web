import 'package:flutter/foundation.dart';

import '../Model/admin_models.dart';
import '../Service/admin_dashboard_api.dart';

class ActivityLogViewModel extends ChangeNotifier {
  ActivityLogViewModel({AdminDashboardApi? api}) : _api = api ?? AdminDashboardApi() {
    load();
  }

  final AdminDashboardApi _api;

  bool _isLoading = true;
  String? _errorMessage;
  String _selectedFilter = 'all';
  List<ActivityFilterItem> _filters = const [
    ActivityFilterItem(value: 'all', label: '전체'),
    ActivityFilterItem(value: 'view', label: '혼잡도 조회'),
    ActivityFilterItem(value: 'prediction', label: '예측 조회'),
    ActivityFilterItem(value: 'timing', label: '출발 타이밍'),
    ActivityFilterItem(value: 'map', label: '지도 보기'),
    ActivityFilterItem(value: 'favorite', label: '즐겨찾기'),
    ActivityFilterItem(value: 'notification', label: '알림 설정'),
    ActivityFilterItem(value: 'login', label: '로그인'),
  ];
  List<ActivityLogItem> _activities = const [];
  List<AdminActivityInsightCard> _insights = const [];
  Map<String, int> _countsByType = const {};
  int _totalCount = 0;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get selectedFilter => _selectedFilter;
  List<ActivityFilterItem> get filters => _filters;
  List<ActivityLogItem> get activities => _activities;
  List<AdminActivityInsightCard> get insights => _insights;
  int get totalCount => _totalCount;

  String get pageTitle => '실시간 활동';
  String get pageSubtitle => '최근 사용자 활동과 운영 이벤트를 모니터링하는 화면입니다.';

  Future<void> load() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final overview = await _api.fetchActivityLogOverview();
      _totalCount = overview.totalCount;
      _countsByType = {
        for (final item in overview.counts) item.key: item.count,
      };
      _activities = overview.activities
          .map(
            (item) => ActivityLogItem(
              time: item.time,
              action: item.action,
              user: item.user,
              detail: item.detail,
              type: item.type,
            ),
          )
          .toList();
      _insights = overview.insights
          .map(
            (item) => AdminActivityInsightCard(
              title: item.title,
              value: item.value,
              detail: item.detail,
            ),
          )
          .toList();
    } catch (error) {
      _errorMessage = error.toString();
      _totalCount = 0;
      _countsByType = const {};
      _activities = const [];
      _insights = const [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void selectFilter(String value) {
    _selectedFilter = value;
    notifyListeners();
  }

  List<ActivityLogItem> get filteredActivities {
    if (_selectedFilter == 'all') {
      return _activities;
    }
    return _activities.where((item) => item.type == _selectedFilter).toList();
  }

  int countByType(String type) {
    return _countsByType[type] ?? 0;
  }
}

class AdminActivityInsightCard {
  const AdminActivityInsightCard({required this.title, required this.value, required this.detail});

  final String title;
  final String value;
  final String detail;
}
