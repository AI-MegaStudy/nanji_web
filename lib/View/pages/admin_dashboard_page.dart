import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../Model/admin_models.dart';
import '../../VM/admin_dashboard_viewmodel.dart';
import '../widgets/admin_widgets.dart';

class AdminDashboardPage extends StatelessWidget {
  const AdminDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AdminDashboardViewModel(),
      child: const _AdminDashboardView(),
    );
  }
}

class _AdminDashboardView extends StatelessWidget {
  const _AdminDashboardView();

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<AdminDashboardViewModel>();

    return Container(
      color: const Color(0xFFF3F4F6),
      child: Column(
        children: [
          Expanded(
            child: vm.isLoading
                ? const Center(child: CircularProgressIndicator())
                : vm.errorMessage != null
                    ? _DashboardErrorView(
                        message: vm.errorMessage!,
                        onRetry: vm.load,
                      )
                    : LayoutBuilder(
                        builder: (context, constraints) {
                          final isNarrow = constraints.maxWidth < 1100;
                          final cardWidth = isNarrow
                              ? constraints.maxWidth - 48
                              : (constraints.maxWidth - 80) / 2;

                          return SingleChildScrollView(
                            padding: const EdgeInsets.all(24),
                            child: Center(
                              child: ConstrainedBox(
                                constraints:
                                    const BoxConstraints(maxWidth: 1440),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _TopStatsGrid(metrics: vm.metrics),
                                    const SizedBox(height: 24),
                                    WideCard(
                                      title: '${vm.parkingTitle} 현황',
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Wrap(
                                            spacing: 16,
                                            runSpacing: 16,
                                            children: vm.parkingSummary
                                                .map(
                                                  (item) => _ParkingSummaryCard(
                                                    item: item,
                                                  ),
                                                )
                                                .toList(),
                                          ),
                                          const SizedBox(height: 24),
                                          Row(
                                            children: [
                                              const Text(
                                                '실시간 혼잡도',
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  color: Color(0xFF6B7280),
                                                ),
                                              ),
                                              const Spacer(),
                                              _CongestionBadge(
                                                label: vm.realtimeStatus,
                                                color: vm.realtimeColor(),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 10),
                                          ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(999),
                                            child: LinearProgressIndicator(
                                              value: vm.realtimeOccupancy,
                                              minHeight: 16,
                                              backgroundColor:
                                                  const Color(0xFFE5E7EB),
                                              valueColor:
                                                  AlwaysStoppedAnimation<Color>(
                                                vm.realtimeColor(),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 24),
                                    if (vm.insights.isNotEmpty)
                                      WideCard(
                                        title: '운영 인사이트',
                                        child: Column(
                                          children: vm.insights
                                              .map(
                                                (insight) => _InsightTile(
                                                  insight: insight,
                                                ),
                                              )
                                              .toList(),
                                        ),
                                      ),
                                    const SizedBox(height: 24),
                                    if (isNarrow) ...[
                                      WideCard(
                                        title: '시간대별 사용자 접속 현황',
                                        child: _HourlyUsageChart(
                                          points: vm.hourlyUsage,
                                        ),
                                      ),
                                      const SizedBox(height: 24),
                                      WideCard(
                                        title: '기능별 사용 비율',
                                        child: _FeatureUsageChart(
                                          slices: vm.featureUsage,
                                        ),
                                      ),
                                    ] else
                                      Wrap(
                                        spacing: 16,
                                        runSpacing: 16,
                                        children: [
                                          SizedBox(
                                            width: cardWidth,
                                            child: WideCard(
                                              title: '시간대별 사용자 접속 현황',
                                              child: _HourlyUsageChart(
                                                points: vm.hourlyUsage,
                                              ),
                                            ),
                                          ),
                                          SizedBox(
                                            width: cardWidth,
                                            child: WideCard(
                                              title: '기능별 사용 비율',
                                              child: _FeatureUsageChart(
                                                slices: vm.featureUsage,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    const SizedBox(height: 24),
                                    WideCard(
                                      title: '사용자 행동 퍼널',
                                      child: Column(
                                        children: vm.funnelSteps
                                            .asMap()
                                            .entries
                                            .map(
                                              (entry) => Padding(
                                                padding: const EdgeInsets.only(
                                                  bottom: 16,
                                                ),
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
                                            )
                                            .toList(),
                                      ),
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

class _TopStatsGrid extends StatelessWidget {
  const _TopStatsGrid({required this.metrics});

  final List<AdminMetric> metrics;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: metrics
          .map(
            (metric) => SizedBox(
              width: 180,
              child: Container(
                padding: const EdgeInsets.all(18),
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
                        Icon(metric.icon, size: 20, color: metric.color),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            metric.label,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF6B7280),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Text(
                      _metricValue(metric),
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF111827),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )
          .toList(),
    );
  }

  String _metricValue(AdminMetric metric) {
    if (metric.label == '오늘 방문자') return '${metric.value}명';
    if (metric.label == '즐겨찾기') return '${metric.value}건';
    return '${metric.value}회';
  }
}

class _ParkingSummaryCard extends StatelessWidget {
  const _ParkingSummaryCard({required this.item});

  final ParkingSummaryItem item;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 220,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 22),
      decoration: BoxDecoration(
        color: const Color(0xFFB5E0F5).withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFB5E0F5), width: 1.8),
      ),
      child: Column(
        children: [
          Text(
            item.label,
            style: const TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
          ),
          const SizedBox(height: 10),
          Text(
            item.value,
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w800,
              color: Color(0xFF111827),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            item.unit,
            style: const TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
          ),
        ],
      ),
    );
  }
}

class _CongestionBadge extends StatelessWidget {
  const _CongestionBadge({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 13,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _InsightTile extends StatelessWidget {
  const _InsightTile({required this.insight});

  final OperationalInsight insight;

  @override
  Widget build(BuildContext context) {
    final isWarning = insight.type == 'warning';
    final background =
        isWarning ? const Color(0xFFFEFCE8) : const Color(0xFFEFF6FF);
    final border =
        isWarning ? const Color(0xFFEAB308) : const Color(0xFF3B82F6);
    final iconColor =
        isWarning ? const Color(0xFFD97706) : const Color(0xFF2563EB);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(18),
        border: Border(left: BorderSide(color: border, width: 4)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.trending_up_rounded, color: iconColor, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  insight.message,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  insight.time,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF6B7280),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HourlyUsageChart extends StatelessWidget {
  const _HourlyUsageChart({required this.points});

  final List<HourlyUsagePoint> points;

  @override
  Widget build(BuildContext context) {
    if (points.isEmpty) {
      return const PlaceholderChart(label: '표시할 데이터가 없습니다');
    }

    final maxValue =
        points.map((point) => point.value).reduce((a, b) => a > b ? a : b);

    return SizedBox(
      height: 320,
      child: BarChart(
        BarChartData(
          maxY: maxValue <= 0 ? 10 : maxValue + 20,
          alignment: BarChartAlignment.spaceAround,
          gridData: FlGridData(
            show: true,
            horizontalInterval:
                maxValue <= 0 ? 2 : ((maxValue + 20) / 4).clamp(10, 120),
            getDrawingHorizontalLine: (value) => const FlLine(
              color: Color(0xFFD1D5DB),
              strokeWidth: 1,
              dashArray: [4, 4],
            ),
            drawVerticalLine: false,
          ),
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 34,
                getTitlesWidget: (value, meta) => Text(
                  value.toInt().toString(),
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF6B7280),
                  ),
                ),
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 28,
                getTitlesWidget: (value, meta) => Text(
                  value.toInt().toString(),
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF6B7280),
                  ),
                ),
              ),
            ),
          ),
          barTouchData: BarTouchData(
            touchTooltipData: BarTouchTooltipData(
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                return BarTooltipItem(
                  '${group.x}시\n${rod.toY.round()}명',
                  const TextStyle(
                    color: Color(0xFF111827),
                    fontWeight: FontWeight.w700,
                  ),
                );
              },
            ),
          ),
          barGroups: points
              .map(
                (point) => BarChartGroupData(
                  x: point.hour,
                  barRods: [
                    BarChartRodData(
                      toY: point.value,
                      width: 14,
                      color: const Color(0xFFB5E0F5),
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ],
                ),
              )
              .toList(),
        ),
      ),
    );
  }
}

class _FeatureUsageChart extends StatelessWidget {
  const _FeatureUsageChart({required this.slices});

  final List<FeatureUsageSlice> slices;

  @override
  Widget build(BuildContext context) {
    if (slices.isEmpty) {
      return const PlaceholderChart(label: '표시할 데이터가 없습니다');
    }

    final total = slices.fold<int>(0, (sum, item) => sum + item.value);

    return SizedBox(
      height: 320,
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: PieChart(
              PieChartData(
                sectionsSpace: 2,
                centerSpaceRadius: 42,
                sections: slices
                    .map(
                      (slice) => PieChartSectionData(
                        value: slice.value.toDouble(),
                        color: slice.color,
                        radius: 78,
                        title: '',
                      ),
                    )
                    .toList(),
              ),
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            flex: 2,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: slices
                  .map(
                    (slice) => Padding(
                      padding: const EdgeInsets.only(bottom: 14),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 12,
                            height: 12,
                            margin: const EdgeInsets.only(top: 3),
                            decoration: BoxDecoration(
                              color: slice.color,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  slice.name,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF374151),
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '${slice.value}회 (${_percent(slice.value, total)}%)',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFF6B7280),
                                  ),
                                ),
                              ],
                            ),
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
    );
  }

  int _percent(int value, int total) {
    if (total <= 0) return 0;
    return ((value / total) * 100).round();
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
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF374151),
                ),
              ),
            ),
            Text(
              '${_formatCount(item.count)}명 (${item.rate}%)',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Color(0xFF111827),
              ),
            ),
            if (drop != null) ...[
              const SizedBox(width: 10),
              Text(
                '-$drop%p',
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFFDC2626),
                  fontWeight: FontWeight.w700,
                ),
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
                        fontWeight: FontWeight.w700,
                      ),
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

  String _formatCount(int value) {
    final text = value.toString();
    final buffer = StringBuffer();
    for (var i = 0; i < text.length; i++) {
      final reverseIndex = text.length - i;
      buffer.write(text[i]);
      if (reverseIndex > 1 && reverseIndex % 3 == 1) {
        buffer.write(',');
      }
    }
    return buffer.toString();
  }
}

class _DashboardErrorView extends StatelessWidget {
  const _DashboardErrorView({required this.message, required this.onRetry});

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
              '데이터를 불러오지 못했습니다',
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
