import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../Model/admin_models.dart';
import '../../VM/activity_log_viewmodel.dart';
import '../widgets/admin_widgets.dart';

class ActivityLogPage extends StatelessWidget {
  const ActivityLogPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ActivityLogViewModel(),
      child: const _ActivityLogView(),
    );
  }
}

class _ActivityLogView extends StatelessWidget {
  const _ActivityLogView();

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ActivityLogViewModel>();

    return Container(
      color: const Color(0xFFF3F4F6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PageHeader(title: vm.pageTitle, subtitle: vm.pageSubtitle),
          Expanded(
            child: vm.isLoading
                ? const Center(child: CircularProgressIndicator())
                : vm.errorMessage != null
                    ? _ActivityLogErrorView(message: vm.errorMessage!, onRetry: vm.load)
                    : ListView(
                        padding: const EdgeInsets.all(24),
                        children: [
                          Wrap(
                            spacing: 12,
                            runSpacing: 12,
                            children: [
                              _MiniStatCard(label: '전체 활동', value: '${vm.totalCount}', color: const Color(0xFF6B7280)),
                              _MiniStatCard(label: '혼잡도 조회', value: '${vm.countByType('view')}', color: const Color(0xFF2563EB)),
                              _MiniStatCard(label: '예측 조회', value: '${vm.countByType('prediction')}', color: const Color(0xFF06B6D4)),
                              _MiniStatCard(label: '출발 타이밍', value: '${vm.countByType('timing')}', color: const Color(0xFFEA580C)),
                              _MiniStatCard(label: '지도 보기', value: '${vm.countByType('map')}', color: const Color(0xFF16A34A)),
                              _MiniStatCard(label: '즐겨찾기', value: '${vm.countByType('favorite')}', color: const Color(0xFFD97706)),
                              _MiniStatCard(label: '알림 설정', value: '${vm.countByType('notification')}', color: const Color(0xFF9333EA)),
                              _MiniStatCard(label: '로그인', value: '${vm.countByType('login')}', color: const Color(0xFF4B5563)),
                            ],
                          ),
                          const SizedBox(height: 24),
                          WideCard(
                            title: '실시간 사용자 활동 로그',
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    const Icon(Icons.filter_alt_outlined, size: 18, color: Color(0xFF6B7280)),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: SingleChildScrollView(
                                        scrollDirection: Axis.horizontal,
                                        child: Row(
                                          children: vm.filters
                                              .map(
                                                (filter) => Padding(
                                                  padding: const EdgeInsets.only(right: 8),
                                                  child: ChoiceChip(
                                                    label: Text(filter.label),
                                                    selected: vm.selectedFilter == filter.value,
                                                    onSelected: (_) => vm.selectFilter(filter.value),
                                                    selectedColor: const Color(0xFFB5E0F5),
                                                  ),
                                                ),
                                              )
                                              .toList(),
                                        ),
                                      ),
                                    ),
                                    const Row(
                                      children: [
                                        Icon(Icons.circle, size: 10, color: Color(0xFF22C55E)),
                                        SizedBox(width: 6),
                                        Text('실시간 업데이트 중', style: TextStyle(fontSize: 13, color: Color(0xFF6B7280))),
                                      ],
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 20),
                                Container(
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF9FAFB),
                                    borderRadius: BorderRadius.circular(18),
                                    border: Border.all(color: const Color(0xFFE5E7EB)),
                                  ),
                                  child: Column(
                                    children: [
                                      const Padding(
                                        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                        child: Row(
                                          children: [
                                            Expanded(child: Text('시간', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF6B7280)))),
                                            Expanded(child: Text('사용자', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF6B7280)))),
                                            Expanded(child: Text('행동', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF6B7280)))),
                                            Expanded(flex: 2, child: Text('상세', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF6B7280)))),
                                          ],
                                        ),
                                      ),
                                      ...vm.filteredActivities.map((activity) => _ActivityRow(activity: activity)),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Row(
                                  children: [
                                    Text('총 ${vm.filteredActivities.length}개의 활동', style: const TextStyle(fontSize: 13, color: Color(0xFF6B7280))),
                                    const Spacer(),
                                    const Text('최근 로그 기준', style: TextStyle(fontSize: 12, color: Color(0xFF9CA3AF))),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),
                          Row(
                            children: [
                              for (int index = 0; index < vm.insights.length; index++) ...[
                                Expanded(
                                  child: _InsightMiniCard(
                                    title: vm.insights[index].title,
                                    value: vm.insights[index].value,
                                    detail: vm.insights[index].detail,
                                    background: _insightBackground(index),
                                    accent: _insightAccent(index),
                                  ),
                                ),
                                if (index != vm.insights.length - 1) const SizedBox(width: 16),
                              ],
                            ],
                          ),
                        ],
                      ),
          ),
        ],
      ),
    );
  }

  Color _insightBackground(int index) {
    const backgrounds = [
      Color(0xFFEFF6FF),
      Color(0xFFF0FDF4),
      Color(0xFFF5F3FF),
    ];
    return backgrounds[index % backgrounds.length];
  }

  Color _insightAccent(int index) {
    const accents = [
      Color(0xFF2563EB),
      Color(0xFF16A34A),
      Color(0xFF9333EA),
    ];
    return accents[index % accents.length];
  }
}

