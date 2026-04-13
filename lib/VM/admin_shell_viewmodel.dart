import 'package:flutter/material.dart';
import '../Model/admin_models.dart';

class AdminShellViewModel extends ChangeNotifier {
  int _selectedIndex = 0;
  bool _autoRefresh = true;

  final List<AdminNavItem> navItems = const [
    AdminNavItem(
      label: '대시보드',
      icon: Icons.dashboard_rounded,
      title: '대시보드',
      subtitle: '서비스 운영 현황과 핵심 지표를 한눈에 확인할 수 있어요.',
    ),
    AdminNavItem(
      label: '사용자 행동',
      icon: Icons.people_alt_rounded,
      title: '사용자 행동',
      subtitle: '재방문, 기능 전환율, 사용자 흐름을 살펴보는 화면입니다.',
    ),
    AdminNavItem(
      label: '주차장 분석',
      icon: Icons.local_parking_rounded,
      title: '주차장 분석',
      subtitle: '주차장별 선택, 지도 확인, 즐겨찾기 흐름을 분석하는 화면입니다.',
    ),
    AdminNavItem(
      label: '예측 분석',
      icon: Icons.trending_up_rounded,
      title: '예측 분석',
      subtitle: '예측 결과, 정확도, 시간대별 패턴을 확인하는 화면입니다.',
    ),
    AdminNavItem(
      label: '실시간 활동',
      icon: Icons.bolt_rounded,
      title: '실시간 활동',
      subtitle: '최근 사용자 활동과 운영 이벤트를 모니터링하는 화면입니다.',
    ),
  ];

  int get selectedIndex => _selectedIndex;
  bool get autoRefresh => _autoRefresh;
  AdminNavItem get selectedItem => navItems[_selectedIndex];

  void selectTab(int index) {
    if (_selectedIndex == index) return;
    _selectedIndex = index;
    notifyListeners();
  }

  void toggleAutoRefresh() {
    _autoRefresh = !_autoRefresh;
    notifyListeners();
  }
}
