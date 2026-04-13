import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../Model/admin_models.dart';
import '../../VM/parking_analysis_viewmodel.dart';
import '../widgets/admin_widgets.dart';

class ParkingAnalysisPage extends StatelessWidget {
  const ParkingAnalysisPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ParkingAnalysisViewModel(),
      child: const _ParkingAnalysisView(),
    );
  }
}

class _ParkingAnalysisView extends StatelessWidget {
  const _ParkingAnalysisView();

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ParkingAnalysisViewModel>();

    return Container(
      color: const Color(0xFFF3F4F6),
      child: Column(
        children: [
          Expanded(
            child: vm.isLoading
                ? const Center(child: CircularProgressIndicator())
                : vm.errorMessage != null
                    ? _ParkingAnalysisErrorView(
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
                          final totalFavorites = vm.favoriteRanking.fold<int>(
                            0,
                            (sum, item) => sum + item.count,
                          );
                          final mapTotal = vm.mapUsageData.fold<int>(
                            0,
                            (sum, item) => sum + item.count,
                          );
                          final mapUsed = vm.mapUsageData.firstWhere(
                            (item) => item.label.contains('지도'),
                            orElse: () => const DistributionItem(
                              label: '지도 확인',
                              count: 0,
                              color: Color(0xFF6FA05C),
                            ),
                          );
                          final mapUsageRate = mapTotal == 0
                              ? 0.0
                              : (mapUsed.count / mapTotal) * 100;
                          final topParking = vm.selectionData.isEmpty
                              ? null
                              : vm.selectionData.reduce(
                                  (a, b) => a.count >= b.count ? a : b,
                                );
                          final hourlyMapUsage = _buildHourlyMapUsage(
                            vm.selectionData,
                            mapUsed.count,
                          );
                          final weeklySeries = _buildWeeklySeries(
                            vm.selectionData,
                            vm.weeklyParkingData,
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
                                          icon: Icons.star_rounded,
                                          iconColor: const Color(0xFFD97706),
                                          label: '총 즐겨찾기',
                                          value: _formatCompact(totalFavorites),
                                          caption:
                                              '${vm.favoriteRanking.length}개 주차장 합계',
                                        ),
                                        _TopStatCard(
                                          icon: Icons.map_rounded,
                                          iconColor: const Color(0xFF0891B2),
                                          label: '지도 사용률',
                                          value:
                                              '${mapUsageRate.toStringAsFixed(1)}%',
                                          caption:
                                              '${_formatCompact(mapUsed.count)}명이 지도 확인',
                                        ),
                                        _TopStatCard(
                                          icon: Icons.visibility_rounded,
                                          iconColor: const Color(0xFF7C3AED),
                                          label: '가장 인기있는 주차장',
                                          value: topParking?.label ?? '-',
                                          caption:
                                              '${_formatCompact(topParking?.count ?? 0)}회 조회',
                                          largeText: false,
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
                                            title: '주차장별 선택 횟수 (오늘)',
                                            child: Column(
                                              children: vm.selectionData
                                                  .map(
                                                    (item) => Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                        bottom: 16,
                                                      ),
                                                      child: _SelectionBarTile(
                                                        label: item.label,
                                                        value:
                                                            '${_formatCompact(item.count)}회',
                                                        ratio: _maxRatio(
                                                          vm.selectionData,
                                                          item.count,
                                                        ),
                                                        color: item.color,
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
                                            title: '지도 사용 비율',
                                            child: Column(
                                              children: [
                                                _UsageSplitBar(
                                                  used: mapUsed.count,
                                                  total: mapTotal,
                                                  usedColor:
                                                      const Color(0xFF6FA05C),
                                                ),
                                                const SizedBox(height: 20),
                                                ...vm.mapUsageData.map(
                                                  (item) => Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                      bottom: 14,
                                                    ),
                                                    child: _LegendValueRow(
                                                      color: item.color,
                                                      label: item.label,
                                                      value:
                                                          '${_formatCompact(item.count)}명',
                                                      detail:
                                                          '${mapTotal == 0 ? 0 : ((item.count / mapTotal) * 100).toStringAsFixed(1)}%',
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 24),
                                    WideCard(
                                      title: '즐겨찾기 순위',
                                      child: isCompact
                                          ? Column(
                                              children: vm.favoriteRanking
                                                  .map(
                                                    (item) =>
                                                        _FavoriteRankCard(
                                                      item: item,
                                                      total: totalFavorites,
                                                    ),
                                                  )
                                                  .toList(),
                                            )
                                          : Column(
                                              children: [
                                                const Padding(
                                                  padding: EdgeInsets.only(
                                                    bottom: 12,
                                                  ),
                                                  child: Row(
                                                    children: [
                                                      SizedBox(
                                                        width: 72,
                                                        child: Text(
                                                          '순위',
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
                                                      Expanded(
                                                        child: Text(
                                                          '주차장',
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
                                                        width: 120,
                                                        child: Text(
                                                          '즐겨찾기 수',
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
                                                        width: 120,
                                                        child: Text(
                                                          '전일 대비',
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
                                                        width: 80,
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
                                                    ],
                                                  ),
                                                ),
                                                ...vm.favoriteRanking.map(
                                                  (item) => _FavoriteRankRow(
                                                    item: item,
                                                    total: totalFavorites,
                                                  ),
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
                                            title: '시간대별 지도 사용 현황',
                                            child: SizedBox(
                                              height: 280,
                                              child: _MiniLineChart(
                                                points: hourlyMapUsage,
                                                color: const Color(0xFF6FA05C),
                                                labelBuilder: (index) =>
                                                    '${index * 2}',
                                              ),
                                            ),
                                          ),
                                        ),
                                        SizedBox(
                                          width: pairWidth,
                                          child: WideCard(
                                            title: '주차장별 평균 앱 체류 시간',
                                            child: Column(
                                              children: vm.avgDurationData
                                                  .map(
                                                    (item) => Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                        bottom: 16,
                                                      ),
                                                      child: _SelectionBarTile(
                                                        label: item.label,
                                                        value:
                                                            '${item.count}분',
                                                        ratio: _maxRatio(
                                                          vm.avgDurationData,
                                                          item.count,
                                                        ),
                                                        color: const Color(
                                                          0xFFFB923C,
                                                        ),
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
                                      title: '요일별 주차장 선택 추이',
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
      width: 320,
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

class _SelectionBarTile extends StatelessWidget {
  const _SelectionBarTile({
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

class _UsageSplitBar extends StatelessWidget {
  const _UsageSplitBar({
    required this.used,
    required this.total,
    required this.usedColor,
  });

  final int used;
  final int total;
  final Color usedColor;

  @override
  Widget build(BuildContext context) {
    final ratio = total == 0 ? 0.0 : used / total;

    return Column(
      children: [
        SizedBox(
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
                      valueColor: AlwaysStoppedAnimation<Color>(usedColor),
                    ),
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${(ratio * 100).toStringAsFixed(1)}%',
                      style: const TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF111827),
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      '지도 사용률',
                      style: TextStyle(
                        fontSize: 13,
                        color: Color(0xFF6B7280),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
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
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        const SizedBox(width: 10),
        Text(
          detail,
          style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
        ),
      ],
    );
  }
}

class _FavoriteRankRow extends StatelessWidget {
  const _FavoriteRankRow({required this.item, required this.total});

  final FavoriteRankItem item;
  final int total;

  @override
  Widget build(BuildContext context) {
    final rate = total == 0 ? 0.0 : (item.count / total) * 100;
    final trend = _trendMeta(item.trend, item.change);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: Color(0xFFE5E7EB))),
      ),
      child: Row(
        children: [
          SizedBox(width: 72, child: _RankBadge(rank: item.rank)),
          Expanded(
            child: Text(
              item.name,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
          SizedBox(
            width: 120,
            child: Text(
              _formatCompact(item.count),
              textAlign: TextAlign.right,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
          SizedBox(
            width: 120,
            child: Align(
              alignment: Alignment.centerRight,
              child: _TrendBadge(
                label: trend.$1,
                background: trend.$2,
                foreground: trend.$3,
              ),
            ),
          ),
          SizedBox(
            width: 80,
            child: Text(
              '${rate.toStringAsFixed(1)}%',
              textAlign: TextAlign.right,
              style: const TextStyle(color: Color(0xFF6B7280)),
            ),
          ),
        ],
      ),
    );
  }
}

class _FavoriteRankCard extends StatelessWidget {
  const _FavoriteRankCard({required this.item, required this.total});

  final FavoriteRankItem item;
  final int total;

  @override
  Widget build(BuildContext context) {
    final rate = total == 0 ? 0.0 : (item.count / total) * 100;
    final trend = _trendMeta(item.trend, item.change);

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
              _RankBadge(rank: item.rank),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  item.name,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
              Text(
                _formatCompact(item.count),
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 8,
            children: [
              _TrendBadge(
                label: trend.$1,
                background: trend.$2,
                foreground: trend.$3,
              ),
              Text(
                '비율 ${rate.toStringAsFixed(1)}%',
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF6B7280),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _RankBadge extends StatelessWidget {
  const _RankBadge({required this.rank});

  final int rank;

  @override
  Widget build(BuildContext context) {
    late final Color background;
    late final Color foreground;

    switch (rank) {
      case 1:
        background = const Color(0xFFFEF3C7);
        foreground = const Color(0xFFA16207);
        break;
      case 2:
        background = const Color(0xFFF3F4F6);
        foreground = const Color(0xFF4B5563);
        break;
      case 3:
        background = const Color(0xFFFFEDD5);
        foreground = const Color(0xFF9A3412);
        break;
      default:
        background = const Color(0xFFEFF6FF);
        foreground = const Color(0xFF2563EB);
    }

    return Container(
      width: 34,
      height: 34,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: background,
        shape: BoxShape.circle,
      ),
      child: Text(
        '$rank',
        style: TextStyle(fontWeight: FontWeight.w800, color: foreground),
      ),
    );
  }
}

class _TrendBadge extends StatelessWidget {
  const _TrendBadge({
    required this.label,
    required this.background,
    required this.foreground,
  });

  final String label;
  final Color background;
  final Color foreground;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: foreground,
        ),
      ),
    );
  }
}

class _MiniLineChart extends StatelessWidget {
  const _MiniLineChart({
    required this.points,
    required this.color,
    required this.labelBuilder,
  });

  final List<double> points;
  final Color color;
  final String Function(int index) labelBuilder;

  @override
  Widget build(BuildContext context) {
    final maxValue = points.fold<double>(0, math.max);

    return Column(
      children: [
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              for (var i = 0; i < points.length; i++)
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Container(
                          height: maxValue == 0
                              ? 0
                              : (points[i] / maxValue) * 200,
                          decoration: BoxDecoration(
                            color: color.withValues(alpha: 0.85),
                            borderRadius: BorderRadius.circular(8),
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
            for (var i = 0; i < points.length; i++)
              Expanded(
                child: Text(
                  labelBuilder(i),
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
        Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            Text(
              '최대 ${_formatCompact(maxValue)}',
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF6B7280),
              ),
            ),
          ],
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

class _ParkingAnalysisErrorView extends StatelessWidget {
  const _ParkingAnalysisErrorView({
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
              '주차장 데이터를 불러오지 못했습니다',
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

List<double> _buildHourlyMapUsage(List<DistributionItem> selections, int mapUsed) {
  final base = math.max(1, mapUsed ~/ 6);
  final selectionSeed = selections.fold<int>(0, (sum, item) => sum + item.count);
  return List<double>.generate(12, (index) {
    final weight = index >= 4 && index <= 9 ? 1.0 : 0.55;
    final offset = ((selectionSeed + index * 17) % 35).toDouble();
    return base * weight + offset + 12;
  });
}

List<_WeeklySeries> _buildWeeklySeries(
  List<DistributionItem> selections,
  List<WeeklyTrendPoint> weekly,
) {
  const palette = [
    Color(0xFFB5E0F5),
    Color(0xFF7DD3FC),
    Color(0xFF38BDF8),
    Color(0xFF0EA5E9),
    Color(0xFF0284C7),
  ];
  final source = weekly.isEmpty
      ? List<WeeklyTrendPoint>.generate(
          7,
          (index) => const WeeklyTrendPoint(label: '', primary: 0, secondary: 0),
        )
      : weekly;

  return List<_WeeklySeries>.generate(
    math.min(selections.length, 5),
    (index) {
      final seed = selections[index].count;
      final values = List<int>.generate(source.length, (dayIndex) {
        final total = source[dayIndex].primary +
            source[dayIndex].secondary +
            source[dayIndex].tertiary;
        final scaled = total == 0
            ? ((seed * (dayIndex + 2)) % 180) + (dayIndex >= 4 ? 120 : 60)
            : math.max(1, (seed / 5).round() + total ~/ (index + 2));
        return scaled;
      });
      return _WeeklySeries(
        label: selections[index].label,
        values: values,
        color: palette[index % palette.length],
      );
    },
  );
}

double _maxRatio(List<DistributionItem> items, int count) {
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

(String, Color, Color) _trendMeta(String trend, int change) {
  if (trend == 'up') {
    return (
      '↑ ${change.abs()}%',
      const Color(0xFFDCFCE7),
      const Color(0xFF166534),
    );
  }
  if (trend == 'down') {
    return (
      '↓ ${change.abs()}%',
      const Color(0xFFFEE2E2),
      const Color(0xFFB91C1C),
    );
  }
  return (
    '→ 변동없음',
    const Color(0xFFF3F4F6),
    const Color(0xFF4B5563),
  );
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
