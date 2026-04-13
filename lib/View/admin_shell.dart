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

    return Scaffold(
      body: Column(
        children: [
          _Header(
            title: vm.selectedItem.title,
            subtitle: vm.selectedItem.subtitle,
            autoRefresh: vm.autoRefresh,
            onToggleRefresh: vm.toggleAutoRefresh,
          ),
          _TopNavBar(
            items: vm.navItems,
            selectedIndex: vm.selectedIndex,
            onTap: vm.selectTab,
          ),
          Expanded(
            child: _SelectedPage(index: vm.selectedIndex),
          ),
        ],
      ),
    );
  }
}

class _SelectedPage extends StatelessWidget {
  const _SelectedPage({required this.index});

  final int index;

  @override
  Widget build(BuildContext context) {
    switch (index) {
      case 0:
        return const AdminDashboardPage();
      case 1:
        return const UserBehaviorPage();
      case 2:
        return const ParkingAnalysisPage();
      case 3:
        return const PredictionAnalysisPage();
      case 4:
        return const ActivityLogPage();
      default:
        return const AdminDashboardPage();
    }
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.title,
    required this.subtitle,
    required this.autoRefresh,
    required this.onToggleRefresh,
  });

  final String title;
  final String subtitle;
  final bool autoRefresh;
  final VoidCallback onToggleRefresh;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final isCompact = width < 820;

    return Container(
      color: const Color(0xFFB5E0F5),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: SafeArea(
        bottom: false,
        child: isCompact
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.35),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(Icons.settings_rounded, size: 28),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title,
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF111827),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              subtitle,
                              style: const TextStyle(
                                fontSize: 14,
                                color: Color(0xFF374151),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  FilledButton.icon(
                    onPressed: onToggleRefresh,
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.white.withValues(
                        alpha: autoRefresh ? 0.72 : 0.42,
                      ),
                      foregroundColor: const Color(0xFF111827),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: 0,
                    ),
                    icon: Icon(
                      autoRefresh
                          ? Icons.refresh_rounded
                          : Icons.refresh_outlined,
                    ),
                    label: Text(
                      autoRefresh ? '자동 새로고침 켜짐' : '자동 새로고침 꺼짐',
                    ),
                  ),
                ],
              )
            : Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.35),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(Icons.settings_rounded, size: 28),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF111827),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          subtitle,
                          style: const TextStyle(
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
                      backgroundColor: Colors.white.withValues(
                        alpha: autoRefresh ? 0.72 : 0.42,
                      ),
                      foregroundColor: const Color(0xFF111827),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: 0,
                    ),
                    icon: Icon(
                      autoRefresh
                          ? Icons.refresh_rounded
                          : Icons.refresh_outlined,
                    ),
                    label: Text(
                      autoRefresh ? '자동 새로고침 켜짐' : '자동 새로고침 꺼짐',
                    ),
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
      width: double.infinity,
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 18),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1440),
          child: Wrap(
            spacing: 12,
            runSpacing: 12,
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
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          decoration: BoxDecoration(
            color: isActive ? const Color(0xFFEAF7FC) : const Color(0xFFF9FAFB),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color:
                  isActive ? const Color(0xFFB5E0F5) : const Color(0xFFE5E7EB),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(item.icon,
                  size: 18,
                  color: isActive
                      ? const Color(0xFF111827)
                      : const Color(0xFF6B7280)),
              const SizedBox(width: 8),
              Text(
                item.label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                  color: isActive
                      ? const Color(0xFF111827)
                      : const Color(0xFF6B7280),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
