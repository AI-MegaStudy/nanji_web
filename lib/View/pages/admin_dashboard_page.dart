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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PageHeader(title: vm.pageTitle, subtitle: vm.pageSubtitle),
          Expanded(
            child: vm.isLoading
                ? const Center(child: CircularProgressIndicator())
                : vm.errorMessage != null
                    ? _DashboardErrorView(message: vm.errorMessage!, onRetry: vm.load)
                    : ListView(
                        padding: const EdgeInsets.all(24),
                        children: [
                          Wrap(
                            spacing: 16,
                            runSpacing: 16,
                            children: vm.metrics.map((metric) => MetricCard(metric: metric)).toList(),
                          ),
                          const SizedBox(height: 24),
                          WideCard(
                            title: '${vm.parkingTitle} 현황',
                            child: Column(
                              children: [
                                Wrap(
                                  spacing: 16,
                                  runSpacing: 16,
                                  children: vm.parkingSummary
                                      .map(
                                        (item) => Container(
                                          width: 220,
                                          padding: const EdgeInsets.all(20),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFB5E0F5).withOpacity(0.18),
                                            borderRadius: BorderRadius.circular(20),
                                            border: Border.all(color: const Color(0xFFB5E0F5), width: 1.8),
                                          ),
                                          child: Column(
                                            children: [
                                              Text(item.label, style: const TextStyle(fontSize: 13, color: Color(0xFF6B7280))),
                                              const SizedBox(height: 10),
                                              Text(item.value, style: const TextStyle(fontSize: 34, fontWeight: FontWeight.w800)),
                                              const SizedBox(height: 4),
                                              Text(item.unit, style: const TextStyle(fontSize: 13, color: Color(0xFF6B7280))),
                                            ],
                                          ),
                                        ),
                                      )
                                      .toList(),
                                ),
                                const SizedBox(height: 24),
                                Row(
                                  children: [
                                    const Text('실시간 혼잡도', style: TextStyle(fontSize: 14, color: Color(0xFF6B7280))),
                                    const Spacer(),
                                    StatusBadge(label: vm.realtimeStatus, color: vm.realtimeColor()),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(999),
                                  child: LinearProgressIndicator(
                                    value: vm.realtimeOccupancy,
                                    minHeight: 16,
                                    backgroundColor: const Color(0xFFE5E7EB),
                                    valueColor: AlwaysStoppedAnimation<Color>(vm.realtimeColor()),
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
                                children: [
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: Text('${vm.insights.length}건', style: const TextStyle(fontSize: 14, color: Color(0xFF6B7280))),
                                  ),
                                  const SizedBox(height: 12),
                                  ...vm.insights.map((insight) => _InsightTile(insight: insight)),
                                ],
                              ),
                            ),
                          const SizedBox(height: 24),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: WideCard(
                                  title: '시간대별 사용자 접속 현황',
                                  child: _HourlyUsageChart(points: vm.hourlyUsage),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: WideCard(
                                  title: '기능별 사용 비율',
                                  child: _FeatureUsageChart(slices: vm.featureUsage),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          WideCard(
                            title: '사용자 행동 퍼널',
                            child: Column(
                              children: vm.funnelSteps.map((item) => _FunnelRow(item: item)).toList(),
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

class _InsightTile extends StatelessWidget {
  const _InsightTile({required this.insight});

  final OperationalInsight insight;

  @override
  Widget build(BuildContext context) {
    final isWarning = insight.type == 'warning';
    final background = isWarning ? const Color(0xFFFEFCE8) : const Color(0xFFEFF6FF);
    final border = isWarning ? const Color(0xFFEAB308) : const Color(0xFF3B82F6);
    final iconColor = isWarning ? const Color(0xFFD97706) : const Color(0xFF2563EB);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(20),
        border: Border(left: BorderSide(color: border, width: 5)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.trending_up_rounded, color: iconColor),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(insight.message, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, height: 1.4)),
                const SizedBox(height: 6),
                Text(insight.time, style: const TextStyle(fontSize: 13, color: Color(0xFF6B7280))),
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

    final maxValue = points.map((point) => point.value).reduce((a, b) => a > b ? a : b);

    return SizedBox(
      height: 320,
      child: BarChart(
        BarChartData(
          maxY: maxValue == 0 ? 10 : maxValue + 20,
          alignment: BarChartAlignment.spaceAround,
          gridData: FlGridData(
            show: true,
            horizontalInterval: maxValue == 0 ? 2 : ((maxValue + 20) / 4).clamp(20, 120).toDouble(),
            getDrawingHorizontalLine: (value) => const FlLine(color: Color(0xFFD1D5DB), strokeWidth: 1, dashArray: [4, 4]),
            drawVerticalLine: false,
          ),
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 40,
                getTitlesWidget: (value, meta) => Text(
                  value.toInt().toString(),
                  style: const TextStyle(fontSize: 11, color: Color(0xFF6B7280)),
                ),
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 28,
                getTitlesWidget: (value, meta) => Text(
                  value.toInt().toString(),
                  style: const TextStyle(fontSize: 11, color: Color(0xFF6B7280)),
                ),
              ),
            ),
          ),
          barTouchData: BarTouchData(
            touchTooltipData: BarTouchTooltipData(
              tooltipBgColor: Colors.white,
              tooltipRoundedRadius: 12,
              tooltipBorder: const BorderSide(color: Color(0xFFE5E7EB)),
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                final hour = points[group.x.toInt()].hour;
                return BarTooltipItem(
                  '$hour시\n값: ${rod.toY.round()}',
                  const TextStyle(color: Color(0xFF111827), fontWeight: FontWeight.w700),
                );
              },
            ),
          ),
          barGroups: List.generate(points.length, (index) {
            final point = points[index];
            return BarChartGroupData(
              x: point.hour,
              barRods: [
                BarChartRodData(
                  toY: point.value,
                  width: 18,
                  borderRadius: BorderRadius.circular(4),
                  color: const Color(0xFFB5E0F5),
                ),
              ],
            );
          }),
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

    return SizedBox(
      height: 320,
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: PieChart(
              PieChartData(
                sectionsSpace: 2,
                centerSpaceRadius: 0,
                sections: slices
                    .map(
                      (slice) => PieChartSectionData(
                        value: slice.value.toDouble(),
                        color: slice.color,
                        radius: 86,
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
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Row(
                        children: [
                          Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(color: slice.color, shape: BoxShape.circle),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              '${slice.name} (${slice.value})',
                              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: slice.color == const Color(0xFFFDE68A) ? const Color(0xFFD97706) : const Color(0xFF374151)),
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
}

class _FunnelRow extends StatelessWidget {
  const _FunnelRow({required this.item});

  final FunnelStepData item;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(item.label, style: const TextStyle(fontSize: 15, color: Color(0xFF374151))),
              const Spacer(),
              Text('${_formatCount(item.count)}명 (${item.rate}%)', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: item.rate / 100,
              minHeight: 24,
              backgroundColor: const Color(0xFFE5E7EB),
              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFB5E0F5)),
            ),
          ),
        ],
      ),
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
            const Icon(Icons.error_outline_rounded, size: 42, color: Color(0xFFC85A54)),
            const SizedBox(height: 16),
            const Text('데이터를 불러오지 못했습니다', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
            const SizedBox(height: 8),
            Text(message, textAlign: TextAlign.center, style: const TextStyle(color: Color(0xFF6B7280), height: 1.5)),
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