class _MiniStatCard extends StatelessWidget {
  const _MiniStatCard({required this.label, required this.value, required this.color});

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 156,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [BoxShadow(color: Color(0x14000000), blurRadius: 18, offset: Offset(0, 8))],
        border: Border(left: BorderSide(color: color, width: 4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280))),
          const SizedBox(height: 6),
          Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: color)),
        ],
      ),
    );
  }
}

class _ActivityRow extends StatelessWidget {
  const _ActivityRow({required this.activity});

  final ActivityLogItem activity;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: Color(0xFFE5E7EB))),
      ),
      child: Row(
        children: [
          Expanded(child: Text(activity.time, style: const TextStyle(fontFamily: 'monospace'))),
          Expanded(child: Text(activity.user, style: const TextStyle(color: Color(0xFF6B7280)))),
          Expanded(child: _ActionChip(action: activity.action)),
          Expanded(flex: 2, child: Text(activity.detail, style: const TextStyle(color: Color(0xFF6B7280)))),
        ],
      ),
    );
  }
}

class _ActionChip extends StatelessWidget {
  const _ActionChip({required this.action});

  final String action;

  @override
  Widget build(BuildContext context) {
    Color background;
    Color foreground;
    if (action == '혼잡도 조회') {
      background = const Color(0xFFDBEAFE);
      foreground = const Color(0xFF1D4ED8);
    } else if (action == '예측 조회') {
      background = const Color(0xFFCFFAFE);
      foreground = const Color(0xFF0E7490);
    } else if (action == '출발 타이밍') {
      background = const Color(0xFFFFEDD5);
      foreground = const Color(0xFF9A3412);
    } else if (action == '지도 보기') {
      background = const Color(0xFFDCFCE7);
      foreground = const Color(0xFF166534);
    } else if (action.contains('즐겨찾기')) {
      background = const Color(0xFFFEF3C7);
      foreground = const Color(0xFF92400E);
    } else if (action.contains('알림')) {
      background = const Color(0xFFF3E8FF);
      foreground = const Color(0xFF7E22CE);
    } else {
      background = const Color(0xFFF3F4F6);
      foreground = const Color(0xFF374151);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(color: background, borderRadius: BorderRadius.circular(10)),
      child: Text(action, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: foreground)),
    );
  }
}

class _InsightMiniCard extends StatelessWidget {
  const _InsightMiniCard({
    required this.title,
    required this.value,
    required this.detail,
    required this.background,
    required this.accent,
  });

  final String title;
  final String value;
  final String detail;
  final Color background;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [BoxShadow(color: Color(0x12000000), blurRadius: 12, offset: Offset(0, 6))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(fontSize: 13, color: accent)),
          const SizedBox(height: 8),
          Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800)),
          const SizedBox(height: 4),
          Text(detail, style: const TextStyle(fontSize: 13, color: Color(0xFF6B7280))),
        ],
      ),
    );
  }
}

class _ActivityLogErrorView extends StatelessWidget {
  const _ActivityLogErrorView({required this.message, required this.onRetry});

  final String message;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 420,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline_rounded, size: 42, color: Color(0xFFC85A54)),
            const SizedBox(height: 16),
            const Text('실시간 활동 데이터를 불러오지 못했습니다', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
            const SizedBox(height: 8),
            Text(message, textAlign: TextAlign.center, style: const TextStyle(color: Color(0xFF6B7280), height: 1.5)),
            const SizedBox(height: 18),
            FilledButton(
              onPressed: () => onRetry(),
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF0F6E8C),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              child: const Text('다시 시도'),
            ),
          ],
        ),
      ),
    );
  }
}
