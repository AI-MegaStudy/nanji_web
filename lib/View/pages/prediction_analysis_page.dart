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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PageHeader(title: vm.pageTitle, subtitle: vm.pageSubtitle),
          Expanded(
            child: vm.isLoading
                ? const Center(child: CircularProgressIndicator())
                : vm.errorMessage != null
                    ? _PredictionAnalysisErrorView(message: vm.errorMessage!, onRetry: vm.load)
                    : ListView(
                        padding: const EdgeInsets.all(24),
                        children: [
                          Wrap(
                            spacing: 16,
                            runSpacing: 16,
                            children: vm.metrics.map((metric) => MetricCard(metric: metric)).toList(),
                          ),
                          const SizedBox(height: 24),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: WideCard(
                                  title: '예측 대상 시간 분포',
                                  child: Column(
                                    children: [
                                      ...vm.predictionByHour.map(
                                        (item) => _DistributionBar(
                                          item: item,
                                          total: vm.predictionByHour.isEmpty ? 0 : vm.predictionByHour.first.count,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      _InfoBox(text: vm.predictionInsight, background: const Color(0xFFEFF6FF)),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: WideCard(
                                  title: '출발 타이밍 추천 분포',
                                  child: Column(
                                    children: [
                                      ...vm.departureTiming.map(
                                        (item) => _TimingTile(
                                          item: item,
                                          total: vm.departureTiming.fold(0, (sum, value) => sum + value.count),
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      _InfoBox(text: vm.departureInsight, background: const Color(0xFFF0FDF4)),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          WideCard(
                            title: '시간대별 예측 분포',
                            child: Column(
                              children: [
                                SizedBox(
                                  height: 280,
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: vm.hourlyPattern.map((point) => _TripleBar(point: point)).toList(),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Row(
                                  children: const [
                                    _LegendDot(color: Color(0xFFB5E0F5), label: '여유'),
                                    SizedBox(width: 16),
                                    _LegendDot(color: Color(0xFF7DD3FC), label: '보통'),
                                    SizedBox(width: 16),
                                    _LegendDot(color: Color(0xFF38BDF8), label: '혼잡'),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                _InfoBox(text: vm.hourlyInsight, background: const Color(0xFFF5F3FF)),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: WideCard(
                                  title: '요일별 예측 생성 현황',
                                  child: SizedBox(
                                    height: 280,
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: vm.weeklyPrediction.map((point) => _TripleBar(point: point)).toList(),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: WideCard(
                                  title: '예측 정확도 트렌드',
                                  child: Column(
                                    children: vm.accuracyTrend.map((item) => _AccuracyRow(item: item)).toList(),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          WideCard(
                            title: '예측 확인 후 사용자 행동',
                            child: Column(
                              children: vm.postActions.map((item) => _PostActionRow(item: item)).toList(),
                            ),
                          ),
                          const SizedBox(height: 24),
                          WideCard(
                            title: '혼잡도별 예측 조회 비율',
                            child: Column(
                              children: [
                                ...vm.congestionPrediction.map((item) => _CongestionCard(item: item)),
                                const SizedBox(height: 8),
                                _InfoBox(text: vm.congestionInsight, background: const Color(0xFFFEF2F2)),
                              ],
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

class _DistributionBar extends StatelessWidget {
  const _DistributionBar({required this.item, required this.total});

  final DistributionItem item;
  final int total;

  @override
  Widget build(BuildContext context) {
    final ratio = total == 0 ? 0.0 : item.count / total;
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(child: Text(item.label, style: const TextStyle(fontSize: 14, color: Color(0xFF374151)))),
              Text('${item.count}', style: const TextStyle(fontWeight: FontWeight.w700)),
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
      ),
    );
  }
}

class _TimingTile extends StatelessWidget {
  const _TimingTile({required this.item, required this.total});

  final DistributionItem item;
  final int total;

  @override
  Widget build(BuildContext context) {
    final ratio = total == 0 ? 0.0 : item.count / total;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: item.color.withOpacity(0.18),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Container(width: 14, height: 14, decoration: BoxDecoration(color: item.color, shape: BoxShape.circle)),
          const SizedBox(width: 12),
          Expanded(child: Text(item.label, style: const TextStyle(fontWeight: FontWeight.w700))),
          Text('${item.count}회', style: const TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(width: 12),
          Text('${(ratio * 100).round()}%', style: const TextStyle(color: Color(0xFF6B7280))),
        ],
      ),
    );
  }
}

class _TripleBar extends StatelessWidget {
  const _TripleBar({required this.point});

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
                  if (point.tertiary > 0)
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
                    child: Container(
                      width: double.infinity,
                      color: const Color(0xFF7DD3FC),
                    ),
                  ),
                  Flexible(
                    flex: point.primary,
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: const Color(0xFFB5E0F5),
                        borderRadius: point.tertiary == 0
                            ? const BorderRadius.vertical(top: Radius.circular(8))
                            : BorderRadius.zero,
                      ),
                    ),
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

class _AccuracyRow extends StatelessWidget {
  const _AccuracyRow({required this.item});

  final AccuracyPoint item;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          SizedBox(width: 26, child: Text(item.label, style: const TextStyle(color: Color(0xFF6B7280)))),
          const SizedBox(width: 8),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: LinearProgressIndicator(
                value: item.accuracy / 100,
                minHeight: 16,
                backgroundColor: const Color(0xFFE5E7EB),
                valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFFB923C)),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Text('${item.accuracy}%', style: const TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(width: 12),
          Text('${item.usage}', style: const TextStyle(color: Color(0xFF6B7280))),
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
      margin: const EdgeInsets.only(bottom: 14),
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
              Expanded(child: Text(item.label, style: const TextStyle(fontWeight: FontWeight.w700))),
              Text('${item.count}', style: const TextStyle(fontWeight: FontWeight.w700)),
              const SizedBox(width: 12),
              Text('${item.rate.toStringAsFixed(1)}%', style: const TextStyle(color: Color(0xFF6B7280))),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: item.rate / 100,
              minHeight: 16,
              backgroundColor: const Color(0xFFE5E7EB),
              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF7DD3FC)),
            ),
          ),
        ],
      ),
    );
  }
}

class _CongestionCard extends StatelessWidget {
  const _CongestionCard({required this.item});

  final CongestionPredictionItem item;

  @override
  Widget build(BuildContext context) {
    final total = item.prediction + item.noPrediction;
    final ratio = total == 0 ? 0.0 : item.prediction / total;
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: item.color.withOpacity(0.14),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(child: Text(item.label, style: const TextStyle(fontWeight: FontWeight.w700))),
              Text('예측 ${item.prediction}', style: const TextStyle(fontWeight: FontWeight.w700)),
              const SizedBox(width: 12),
              Text('비예측 ${item.noPrediction}', style: const TextStyle(color: Color(0xFF6B7280))),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: ratio,
              minHeight: 16,
              backgroundColor: const Color(0xFFE5E7EB),
              valueColor: AlwaysStoppedAnimation<Color>(item.color),
            ),
          ),
        ],
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
      children: [
        Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(fontSize: 13, color: Color(0xFF6B7280))),
      ],
    );
  }
}

class _InfoBox extends StatelessWidget {
  const _InfoBox({required this.text, required this.background});

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
      child: Text(
        text,
        style: const TextStyle(fontSize: 14, color: Color(0xFF374151), height: 1.5),
      ),
    );
  }
}

class _PredictionAnalysisErrorView extends StatelessWidget {
  const _PredictionAnalysisErrorView({required this.message, required this.onRetry});

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
            const Text('예측 분석 데이터를 불러오지 못했습니다', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
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
