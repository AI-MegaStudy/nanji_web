import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../Model/admin_models.dart';
import '../VM/admin_shell_viewmodel.dart';
import 'pages/activity_log_page.dart';
import 'pages/admin_dashboard_page.dart';
import 'pages/parking_analysis_page.dart';
import 'pages/prediction_analysis_page.dart';
import 'pages/user_behavior_page.dart';

class AdminShell extends StatelessWidget {
  const AdminShell({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AdminShellViewModel(),
      child: const _AdminShellView(),
    );
  }
}

class _AdminShellView extends StatelessWidget {
  const _AdminShellView();

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<AdminShellViewModel>();

    final pages = const [
      AdminDashboardPage(),
      UserBehaviorPage(),
      ParkingAnalysisPage(),
      PredictionAnalysisPage(),
      ActivityLogPage(),
    ];

    return Scaffold(
      body: Column(
        children: [
          _Header(
            autoRefresh: vm.autoRefresh,
            onToggleRefresh: vm.toggleAutoRefresh,
          ),
          _TopNavBar(
            items: vm.navItems,
            selectedIndex: vm.selectedIndex,
            onTap: vm.selectTab,
          ),
          Expanded(
            child: IndexedStack(
              index: vm.selectedIndex,
              children: pages,
            ),
          ),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.autoRefresh,
    required this.onToggleRefresh,
  });

  final bool autoRefresh;
  final VoidCallback onToggleRefresh;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFB5E0F5),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: SafeArea(
        bottom: false,
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.35),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(Icons.settings_rounded, size: 28),
            ),
            const SizedBox(width: 16),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '자리난지 서비스 운영 대시보드',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF111827),
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    '사용자 이용 분석 및 서비스 모니터링',
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF374151),
                    ),
                  ),
                ],
              ),
            ),
            FilledButton.icon(
              onPressed: onToggleRefresh,
              style: FilledButton.styleFrom(
                backgroundColor: Colors.white.withOpacity(autoRefresh ? 0.72 : 0.42),
                foregroundColor: const Color(0xFF111827),
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                elevation: 0,
              ),
              icon: Icon(autoRefresh ? Icons.refresh_rounded : Icons.refresh_outlined),
              label: Text(autoRefresh ? '자동 새로고침 켜짐' : '자동 새로고침 꺼짐'),
            ),
          ],
        ),
      ),
    );
  }
}

class _TopNavBar extends StatelessWidget {
  const _TopNavBar({
    required this.items,
    required this.selectedIndex,
    required this.onTap,
  });

  final List<AdminNavItem> items;
  final int selectedIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            for (var i = 0; i < items.length; i++)
              _NavTab(
                item: items[i],
                isActive: i == selectedIndex,
                onTap: () => onTap(i),
              ),
          ],
        ),
      ),
    );
  }
}

class _NavTab extends StatelessWidget {
  const _NavTab({
    required this.item,
    required this.isActive,
    required this.onTap,
  });

  final AdminNavItem item;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isActive ? const Color(0xFFB5E0F5) : Colors.transparent,
              width: 3,
            ),
          ),
        ),
        child: Row(
          children: [
            Icon(item.icon, size: 18, color: isActive ? const Color(0xFF111827) : const Color(0xFF6B7280)),
            const SizedBox(width: 8),
            Text(
              item.label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                color: isActive ? const Color(0xFF111827) : const Color(0xFF6B7280),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
