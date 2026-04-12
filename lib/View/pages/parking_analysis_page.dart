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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PageHeader(title: vm.pageTitle, subtitle: vm.pageSubtitle),
          Expanded(
            child: vm.isLoading
                ? const Center(child: CircularProgressIndicator())
                : vm.errorMessage != null
                    ? _ParkingAnalysisErrorView(message: vm.errorMessage!, onRetry: vm.load)
                    : ListView(
                        padding: const EdgeInsets.all(24),
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: vm.metrics
                                .map(
                                  (metric) => Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.only(right: 16),
                                      child: MetricCard(metric: metric),
                                    ),
                                  ),
                                )
                                .toList(),
                          ),
                          const SizedBox(height: 24),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: WideCard(
                                  title: '주차장별 선택 횟수 (오늘)',
                                  child: Column(
                                    children: vm.selectionData
                                        .map(
                                          (item) => Padding(
                                            padding: const EdgeInsets.only(bottom: 16),
                                            child: _SelectionRow(item: item, max: vm.selectionData.first.count),
                                          ),
                                        )
                                        .toList(),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: WideCard(
                                  title: '지도 사용 비율',
                                  child: Column(
                                    children: [
                                      ...vm.mapUsageData.map((item) => _SelectionRow(item: item, max: vm.mapUsageData.fold(0, (sum, value) => sum + value.count))),
                                      const SizedBox(height: 12),
                                      Text(
                                        '지도 사용률 ${((vm.mapUsageData.last.count / vm.mapUsageData.fold(0, (sum, value) => sum + value.count)) * 100).toStringAsFixed(1)}%',
                                        style: const TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
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
                            child: Column(
                              children: [
                                const Row(
                                  children: [
                                    SizedBox(width: 64, child: Text('순위', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF6B7280)))),
                                    Expanded(child: Text('주차장', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF6B7280)))),
                                    SizedBox(width: 120, child: Text('즐겨찾기 수', textAlign: TextAlign.right, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF6B7280)))),
                                    SizedBox(width: 120, child: Text('전일 대비', textAlign: TextAlign.right, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF6B7280)))),
                                    SizedBox(width: 80, child: Text('비율', textAlign: TextAlign.right, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF6B7280)))),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                ...vm.favoriteRanking.map((item) => _FavoriteRankingRow(item: item, total: vm.favoriteRanking.fold(0, (sum, value) => sum + value.count))),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: WideCard(
                                  title: '시간대별 지도 사용 현황',
                                  child: Column(
                                    children: vm.selectionData.take(4).map((item) => _SelectionRow(item: item, max: vm.selectionData.first.count)).toList(),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: WideCard(
                                  title: '주차장별 평균 앱 체류 시간',
                                  child: Column(
                                    children: vm.avgDurationData
                                        .map(
                                          (item) => Padding(
                                            padding: const EdgeInsets.only(bottom: 16),
                                            child: _SelectionRow(item: item, max: vm.avgDurationData.fold(0, (max, value) => value.count > max ? value.count : max), unit: '분'),
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
                            child: SizedBox(
                              height: 280,
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: vm.weeklyParkingData.map((point) => _WeeklyParkingBar(point: point)).toList(),
                              ),
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

class _SelectionRow extends StatelessWidget {
  const _SelectionRow({required this.item, required this.max, this.unit = '회'});

  final DistributionItem item;
  final int max;
  final String unit;

  @override
  Widget build(BuildContext context) {
    final ratio = max == 0 ? 0.0 : item.count / max;
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: Text(item.label, style: const TextStyle(fontSize: 14, color: Color(0xFF374151)))),
            Text('${item.count}$unit', style: const TextStyle(fontWeight: FontWeight.w700)),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: LinearProgressIndicator(
            value: ratio,
            minHeight: 18,
            backgroundColor: const Color(0xFFE5E7EB),
            valueColor: AlwaysStoppedAnimation<Color>(item.color),
          ),
        ),
      ],
    );
  }
}

class _FavoriteRankingRow extends StatelessWidget {
  const _FavoriteRankingRow({required this.item, required this.total});

  final FavoriteRankItem item;
  final int total;

  @override
  Widget build(BuildContext context) {
    final rate = total == 0 ? 0.0 : item.count / total;
    Color trendColor;
    String trendLabel;
    if (item.trend == 'up') {
      trendColor = const Color(0xFF16A34A);
      trendLabel = '↑ ${item.change.abs()}%';
    } else if (item.trend == 'down') {
      trendColor = const Color(0xFFDC2626);
      trendLabel = '↓ ${item.change.abs()}%';
    } else {
      trendColor = const Color(0xFF6B7280);
      trendLabel = '→ 변동없음';
    }

    Color rankBackground;
    Color rankForeground;
    switch (item.rank) {
      case 1:
        rankBackground = const Color(0xFFFEF3C7);
        rankForeground = const Color(0xFF92400E);
        break;
      case 2:
        rankBackground = const Color(0xFFF3F4F6);
        rankForeground = const Color(0xFF374151);
        break;
      case 3:
        rankBackground = const Color(0xFFFFEDD5);
        rankForeground = const Color(0xFF9A3412);
        break;
      default:
        rankBackground = const Color(0xFFEFF6FF);
        rankForeground = const Color(0xFF2563EB);
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: const BoxDecoration(border: Border(top: BorderSide(color: Color(0xFFE5E7EB)))),
      child: Row(
        children: [
          SizedBox(
            width: 64,
            child: Align(
              alignment: Alignment.centerLeft,
              child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(color: rankBackground, shape: BoxShape.circle),
                alignment: Alignment.center,
                child: Text('${item.rank}', style: TextStyle(fontWeight: FontWeight.w800, color: rankForeground)),
              ),
            ),
          ),
          Expanded(child: Text(item.name, style: const TextStyle(fontWeight: FontWeight.w700))),
          SizedBox(width: 120, child: Text('${item.count}', textAlign: TextAlign.right, style: const TextStyle(fontWeight: FontWeight.w700))),
          SizedBox(width: 120, child: Text(trendLabel, textAlign: TextAlign.right, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: trendColor))),
          SizedBox(width: 80, child: Text('${(rate * 100).toStringAsFixed(1)}%', textAlign: TextAlign.right, style: const TextStyle(color: Color(0xFF6B7280)))),
        ],
      ),
    );
  }
}

class _WeeklyParkingBar extends StatelessWidget {
  const _WeeklyParkingBar({required this.point});

  final WeeklyTrendPoint point;

  @override
  Widget build(BuildContext context) {
    final total = point.primary + point.secondary + point.tertiary;
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text('$total', style: const TextStyle(fontSize: 11, color: Color(0xFF6B7280))),
            const SizedBox(height: 8),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Flexible(
                    flex: point.tertiary,
                    child: Container(
                      width: double.infinity,
                      decoration: const BoxDecoration(
                        color: Color(0xFF38BDF8),
                        borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
                      ),
                    ),
                  ),
                  Flexible(
                    flex: point.secondary,
                    child: Container(width: double.infinity, color: const Color(0xFF7DD3FC)),
                  ),
                  Flexible(
                    flex: point.primary,
                    child: Container(width: double.infinity, color: const Color(0xFFB5E0F5)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Text(point.label, style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280))),
          ],
        ),
      ),
    );
  }
}

class _ParkingAnalysisErrorView extends StatelessWidget {
  const _ParkingAnalysisErrorView({required this.message, required this.onRetry});

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
            const Text('주차장 데이터를 불러오지 못했습니다', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
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
