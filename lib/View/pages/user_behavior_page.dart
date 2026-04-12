import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../Model/admin_models.dart';
import '../../VM/user_behavior_viewmodel.dart';
import '../widgets/admin_widgets.dart';

class UserBehaviorPage extends StatelessWidget {
  const UserBehaviorPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => UserBehaviorViewModel(),
      child: const _UserBehaviorView(),
    );
  }
}

class _UserBehaviorView extends StatelessWidget {
  const _UserBehaviorView();

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<UserBehaviorViewModel>();

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
                    ? _UserBehaviorErrorView(
                        message: vm.errorMessage!, onRetry: vm.load)
                    : LayoutBuilder(
                        builder: (context, constraints) {
                          final isNarrow = constraints.maxWidth < 1100;
                          final totalSessions = vm.sessionDurations
                              .fold<int>(0, (sum, item) => sum + item.count);
                          final totalWeekly = vm.weeklyActiveUsers.fold<int>(
                            0,
                            (sum, item) => sum + item.primary + item.secondary,
                          );
                          final weekdayItems = vm.weeklyActiveUsers
                              .take(math.min(5, vm.weeklyActiveUsers.length))
                              .toList();
                          final weekendItems = vm.weeklyActiveUsers
                              .skip(math.min(5, vm.weeklyActiveUsers.length))
                              .toList();
                          final weekdayAverage = weekdayItems.isEmpty
                              ? 0
                              : weekdayItems.fold<int>(
                                      0,
                                      (sum, item) =>
                                          sum +
                                          item.primary +
                                          item.secondary) ~/
                                  weekdayItems.length;
                          final weekendAverage = weekendItems.isEmpty
                              ? 0
                              : weekendItems.fold<int>(
                                      0,
                                      (sum, item) =>
                                          sum +
                                          item.primary +
                                          item.secondary) ~/
                                  weekendItems.length;
                          final weekendGrowth = weekdayAverage == 0
                              ? 0
                              : (((weekendAverage - weekdayAverage) /
                                          weekdayAverage) *
                                      100)
                                  .round();

                          return ListView(
                            padding: const EdgeInsets.all(24),
                            children: [
                              _StatsGrid(
                                  metrics: vm.metrics,
                                  totalUsersText: vm.totalActiveUsersText),
                              const SizedBox(height: 24),
                              WideCard(
                                title: '사용자 행동 퍼널',
                                child: Column(
                                  children: [
                                    ...vm.funnelSteps.asMap().entries.map(
                                          (entry) => Padding(
                                            padding: const EdgeInsets.only(
                                                bottom: 18),
                                            child: _FunnelRow(
                                              item: entry.value,
                                              previousRate: entry.key == 0
                                                  ? null
                                                  : vm
                                                      .funnelSteps[
                                                          entry.key - 1]
                                                      .rate,
                                            ),
                                          ),
                                        ),
                                    _InsightBanner(
                                      text: vm.activeUserInsight,
                                      background: const Color(0xFFEFF6FF),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 24),
                              if (isNarrow) ...[
                                WideCard(
                                  title: '세션 시간 분포',
                                  child: Column(
                                    children: [
                                      _PieLegendList(
                                          items: vm.sessionDurations,
                                          total: totalSessions),
                                      const SizedBox(height: 16),
                                      _InsightBanner(
                                        text: vm.sessionInsight,
                                        background: const Color(0xFFF5F3FF),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 24),
                                WideCard(
                                  title: '재방문 패턴',
                                  child: Column(
                                    children: [
                                      ...vm.returnPatterns.map(
                                          (item) => _PatternRow(item: item)),
                                      const SizedBox(height: 16),
                                      _InsightBanner(
                                        text: vm.returnInsight,
                                        background: const Color(0xFFF0FDF4),
                                      ),
                                    ],
                                  ),
                                ),
                              ] else
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: WideCard(
                                        title: '세션 시간 분포',
                                        child: Column(
                                          children: [
                                            _PieLegendList(
                                                items: vm.sessionDurations,
                                                total: totalSessions),
                                            const SizedBox(height: 16),
                                            _InsightBanner(
                                              text: vm.sessionInsight,
                                              background:
                                                  const Color(0xFFF5F3FF),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: WideCard(
                                        title: '재방문 패턴',
                                        child: Column(
                                          children: [
                                            ...vm.returnPatterns.map((item) =>
                                                _PatternRow(item: item)),
                                            const SizedBox(height: 16),
                                            _InsightBanner(
                                              text: vm.returnInsight,
                                              background:
                                                  const Color(0xFFF0FDF4),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              const SizedBox(height: 24),
                              WideCard(
                                title: '일주일간 활성 사용자 추이',
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SizedBox(
                                      height: 320,
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        children: vm.weeklyActiveUsers
                                            .map((point) => _WeeklyStackBar(
                                                point: point,
                                                maxTotal: totalWeekly == 0
                                                    ? 1
                                                    : _maxWeekly(
                                                        vm.weeklyActiveUsers)))
                                            .toList(),
                                      ),
                                    ),
                                    const SizedBox(height: 20),
                                    const Wrap(
                                      spacing: 16,
                                      runSpacing: 16,
                                      children: [
                                        _LegendDot(
                                            color: Color(0xFFB5E0F5),
                                            label: '신규 사용자'),
                                        _LegendDot(
                                            color: Color(0xFF6FA05C),
                                            label: '재방문 사용자'),
                                      ],
                                    ),
                                    const SizedBox(height: 20),
                                    Wrap(
                                      spacing: 16,
                                      runSpacing: 16,
                                      children: [
                                        _SummaryChip(
                                            label: '주중 평균',
                                            value:
                                                '${_formatCompact(weekdayAverage)}명/일',
                                            background:
                                                const Color(0xFFEFF6FF)),
                                        _SummaryChip(
                                            label: '주말 평균',
                                            value:
                                                '${_formatCompact(weekendAverage)}명/일',
                                            background:
                                                const Color(0xFFF0FDF4)),
                                        _SummaryChip(
                                          label: '주말 증가율',
                                          value:
                                              '${weekendGrowth >= 0 ? '+' : ''}$weekendGrowth%',
                                          background: const Color(0xFFF5F3FF),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 24),
                              if (isNarrow) ...[
                                WideCard(
                                  title: '기능별 사용 빈도 (세션당 평균)',
                                  child: Column(
                                    children: vm.featureFrequency
                                        .map((item) => Padding(
                                              padding: const EdgeInsets.only(
                                                  bottom: 18),
                                              child: _HorizontalStatBar(
                                                label: item.label,
                                                valueLabel: (item.count / 100)
                                                    .toStringAsFixed(1),
                                                ratio: _featureRatio(
                                                    vm.featureFrequency, item),
                                                color: item.color,
                                              ),
                                            ))
                                        .toList(),
                                  ),
                                ),
                                const SizedBox(height: 24),
                                WideCard(
                                  title: '알림 설정 현황',
                                  child: Column(
                                    children: [
                                      ...vm.notificationStats.map((item) =>
                                          _NotificationTile(item: item)),
                                      const SizedBox(height: 8),
                                      _NotificationFooter(
                                          totalUsersText:
                                              vm.totalActiveUsersText),
                                    ],
                                  ),
                                ),
                              ] else
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: WideCard(
                                        title: '기능별 사용 빈도 (세션당 평균)',
                                        child: Column(
                                          children: vm.featureFrequency
                                              .map((item) => Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            bottom: 18),
                                                    child: _HorizontalStatBar(
                                                      label: item.label,
                                                      valueLabel: (item.count /
                                                              100)
                                                          .toStringAsFixed(1),
                                                      ratio: _featureRatio(
                                                          vm.featureFrequency,
                                                          item),
                                                      color: item.color,
                                                    ),
                                                  ))
                                              .toList(),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: WideCard(
                                        title: '알림 설정 현황',
                                        child: Column(
                                          children: [
                                            ...vm.notificationStats.map(
                                                (item) => _NotificationTile(
                                                    item: item)),
                                            const SizedBox(height: 8),
                                            _NotificationFooter(
                                                totalUsersText:
                                                    vm.totalActiveUsersText),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              const SizedBox(height: 24),
                              WideCard(
                                title: '이탈 지점 분석',
                                child: Column(
                                  children: [
                                    _DropOffTable(items: vm.dropOff),
                                    const SizedBox(height: 16),
                                    const _InsightBanner(
                                      text:
                                          '지도/즐겨찾기 단계의 진입 장벽을 낮추면 전체 전환율 개선에 도움이 됩니다.',
                                      background: Color(0xFFFFFBEB),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}

class _StatsGrid extends StatelessWidget {
  const _StatsGrid({required this.metrics, required this.totalUsersText});

  final List<AdminMetric> metrics;
  final String totalUsersText;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 16,
      runSpacing: 16,
      children: metrics
          .map(
            (metric) => Container(
              width: 240,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x14000000),
                    blurRadius: 18,
                    offset: Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(metric.icon, color: metric.color, size: 24),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          metric.label,
                          style: const TextStyle(
                              fontSize: 14, color: Color(0xFF4B5563)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    metric.value,
                    style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF111827)),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    metric.label == '총 활성 사용자'
                        ? '오늘 전체'
                        : _metricFooter(metric.label, totalUsersText),
                    style:
                        const TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
                  ),
                ],
              ),
            ),
          )
          .toList(),
    );
  }

  String _metricFooter(String label, String totalUsersText) {
    switch (label) {
      case '재방문율':
        return '$totalUsersText 기준';
      case '평균 체류 시간':
        return '세션당 평균';
      case '알림 설정률':
        return '전체 알림 대비';
      default:
        return '';
    }
  }
}

class _FunnelRow extends StatelessWidget {
  const _FunnelRow({required this.item, this.previousRate});

  final FunnelStepData item;
  final int? previousRate;

  @override
  Widget build(BuildContext context) {
    final drop = previousRate == null ? null : previousRate! - item.rate;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                item.label,
                style: const TextStyle(fontSize: 14, color: Color(0xFF374151)),
              ),
            ),
            Text(
              '${_formatCompact(item.count)}명',
              style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF111827)),
            ),
            const SizedBox(width: 10),
            Text(
              '(${item.rate}%)',
              style: const TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
            ),
            if (drop != null) ...[
              const SizedBox(width: 10),
              Text(
                '-$drop%p 이탈',
                style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFFDC2626),
                    fontWeight: FontWeight.w600),
              ),
            ],
          ],
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          height: 24,
          decoration: BoxDecoration(
            color: const Color(0xFFE5E7EB),
            borderRadius: BorderRadius.circular(999),
          ),
          child: Stack(
            children: [
              FractionallySizedBox(
                widthFactor: item.rate / 100,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFB5E0F5), Color(0xFF7DD3FC)],
                    ),
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
              Positioned.fill(
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: Text(
                      '${item.rate}%',
                      style: const TextStyle(
                          fontSize: 12,
                          color: Colors.white,
                          fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _PieLegendList extends StatelessWidget {
  const _PieLegendList({required this.items, required this.total});

  final List<DistributionItem> items;
  final int total;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 220,
          child: Row(
            children: [
              Expanded(
                flex: 5,
                child: Center(
                  child: SizedBox(
                    width: 180,
                    height: 180,
                    child: CustomPaint(
                      painter: _DonutChartPainter(items: items, total: total),
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text(
                              '전체 세션',
                              style: TextStyle(
                                  fontSize: 12, color: Color(0xFF6B7280)),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              _formatCompact(total),
                              style: const TextStyle(
                                  fontSize: 26, fontWeight: FontWeight.w800),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                flex: 6,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: items
                      .map(
                        (item) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Row(
                            children: [
                              Container(
                                width: 10,
                                height: 10,
                                decoration: BoxDecoration(
                                    color: item.color, shape: BoxShape.circle),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  item.label,
                                  style: const TextStyle(
                                      fontSize: 13, color: Color(0xFF374151)),
                                ),
                              ),
                              Text(
                                '${_formatCompact(item.count)}명',
                                style: const TextStyle(
                                    fontSize: 12, fontWeight: FontWeight.w700),
                              ),
                            ],
                          ),
                        ),
                      )
                      .toList(),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _PatternRow extends StatelessWidget {
  const _PatternRow({required this.item});

  final DistributionItem item;

  @override
  Widget build(BuildContext context) {
    final ratio = ((item.percentage ?? 0) / 100).clamp(0.0, 1.0);

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  item.label,
                  style:
                      const TextStyle(fontSize: 14, color: Color(0xFF374151)),
                ),
              ),
              Text(
                '${_formatCompact(item.count)}명 (${item.percentage ?? 0}%)',
                style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF111827)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: ratio,
              minHeight: 14,
              backgroundColor: const Color(0xFFE5E7EB),
              valueColor: AlwaysStoppedAnimation<Color>(item.color),
            ),
          ),
        ],
      ),
    );
  }
}

class _WeeklyStackBar extends StatelessWidget {
  const _WeeklyStackBar({required this.point, required this.maxTotal});

  final WeeklyTrendPoint point;
  final int maxTotal;

  @override
  Widget build(BuildContext context) {
    final total = point.primary + point.secondary;
    final ratio = maxTotal == 0 ? 0.0 : total / maxTotal;
    final barHeight = 220.0 * ratio.clamp(0.0, 1.0);

    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
              _formatCompact(total),
              style: const TextStyle(fontSize: 11, color: Color(0xFF6B7280)),
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 220,
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  height: barHeight,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x10000000),
                        blurRadius: 10,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                        child: Container(
                          decoration: const BoxDecoration(
                            color: Color(0xFFB5E0F5),
                            borderRadius: BorderRadius.horizontal(
                                left: Radius.circular(10)),
                          ),
                          alignment: Alignment.bottomCenter,
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Text(
                            '${point.primary}',
                            style: const TextStyle(
                                fontSize: 10,
                                color: Color(0xFF1F2937),
                                fontWeight: FontWeight.w700),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Container(
                          decoration: const BoxDecoration(
                            color: Color(0xFF6FA05C),
                            borderRadius: BorderRadius.horizontal(
                                right: Radius.circular(10)),
                          ),
                          alignment: Alignment.bottomCenter,
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Text(
                            '${point.secondary}',
                            style: const TextStyle(
                                fontSize: 10,
                                color: Colors.white,
                                fontWeight: FontWeight.w700),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Text(point.label,
                style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280))),
          ],
        ),
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  const _LegendDot({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 8),
        Text(label,
            style: const TextStyle(fontSize: 13, color: Color(0xFF6B7280))),
      ],
    );
  }
}

class _SummaryChip extends StatelessWidget {
  const _SummaryChip(
      {required this.label, required this.value, required this.background});

  final String label;
  final String value;
  final Color background;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 180,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(label,
              style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280))),
          const SizedBox(height: 6),
          Text(value,
              style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF111827))),
        ],
      ),
    );
  }
}

class _HorizontalStatBar extends StatelessWidget {
  const _HorizontalStatBar({
    required this.label,
    required this.valueLabel,
    required this.ratio,
    required this.color,
  });

  final String label;
  final String valueLabel;
  final double ratio;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Text(label,
                  style:
                      const TextStyle(fontSize: 14, color: Color(0xFF374151))),
            ),
            Text(valueLabel,
                style: const TextStyle(fontWeight: FontWeight.w700)),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: LinearProgressIndicator(
            value: ratio.clamp(0.0, 1.0),
            minHeight: 16,
            backgroundColor: const Color(0xFFE5E7EB),
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }
}

class _NotificationTile extends StatelessWidget {
  const _NotificationTile({required this.item});

  final NotificationSettingStat item;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: item.background,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Icon(item.icon, color: item.color),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              item.label,
              style: const TextStyle(
                  fontWeight: FontWeight.w700, color: Color(0xFF111827)),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                _formatCompact(item.count),
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: item.color),
              ),
              Text(
                '${item.percentage}% 설정',
                style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _NotificationFooter extends StatelessWidget {
  const _NotificationFooter({required this.totalUsersText});

  final String totalUsersText;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 14),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: Color(0xFFE5E7EB))),
      ),
      child: Row(
        children: [
          const Text('총 사용자',
              style: TextStyle(fontSize: 14, color: Color(0xFF6B7280))),
          const Spacer(),
          Text(
            '$totalUsersText명',
            style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: Color(0xFF111827)),
          ),
        ],
      ),
    );
  }
}

