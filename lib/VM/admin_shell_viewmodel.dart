import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../Model/admin_models.dart';

class AdminShellViewModel extends ChangeNotifier {
  int _selectedIndex = 0;
  bool _autoRefresh = true;

  final List<AdminNavItem> navItems = const [
    AdminNavItem(label: '대시보드', icon: Icons.dashboard_rounded),
    AdminNavItem(label: '사용자 행동', icon: Icons.people_alt_rounded),
    AdminNavItem(label: '주차장 분석', icon: Icons.local_parking_rounded),
    AdminNavItem(label: '예측 분석', icon: Icons.trending_up_rounded),
    AdminNavItem(label: '실시간 활동', icon: Icons.bolt_rounded),
  ];

  int get selectedIndex => _selectedIndex;
  bool get autoRefresh => _autoRefresh;

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
