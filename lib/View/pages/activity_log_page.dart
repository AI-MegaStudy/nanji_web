import 'dart:math' as math;

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
        children: [
          Expanded(
            child: vm.isLoading
                ? const Center(child: CircularProgressIndicator())
                : vm.errorMessage != null
                    ? _ActivityLogErrorView(
                        message: vm.errorMessage!,
                        onRetry: vm.load,
                      )
                    : LayoutBuilder(
                        builder: (context, constraints) {
                          final contentWidth =
                              math.min(constraints.maxWidth, 1440.0);
                          final isCompact = contentWidth < 980;
                          final insights = _buildInsights(vm);
                          final filteredActivities = vm.filteredActivities;

                          return SingleChildScrollView(
                            padding: const EdgeInsets.all(24),
                            child: Center(
                              child: ConstrainedBox(
                                constraints:
                                    BoxConstraints(maxWidth: contentWidth),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Wrap(
                                      spacing: 12,
                                      runSpacing: 12,
                                      children: [
                                        _MiniStatCard(
                                          label: '전체 활동',
                                          value: '${vm.totalCount}',
                                          color: const Color(0xFF6B7280),
                                        ),
                                        _MiniStatCard(
                                          label: '혼잡도 조회',
                                          value: '${vm.countByType('view')}',
                                          color: const Color(0xFF2563EB),
                                        ),
                                        _MiniStatCard(
                                          label: '예측 조회',
                                          value:
                                              '${vm.countByType('prediction')}',
                                          color: const Color(0xFF0891B2),
                                        ),
                                        _MiniStatCard(
                                          label: '출발 타이밍',
                                          value: '${vm.countByType('timing')}',
                                          color: const Color(0xFFEA580C),
                                        ),
                                        _MiniStatCard(
                                          label: '지도 보기',
                                          value: '${vm.countByType('map')}',
                                          color: const Color(0xFF16A34A),
                                        ),
                                        _MiniStatCard(
                                          label: '즐겨찾기',
                                          value:
                                              '${vm.countByType('favorite')}',
                                          color: const Color(0xFFD97706),
                                        ),
                                        _MiniStatCard(
                                          label: '알림 설정',
                                          value:
                                              '${vm.countByType('notification')}',
                                          color: const Color(0xFF9333EA),
                                        ),
                                        _MiniStatCard(
                                          label: '로그인',
                                          value: '${vm.countByType('login')}',
                                          color: const Color(0xFF4B5563),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 24),
                                    WideCard(
                                      title: '실시간 사용자 활동 로그',
                                      child: Column(
                                        children: [
                                          if (isCompact)
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                const Row(
                                                  children: [
                                                    Icon(
                                                      Icons.bolt_rounded,
                                                      size: 20,
                                                      color: Color(0xFF111827),
                                                    ),
                                                    SizedBox(width: 10),
                                                    Text(
                                                      '실시간 업데이트 중',
                                                      style: TextStyle(
                                                        fontSize: 14,
                                                        color:
                                                            Color(0xFF6B7280),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                const SizedBox(height: 16),
                                                _FilterChips(vm: vm),
                                              ],
                                            )
                                          else
                                            Row(
                                              children: [
                                                const Icon(
                                                  Icons.bolt_rounded,
                                                  size: 20,
                                                  color: Color(0xFF111827),
                                                ),
                                                const SizedBox(width: 10),
                                                Expanded(
                                                  child: _FilterChips(vm: vm),
                                                ),
                                                const SizedBox(width: 16),
                                                Container(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                    horizontal: 12,
                                                    vertical: 8,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    color:
                                                        const Color(0xFFF0FDF4),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                      999,
                                                    ),
                                                  ),
                                                  child: const Row(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: [
                                                      Icon(
                                                        Icons.circle,
                                                        size: 8,
                                                        color:
                                                            Color(0xFF22C55E),
                                                      ),
                                                      SizedBox(width: 6),
                                                      Text(
                                                        '실시간 업데이트 중',
                                                        style: TextStyle(
                                                          fontSize: 12,
                                                          color: Color(
                                                            0xFF166534,
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          const SizedBox(height: 20),
                                          Container(
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius:
                                                  BorderRadius.circular(18),
                                              border: Border.all(
                                                color:
                                                    const Color(0xFFE5E7EB),
                                              ),
                                            ),
                                            child: filteredActivities.isEmpty
                                                ? const Padding(
                                                    padding:
                                                        EdgeInsets.all(32),
                                                    child: Column(
                                                      children: [
                                                        Icon(
                                                          Icons.timeline,
                                                          size: 44,
                                                          color: Color(
                                                            0xFF9CA3AF,
                                                          ),
                                                        ),
                                                        SizedBox(height: 12),
                                                        Text(
                                                          '선택한 필터에 해당하는 활동이 없습니다.',
                                                          style: TextStyle(
                                                            color: Color(
                                                              0xFF6B7280,
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  )
                                                : isCompact
                                                    ? Column(
                                                        children:
                                                            filteredActivities
                                                                .map(
                                                                  (activity) =>
                                                                      _ActivityCard(
                                                                    activity:
                                                                        activity,
                                                                  ),
                                                                )
                                                                .toList(),
                                                      )
                                                    : Column(
                                                        children: [
                                                          const Padding(
                                                            padding:
                                                                EdgeInsets
                                                                    .symmetric(
                                                              horizontal: 16,
                                                              vertical: 14,
                                                            ),
                                                            child: Row(
                                                              children: [
                                                                SizedBox(
                                                                  width: 110,
                                                                  child: Text(
                                                                    '시간',
                                                                    style:
                                                                        TextStyle(
                                                                      fontSize:
                                                                          13,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w700,
                                                                      color: Color(
                                                                        0xFF6B7280,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ),
                                                                SizedBox(
                                                                  width: 160,
                                                                  child: Text(
                                                                    '사용자',
                                                                    style:
                                                                        TextStyle(
                                                                      fontSize:
                                                                          13,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w700,
                                                                      color: Color(
                                                                        0xFF6B7280,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ),
                                                                SizedBox(
                                                                  width: 170,
                                                                  child: Text(
                                                                    '행동',
                                                                    style:
                                                                        TextStyle(
                                                                      fontSize:
                                                                          13,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w700,
                                                                      color: Color(
                                                                        0xFF6B7280,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ),
                                                                Expanded(
                                                                  child: Text(
                                                                    '상세',
                                                                    style:
                                                                        TextStyle(
                                                                      fontSize:
                                                                          13,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w700,
                                                                      color: Color(
                                                                        0xFF6B7280,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                          ...filteredActivities
                                                              .map(
                                                            (activity) =>
                                                                _ActivityRow(
                                                              activity:
                                                                  activity,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                          ),
                                          if (filteredActivities.isNotEmpty) ...[
                                            const SizedBox(height: 16),
                                            isCompact
                                                ? Wrap(
                                                    spacing: 12,
                                                    runSpacing: 8,
                                                    children: [
                                                      Text(
                                                        '총 ${filteredActivities.length}개의 활동',
                                                        style:
                                                            const TextStyle(
                                                          fontSize: 13,
                                                          color: Color(
                                                            0xFF6B7280,
                                                          ),
                                                        ),
                                                      ),
                                                      const Text(
                                                        '최근 15분간 활동 기준',
                                                        style: TextStyle(
                                                          fontSize: 12,
                                                          color: Color(
                                                            0xFF9CA3AF,
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  )
                                                : Row(
                                                    children: [
                                                      Text(
                                                        '총 ${filteredActivities.length}개의 활동',
                                                        style:
                                                            const TextStyle(
                                                          fontSize: 13,
                                                          color: Color(
                                                            0xFF6B7280,
                                                          ),
                                                        ),
                                                      ),
                                                      const Spacer(),
                                                      const Text(
                                                        '최근 15분간의 활동 내역',
                                                        style: TextStyle(
                                                          fontSize: 12,
                                                          color: Color(
                                                            0xFF9CA3AF,
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                          ],
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 24),
                                    Wrap(
                                      spacing: 16,
                                      runSpacing: 16,
                                      children: insights
                                          .map(
                                            (item) => SizedBox(
                                              width: isCompact
                                                  ? contentWidth
                                                  : (contentWidth - 32) / 3,
                                              child: _InsightCard(
                                                title: item.title,
                                                value: item.value,
                                                detail: item.detail,
                                                background: item.background,
                                                accent: item.accent,
                                              ),
                                            ),
                                          )
                                          .toList(),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}

class _MiniStatCard extends StatelessWidget {
  const _MiniStatCard({
    required this.label,
    required this.value,
    required this.color,
  });

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
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ],
        border: Border(left: BorderSide(color: color, width: 4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterChips extends StatelessWidget {
  const _FilterChips({required this.vm});

  final ActivityLogViewModel vm;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          const Icon(
            Icons.filter_alt_outlined,
            size: 18,
            color: Color(0xFF6B7280),
          ),
          const SizedBox(width: 8),
          ...vm.filters.map(
            (filter) {
              final count = filter.value == 'all'
                  ? vm.totalCount
                  : vm.countByType(filter.value);

              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: Text(
                    filter.value == 'all'
                        ? filter.label
                        : '${filter.label} ($count)',
                  ),
                  selected: vm.selectedFilter == filter.value,
                  onSelected: (_) => vm.selectFilter(filter.value),
                  selectedColor: const Color(0xFFB5E0F5),
                ),
              );
            },
          ),
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
          SizedBox(
            width: 110,
            child: Text(
              activity.time,
              style: const TextStyle(fontFamily: 'monospace'),
            ),
          ),
          SizedBox(
            width: 160,
            child: Text(
              activity.user,
              style: const TextStyle(color: Color(0xFF6B7280)),
            ),
          ),
          SizedBox(
            width: 170,
            child: _ActionBadge(action: activity.action),
          ),
          Expanded(
            child: Text(
              activity.detail,
              style: const TextStyle(color: Color(0xFF6B7280)),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActivityCard extends StatelessWidget {
  const _ActivityCard({required this.activity});

  final ActivityLogItem activity;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: Color(0xFFE5E7EB))),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              Text(
                activity.time,
                style: const TextStyle(fontFamily: 'monospace'),
              ),
              _ActionBadge(action: activity.action),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            activity.user,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              color: Color(0xFF111827),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            activity.detail,
            style: const TextStyle(
              color: Color(0xFF6B7280),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionBadge extends StatelessWidget {
  const _ActionBadge({required this.action});

  final String action;

  @override
  Widget build(BuildContext context) {
    late final Color background;
    late final Color foreground;

    if (action == '혼잡도 조회') {
      background = const Color(0xFFE0F2FE);
      foreground = const Color(0xFF1D4ED8);
    } else if (action == '예측 조회') {
      background = const Color(0xFFCFFAFE);
      foreground = const Color(0xFF0369A1);
    } else if (action.contains('출발')) {
      background = const Color(0xFFFFEDD5);
      foreground = const Color(0xFF9A3412);
    } else if (action.contains('지도')) {
      background = const Color(0xFFDCFCE7);
      foreground = const Color(0xFF166534);
    } else if (action.contains('즐겨찾기')) {
      background = const Color(0xFFFEF3C7);
      foreground = const Color(0xFF78350F);
    } else if (action.contains('알림')) {
      background = const Color(0xFFF3E8FF);
      foreground = const Color(0xFF7E22CE);
    } else {
      background = const Color(0xFFF3F4F6);
      foreground = const Color(0xFF4B5563);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        action,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: foreground,
        ),
      ),
    );
  }
}

class _InsightCard extends StatelessWidget {
  const _InsightCard({
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
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Color(0x12000000),
            blurRadius: 12,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(fontSize: 13, color: accent)),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 6),
          Text(
            detail,
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF6B7280),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _ActivityLogErrorView extends StatelessWidget {
  const _ActivityLogErrorView({
    required this.message,
    required this.onRetry,
  });

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
            const Icon(
              Icons.error_outline_rounded,
              size: 42,
              color: Color(0xFFC85A54),
            ),
            const SizedBox(height: 16),
            const Text(
              '실시간 활동 데이터를 불러오지 못했습니다',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFF6B7280),
                height: 1.5,
              ),
            ),
            const SizedBox(height: 18),
            FilledButton(
              onPressed: () => onRetry(),
              child: const Text('다시 시도'),
            ),
          ],
        ),
      ),
    );
  }
}

List<_InsightData> _buildInsights(ActivityLogViewModel vm) {
  final counts = {
    '혼잡도 조회': vm.countByType('view'),
    '예측 조회': vm.countByType('prediction'),
    '출발 타이밍': vm.countByType('timing'),
    '지도 보기': vm.countByType('map'),
    '즐겨찾기': vm.countByType('favorite'),
    '알림 설정': vm.countByType('notification'),
    '로그인': vm.countByType('login'),
  };

  final topEntry = counts.entries.reduce(
    (a, b) => a.value >= b.value ? a : b,
  );
  final percent = vm.totalCount == 0
      ? 0.0
      : (topEntry.value / vm.totalCount) * 100;
  final averageGap = vm.activities.isEmpty
      ? '0초'
      : '${(15 / math.max(vm.activities.length, 1)).toStringAsFixed(1)}분';

  return [
    _InsightData(
      title: '최다 활동',
      value: topEntry.key,
      detail: '${topEntry.value}회 (${percent.toStringAsFixed(1)}%)',
      background: const Color(0xFFEFF6FF),
      accent: const Color(0xFF1D4ED8),
    ),
    const _InsightData(
      title: '활발한 시간대',
      value: '최근 활동 구간',
      detail: '최근 로그가 가장 많이 쌓인 구간을 기준으로 갱신됩니다.',
      background: Color(0xFFF0FDF4),
      accent: Color(0xFF166534),
    ),
    _InsightData(
      title: '평균 활동 간격',
      value: averageGap,
      detail: '최근 15분 로그를 기준으로 계산한 평균 간격입니다.',
      background: const Color(0xFFF5F3FF),
      accent: const Color(0xFF7E22CE),
    ),
  ];
}

class _InsightData {
  const _InsightData({
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
}