class _DropOffTable extends StatelessWidget {
  const _DropOffTable({required this.items});

  final List<DropOffItem> items;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minWidth: 780),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: Color(0xFFE5E7EB))),
              ),
              child: const Row(
                children: [
                  Expanded(
                      flex: 3,
                      child: Text('이탈 지점',
                          style: TextStyle(
                              fontSize: 13, color: Color(0xFF6B7280)))),
                  Expanded(
                      child: Text('이탈자 수',
                          textAlign: TextAlign.right,
                          style: TextStyle(
                              fontSize: 13, color: Color(0xFF6B7280)))),
                  Expanded(
                      child: Text('누적 이탈률',
                          textAlign: TextAlign.right,
                          style: TextStyle(
                              fontSize: 13, color: Color(0xFF6B7280)))),
                  Expanded(
                      flex: 2,
                      child: Text('진행률',
                          textAlign: TextAlign.right,
                          style: TextStyle(
                              fontSize: 13, color: Color(0xFF6B7280)))),
                ],
              ),
            ),
            ...items.map((item) => _DropOffRow(item: item)),
          ],
        ),
      ),
    );
  }
}

class _DropOffRow extends StatelessWidget {
  const _DropOffRow({required this.item});

  final DropOffItem item;

  @override
  Widget build(BuildContext context) {
    Color color;
    if (item.rate < 30) {
      color = const Color(0xFF22C55E);
    } else if (item.rate < 50) {
      color = const Color(0xFFEAB308);
    } else {
      color = const Color(0xFFEF4444);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFF3F4F6))),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(item.label,
                style: const TextStyle(
                    fontWeight: FontWeight.w700, color: Color(0xFF111827))),
          ),
          Expanded(
            child: Text(
              _formatCompact(item.count),
              textAlign: TextAlign.right,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
          Expanded(
            child: Text(
              '${item.rate}%',
              textAlign: TextAlign.right,
              style: const TextStyle(color: Color(0xFF6B7280)),
            ),
          ),
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.only(left: 24),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(999),
                child: LinearProgressIndicator(
                  value: item.rate / 100,
                  minHeight: 12,
                  backgroundColor: const Color(0xFFE5E7EB),
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InsightBanner extends StatelessWidget {
  const _InsightBanner({required this.text, required this.background});

  final String text;
  final Color background;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(16),
      ),
      child: RichText(
        text: TextSpan(
          style: const TextStyle(
              fontSize: 14, color: Color(0xFF374151), height: 1.5),
          children: [
            const TextSpan(
              text: '인사이트: ',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
            TextSpan(text: text),
          ],
        ),
      ),
    );
  }
}

class _DonutChartPainter extends CustomPainter {
  _DonutChartPainter({required this.items, required this.total});

  final List<DistributionItem> items;
  final int total;

  @override
  void paint(Canvas canvas, Size size) {
    if (items.isEmpty || total <= 0) {
      return;
    }

    final rect = Offset.zero & size;
    final strokeWidth = size.width * 0.18;
    final basePaint = Paint()
      ..color = const Color(0xFFE5E7EB)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(rect.deflate(strokeWidth / 2), -math.pi / 2, math.pi * 2,
        false, basePaint);

    var startAngle = -math.pi / 2;
    for (final item in items) {
      final sweepAngle = (item.count / total) * math.pi * 2;
      final paint = Paint()
        ..color = item.color
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round;
      canvas.drawArc(
          rect.deflate(strokeWidth / 2), startAngle, sweepAngle, false, paint);
      startAngle += sweepAngle;
    }
  }

  @override
  bool shouldRepaint(covariant _DonutChartPainter oldDelegate) {
    return oldDelegate.total != total || oldDelegate.items != items;
  }
}

class _UserBehaviorErrorView extends StatelessWidget {
  const _UserBehaviorErrorView({required this.message, required this.onRetry});

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
            const Icon(Icons.error_outline_rounded,
                color: Color(0xFFD14343), size: 48),
            const SizedBox(height: 16),
            const Text(
              '데이터를 불러오지 못했습니다',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16, color: Color(0xFF6B7280)),
            ),
            const SizedBox(height: 20),
            FilledButton(
              onPressed: () => onRetry(),
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF156C86),
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              ),
              child: const Text('다시 시도'),
            ),
          ],
        ),
      ),
    );
  }
}

double _featureRatio(List<DistributionItem> items, DistributionItem current) {
  final maxCount = items.fold<int>(0, (max, item) => math.max(max, item.count));
  if (maxCount == 0) {
    return 0;
  }
  return current.count / maxCount;
}

int _maxWeekly(List<WeeklyTrendPoint> items) {
  return items.fold<int>(
      0, (max, item) => math.max(max, item.primary + item.secondary));
}

String _formatCompact(int value) {
  final text = value.toString();
  final chars = text.split('');
  final buffer = StringBuffer();
  for (var i = 0; i < chars.length; i++) {
    buffer.write(chars[i]);
    final remaining = chars.length - i - 1;
    if (remaining > 0 && remaining % 3 == 0) {
      buffer.write(',');
    }
  }
  return buffer.toString();
}
