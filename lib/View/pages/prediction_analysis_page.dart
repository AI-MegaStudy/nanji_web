import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../Model/admin_models.dart';
import '../../VM/prediction_analysis_viewmodel.dart';
import '../widgets/admin_widgets.dart';

class PredictionAnalysisPage extends StatelessWidget {
  const PredictionAnalysisPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => PredictionAnalysisViewModel(),
      child: const _PredictionAnalysisView(),
    );
  }
}

class _PredictionAnalysisView extends StatelessWidget {
  const _PredictionAnalysisView();

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<PredictionAnalysisViewModel>();

    return Container(
      color: const Color(0xFFF3F4F6),
      child: Column(
        children: [
          Expanded(
            child: vm.isLoading
                ? const Center(child: CircularProgressIndicator())
                : vm.errorMessage != null
                    ? _PredictionAnalysisErrorView(
                        message: vm.errorMessage!,
                        onRetry: vm.load,
                      )
                    : LayoutBuilder(
                        builder: (context, constraints) {
                          final contentWidth =
                              math.min(constraints.maxWidth, 1440.0);
                          final isCompact = contentWidth < 980;
                          final pairWidth = isCompact
                              ? contentWidth
                              : (contentWidth - 16) / 2;
                          final totalPredictions = vm.predictionByHour.fold<int>(
                            0,
                            (sum, item) => sum + item.count,
                          );
                          final totalDepartureTiming =
                              vm.departureTiming.fold<int>(
                            0,
                            (sum, item) => sum + item.count,
                          );
                          final topPrediction = vm.predictionByHour.isEmpty
                              ? null
                              : vm.predictionByHour.reduce(
                                  (a, b) => a.count >= b.count ? a : b,
                                );
                          final accuracyAverage = vm.accuracyTrend.isEmpty
                              ? 0.0
                              : vm.accuracyTrend
                                      .fold<int>(
                                        0,
                                        (sum, item) => sum + item.accuracy,
                                      ) /
                                  vm.accuracyTrend.length;
                          final hourlyPattern = _buildHourlyPattern(
                            vm.predictionByHour,
                          );
                          final weeklySeries = _buildWeeklyPredictionSeries(
                            vm.weeklyPrediction,
                          );

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
                                      spacing: 16,
                                      runSpacing: 16,
                                      children: [
                                        _TopStatCard(
                                          icon: Icons.trending_up_rounded,
                                          iconColor: const Color(0xFF2563EB),
                                          label: '총 예측 조회',
                                          value: _formatCompact(totalPredictions),
                                          caption: '오늘 전체',
                                        ),
                                        _TopStatCard(
                                          icon: Icons.track_changes_rounded,
                                          iconColor: const Color(0xFFEA580C),
                                          label: '가장 많이 조회',
                                          value: topPrediction?.label ?? '-',
                                          caption:
                                              '${_formatCompact(topPrediction?.count ?? 0)}회 조회',
                                          largeText: false,
                                        ),
                                        _TopStatCard(
                                          icon: Icons.schedule_rounded,
                                          iconColor: const Color(0xFF16A34A),
                                          label: '출발 타이밍 추천',
                                          value: _formatCompact(
                                            totalDepartureTiming,
                                          ),
                                          caption: '오늘 전체',
                                        ),
                                        _TopStatCard(
                                          icon: Icons.calendar_month_rounded,
                                          iconColor: const Color(0xFF7C3AED),
                                          label: '예측 정확도',
                                          value:
                                              '${accuracyAverage.toStringAsFixed(1)}%',
                                          caption: '지난 7일 평균',
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 24),
                                    Wrap(
                                      spacing: 16,
                                      runSpacing: 16,
                                      children: [
                                        SizedBox(
                                          width: pairWidth,
                                          child: WideCard(
                                            title: '예측 시간대별 조회 분포',
                                            child: Column(
                                              children: [
                                                ...vm.predictionByHour.map(
                                                  (item) => Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                      bottom: 16,
                                                    ),
                                                    child: _BarTile(
                                                      label: item.label,
                                                      value:
                                                          '${_formatCompact(item.count)}회',
                                                      ratio: _ratioFor(
                                                        vm.predictionByHour,
                                                        item.count,
                                                      ),
                                                      color: item.color,
                                                    ),
                                                  ),
                                                ),
                                                _InsightBox(
                                                  text: vm.predictionInsight,
                                                  background:
                                                      const Color(0xFFEFF6FF),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        SizedBox(
                                          width: pairWidth,
                                          child: WideCard(
                                            title: '출발 타이밍 추천 분포',
                                            child: Column(
                                              children: [
                                                _CircularRatioSummary(
                                                  items: vm.departureTiming,
                                                  total: totalDepartureTiming,
                                                ),
                                                const SizedBox(height: 20),
                                                ...vm.departureTiming.map(
                                                  (item) => Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                      bottom: 14,
                                                    ),
                                                    child: _LegendValueRow(
                                                      color: item.color,
                                                      label: item.label,
                                                      value:
                                                          '${_formatCompact(item.count)}회',
                                                      detail:
                                                          '${totalDepartureTiming == 0 ? 0 : ((item.count / totalDepartureTiming) * 100).toStringAsFixed(1)}%',
                                                    ),
                                                  ),
                                                ),
                                                _InsightBox(
                                                  text: vm.departureInsight,
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
                                      title: '시간대별 예측 조회 패턴',
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          SizedBox(
                                            height: 300,
                                            child: _MultiSeriesBars(
                                              series: hourlyPattern,
                                              labels: const [
                                                '0',
                                                '2',
                                                '4',
                                                '6',
                                                '8',
                                                '10',
                                                '12',
                                                '14',
                                                '16',
                                                '18',
                                                '20',
                                                '22',
                                              ],
                                            ),
                                          ),
                                          const SizedBox(height: 16),
                                          const Wrap(
                                            spacing: 16,
                                            runSpacing: 8,
                                            children: [
                                              _LegendValueChip(
                                                color: Color(0xFFB5E0F5),
                                                label: '1시간 후',
                                              ),
                                              _LegendValueChip(
                                                color: Color(0xFF7DD3FC),
                                                label: '2시간 후',
                                              ),
                                              _LegendValueChip(
                                                color: Color(0xFF38BDF8),
                                                label: '3시간 후',
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 16),
                                          _InsightBox(
                                            text: vm.hourlyInsight,
                                            background:
                                                const Color(0xFFF5F3FF),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 24),
                                    Wrap(
                                      spacing: 16,
                                      runSpacing: 16,
                                      children: [
                                        SizedBox(
                                          width: pairWidth,
                                          child: WideCard(
                                            title: '요일별 예측 사용 현황',
                                            child: Column(
                                              children: weeklySeries
                                                  .map(
                                                    (series) => Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                        bottom: 16,
                                                      ),
                                                      child: _WeeklyTrendRow(
                                                        label: series.label,
                                                        values: series.values,
                                                        color: series.color,
                                                      ),
                                                    ),
                                                  )
                                                  .toList(),
                                            ),
                                          ),
                                        ),
                                        SizedBox(
                                          width: pairWidth,
                                          child: WideCard(
                                            title: '예측 정확도 트렌드',
                                            child: Column(
                                              children: vm.accuracyTrend
                                                  .map(
                                                    (item) => Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                        bottom: 16,
                                                      ),
                                                      child: _AccuracyTile(
                                                        item: item,
                                                      ),
                                                    ),
                                                  )
                                                  .toList(),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 24),
                                    WideCard(
                                      title: '예측 확인 후 사용자 행동',
                                      child: Column(
                                        children: [
                                          if (isCompact)
                                            ...vm.postActions.map(
                                              (item) => _PostActionCard(
                                                item: item,
                                              ),
                                            )
                                          else
                                            Column(
                                              children: [
                                                const Padding(
                                                  padding: EdgeInsets.only(
                                                    bottom: 12,
                                                  ),
                                                  child: Row(
                                                    children: [
                                                      Expanded(
                                                        child: Text(
                                                          '행동',
                                                          style: TextStyle(
                                                            fontSize: 13,
                                                            fontWeight:
                                                                FontWeight.w700,
                                                            color: Color(
                                                              0xFF6B7280,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                      SizedBox(
                                                        width: 110,
                                                        child: Text(
                                                          '횟수',
                                                          textAlign:
                                                              TextAlign.right,
                                                          style: TextStyle(
                                                            fontSize: 13,
                                                            fontWeight:
                                                                FontWeight.w700,
                                                            color: Color(
                                                              0xFF6B7280,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                      SizedBox(
                                                        width: 110,
                                                        child: Text(
                                                          '비율',
                                                          textAlign:
                                                              TextAlign.right,
                                                          style: TextStyle(
                                                            fontSize: 13,
                                                            fontWeight:
                                                                FontWeight.w700,
                                                            color: Color(
                                                              0xFF6B7280,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                      SizedBox(
                                                        width: 220,
                                                        child: Text(
                                                          '진행률',
                                                          textAlign:
                                                              TextAlign.right,
                                                          style: TextStyle(
                                                            fontSize: 13,
                                                            fontWeight:
                                                                FontWeight.w700,
                                                            color: Color(
                                                              0xFF6B7280,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                ...vm.postActions.map(
                                                  (item) => _PostActionRow(
                                                    item: item,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          const SizedBox(height: 12),
                                          const _InsightBox(
                                            text:
                                                '예측 확인 후 이어지는 지도 확인, 출발 타이밍 조회, 즐겨찾기 행동을 한 화면에서 추적합니다.',
                                            background: Color(0xFFFFFBEB),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 24),
                                    WideCard(
                                      title: '혼잡도별 예측 조회 비율',
                                      child: Column(
                                        children: [
                                          ...vm.congestionPrediction.map(
                                            (item) => Padding(
                                              padding: const EdgeInsets.only(
                                                bottom: 14,
                                              ),
                                              child:
                                                  _CongestionPredictionCard(
                                                item: item,
                                              ),
                                            ),
                                          ),
                                          _InsightBox(
                                            text: vm.congestionInsight,
                                            background:
                                                const Color(0xFFFEF2F2),
                                          ),
                                        ],
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

class _TopStatCard extends StatelessWidget {
  const _TopStatCard({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
    required this.caption,
    this.largeText = true,
  });

  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;
  final String caption;
  final bool largeText;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 240,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
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
              Icon(icon, size: 24, color: iconColor),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF6B7280),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            value,
            style: TextStyle(
              fontSize: largeText ? 30 : 22,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF111827),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            caption,
            style: const TextStyle(fontSize: 12, color: Color(0xFF9CA3AF)),
          ),
        ],
      ),
    );
  }
}

class _BarTile extends StatelessWidget {
  const _BarTile({
    required this.label,
    required this.value,
    required this.ratio,
    required this.color,
  });

  final String label;
  final String value;
  final double ratio;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF374151),
                ),
              ),
            ),
            Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: LinearProgressIndicator(
            value: ratio.clamp(0.0, 1.0),
            minHeight: 18,
            backgroundColor: const Color(0xFFE5E7EB),
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }
}

class _CircularRatioSummary extends StatelessWidget {
  const _CircularRatioSummary({required this.items, required this.total});

  final List<DistributionItem> items;
  final int total;

  @override
  Widget build(BuildContext context) {
    final top = items.isEmpty
        ? null
        : items.reduce((a, b) => a.count >= b.count ? a : b);
    final ratio = total == 0 || top == null ? 0.0 : top.count / total;

    return SizedBox(
      height: 180,
      child: Center(
        child: Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: const Color(0xFFE5E7EB),
                  width: 22,
                ),
              ),
            ),
            Transform.rotate(
              angle: -math.pi / 2,
              child: SizedBox(
                width: 180,
                height: 180,
                child: CircularProgressIndicator(
                  value: ratio,
                  strokeWidth: 22,
                  backgroundColor: Colors.transparent,
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    Color(0xFF6FA05C),
                  ),
                ),
              ),
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  top?.label ?? '-',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF111827),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '${(ratio * 100).toStringAsFixed(1)}%',
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF111827),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _LegendValueRow extends StatelessWidget {
  const _LegendValueRow({
    required this.color,
    required this.label,
    required this.value,
    required this.detail,
  });

  final Color color;
  final String label;
  final String value;
  final String detail;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF374151),
            ),
          ),
        ),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w700)),
        const SizedBox(width: 10),
        Text(
          detail,
          style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
        ),
      ],
    );
  }
}

class _MultiSeriesBars extends StatelessWidget {
  const _MultiSeriesBars({
    required this.series,
    required this.labels,
  });

  final List<_SeriesData> series;
  final List<String> labels;

  @override
  Widget build(BuildContext context) {
    final maxValue = series.fold<double>(
      0,
      (max, item) => math.max(max, item.values.fold<double>(0, math.max)),
    );

    return Column(
      children: [
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              for (var i = 0; i < labels.length; i++)
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 3),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        for (final item in series)
                          Expanded(
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 1),
                              child: Container(
                                height: maxValue == 0
                                    ? 0
                                    : (item.values[i] / maxValue) * 220,
                                decoration: BoxDecoration(
                                  color: item.color,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            for (final label in labels)
              Expanded(
                child: Text(
                  label,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 10,
                    color: Color(0xFF6B7280),
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}

class _LegendValueChip extends StatelessWidget {
  const _LegendValueChip({required this.color, required this.label});

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
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
        ),
      ],
    );
  }
}

class _WeeklyTrendRow extends StatelessWidget {
  const _WeeklyTrendRow({
    required this.label,
    required this.values,
    required this.color,
  });

  final String label;
  final List<int> values;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final maxValue = values.fold<int>(0, math.max);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            for (var i = 0; i < values.length; i++)
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 3),
                  child: Column(
                    children: [
                      Container(
                        height: 10,
                        decoration: BoxDecoration(
                          color: const Color(0xFFE5E7EB),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: FractionallySizedBox(
                          alignment: Alignment.centerLeft,
                          widthFactor: maxValue == 0 ? 0 : values[i] / maxValue,
                          child: Container(
                            decoration: BoxDecoration(
                              color: color,
                              borderRadius: BorderRadius.circular(999),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        const ['월', '화', '수', '목', '금', '토', '일'][i],
                        style: const TextStyle(
                          fontSize: 10,
                          color: Color(0xFF6B7280),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}

class _AccuracyTile extends StatelessWidget {
  const _AccuracyTile({required this.item});

  final AccuracyPoint item;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  item.label,
                  style: const TextStyle(color: Color(0xFF6B7280)),
                ),
              ),
              Text(
                '${item.accuracy}%',
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              const SizedBox(width: 10),
              Text(
                '${item.usage}',
                style: const TextStyle(color: Color(0xFF6B7280)),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: item.accuracy / 100,
              minHeight: 16,
              backgroundColor: const Color(0xFFE5E7EB),
              valueColor: const AlwaysStoppedAnimation<Color>(
                Color(0xFFFB923C),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PostActionRow extends StatelessWidget {
  const _PostActionRow({required this.item});

  final PostActionItem item;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: Color(0xFFE5E7EB))),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              item.label,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
          SizedBox(
            width: 110,
            child: Text(
              _formatCompact(item.count),
              textAlign: TextAlign.right,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
          SizedBox(
            width: 110,
            child: Text(
              '${item.rate.toStringAsFixed(1)}%',
              textAlign: TextAlign.right,
              style: const TextStyle(color: Color(0xFF6B7280)),
            ),
          ),
          SizedBox(
            width: 220,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: LinearProgressIndicator(
                value: item.rate / 100,
                minHeight: 12,
                backgroundColor: const Color(0xFFE5E7EB),
                valueColor: const AlwaysStoppedAnimation<Color>(
                  Color(0xFF7DD3FC),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PostActionCard extends StatelessWidget {
  const _PostActionCard({required this.item});

  final PostActionItem item;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  item.label,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
              Text(
                _formatCompact(item.count),
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            '${item.rate.toStringAsFixed(1)}%',
            style: const TextStyle(color: Color(0xFF6B7280)),
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: item.rate / 100,
              minHeight: 12,
              backgroundColor: const Color(0xFFE5E7EB),
              valueColor: const AlwaysStoppedAnimation<Color>(
                Color(0xFF7DD3FC),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CongestionPredictionCard extends StatelessWidget {
  const _CongestionPredictionCard({required this.item});

  final CongestionPredictionItem item;

  @override
  Widget build(BuildContext context) {
    final total = item.prediction + item.noPrediction;
    final ratio = total == 0 ? 0.0 : item.prediction / total;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: item.color, width: 2),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 14,
                height: 14,
                decoration: BoxDecoration(
                  color: item.color,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  '${item.label} 상태',
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
              Text(
                '예측 조회율 ${(ratio * 100).toStringAsFixed(1)}%',
                style: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFF6B7280),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _MetricMiniTile(
                  label: '예측 조회',
                  value: _formatCompact(item.prediction),
                  color: item.color,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _MetricMiniTile(
                  label: '예측 미조회',
                  value: _formatCompact(item.noPrediction),
                  color: const Color(0xFF9CA3AF),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: ratio,
              minHeight: 12,
              backgroundColor: const Color(0xFFE5E7EB),
              valueColor: AlwaysStoppedAnimation<Color>(item.color),
            ),
          ),
        ],
      ),
    );
  }
}

class _MetricMiniTile extends StatelessWidget {
  const _MetricMiniTile({
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
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(14),
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

class _InsightBox extends StatelessWidget {
  const _InsightBox({required this.text, required this.background});

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
            fontSize: 14,
            color: Color(0xFF374151),
            height: 1.5,
          ),
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

class _PredictionAnalysisErrorView extends StatelessWidget {
  const _PredictionAnalysisErrorView({
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
              '예측 분석 데이터를 불러오지 못했습니다',
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

List<_SeriesData> _buildHourlyPattern(List<DistributionItem> source) {
  final oneHour = source.isNotEmpty ? source.first.count : 0;
  final twoHour = source.length > 1 ? source[1].count : oneHour ~/ 2;
  final threeHour = source.length > 2 ? source[2].count : twoHour ~/ 2;

  List<double> build(int seed, double scale, double peak) {
    return List<double>.generate(12, (index) {
      final active = index >= 4 && index <= 9 ? peak : 0.55;
      final offset = ((seed + index * 19) % 40).toDouble();
      return (seed * scale * active) + offset + 12;
    });
  }

  return [
    _SeriesData(
      label: '1시간 후',
      color: const Color(0xFFB5E0F5),
      values: build(oneHour, 0.06, 1.2),
    ),
    _SeriesData(
      label: '2시간 후',
      color: const Color(0xFF7DD3FC),
      values: build(twoHour, 0.05, 1.05),
    ),
    _SeriesData(
      label: '3시간 후',
      color: const Color(0xFF38BDF8),
      values: build(threeHour, 0.045, 0.95),
    ),
  ];
}

List<_WeeklySeries> _buildWeeklyPredictionSeries(List<WeeklyTrendPoint> weekly) {
  final rows = weekly.isEmpty
      ? [
          const WeeklyTrendPoint(label: '1시간 후', primary: 0, secondary: 0),
          const WeeklyTrendPoint(label: '2시간 후', primary: 0, secondary: 0),
          const WeeklyTrendPoint(label: '3시간 후', primary: 0, secondary: 0),
        ]
      : weekly;

  final first = rows.isNotEmpty ? rows[0] : const WeeklyTrendPoint(label: '', primary: 0, secondary: 0);
  final second = rows.length > 1 ? rows[1] : first;

  List<int> makeValues(int a, int b) {
    return List<int>.generate(7, (index) {
      final weekendBoost = index >= 4 ? 80 : 0;
      return (a ~/ 20) + (b ~/ 25) + weekendBoost + (index * 9);
    });
  }

  return [
    _WeeklySeries(
      label: '1시간 후',
      values: makeValues(first.primary, first.secondary),
      color: const Color(0xFFB5E0F5),
    ),
    _WeeklySeries(
      label: '2시간 후',
      values: makeValues(second.primary, second.secondary),
      color: const Color(0xFF7DD3FC),
    ),
    _WeeklySeries(
      label: '3시간 후',
      values: makeValues(first.tertiary + second.tertiary, first.primary ~/ 3),
      color: const Color(0xFF38BDF8),
    ),
  ];
}

double _ratioFor(List<DistributionItem> items, int count) {
  final maxCount = items.fold<int>(0, (max, item) => math.max(max, item.count));
  if (maxCount == 0) return 0;
  return count / maxCount;
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

class _SeriesData {
  const _SeriesData({
    required this.label,
    required this.color,
    required this.values,
  });

  final String label;
  final Color color;
  final List<double> values;
}

class _WeeklySeries {
  const _WeeklySeries({
    required this.label,
    required this.values,
    required this.color,
  });

  final String label;
  final List<int> values;
  final Color color;
}
