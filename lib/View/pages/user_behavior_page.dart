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
                    ? _UserBehaviorErrorView(message: vm.errorMessage!, onRetry: vm.load)
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
                  title: '사용자 행동 퍼널',
                  child: Column(
                    children: [
                      ...vm.funnelSteps.map((item) => _FunnelRow(item: item)),
                      const SizedBox(height: 8),
                      _InfoMessage(text: vm.activeUserInsight, background: const Color(0xFFEFF6FF)),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: WideCard(
                        title: '세션 시간 분포',
                        child: Column(
                          children: [
                            ...vm.sessionDurations.map((item) => _DistributionRow(item: item, total: vm.sessionDurations.fold(0, (sum, value) => sum + value.count))),
                            const SizedBox(height: 8),
                            _InfoMessage(text: vm.sessionInsight, background: const Color(0xFFF5F3FF)),
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
                            ...vm.returnPatterns.map((item) => _PatternRow(item: item)),
                            const SizedBox(height: 8),
                            _InfoMessage(text: vm.returnInsight, background: const Color(0xFFF0FDF4)),
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
                    children: [
                      SizedBox(
                        height: 260,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: vm.weeklyActiveUsers.map((point) => _WeeklyStackBar(point: point)).toList(),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: const [
                          _LegendDot(color: Color(0xFFB5E0F5), label: '신규 사용자'),
                          SizedBox(width: 16),
                          _LegendDot(color: Color(0xFF6FA05C), label: '재방문 사용자'),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: WideCard(
                        title: '기능별 사용 빈도 (세션당 평균)',
                        child: Column(
                          children: vm.featureFrequency
                              .map(
                                (item) => Padding(
                                  padding: const EdgeInsets.only(bottom: 16),
                                  child: _HorizontalStatBar(
                                    label: item.label,
                                    valueLabel: (item.count / 10).toStringAsFixed(1),
                                    ratio: vm.featureFrequency.isEmpty || vm.featureFrequency.first.count == 0 ? 0 : item.count / vm.featureFrequency.first.count,
                                    color: item.color,
                                  ),
                                ),
                              )
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
                            ...vm.notificationStats.map((item) => _NotificationTile(item: item)),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                const Text('총 사용자', style: TextStyle(fontSize: 14, color: Color(0xFF6B7280))),
                                const Spacer(),
                                Text('${vm.totalActiveUsersText}명', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                              ],
                            ),
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
                    children: vm.dropOff.map((item) => _DropOffRow(item: item)).toList(),
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
              Text('${_formatCount(item.count)}명', style: const TextStyle(fontWeight: FontWeight.w700)),
              const SizedBox(width: 12),
              Text('(${item.rate}%)', style: const TextStyle(color: Color(0xFF6B7280))),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: item.rate / 100,
              minHeight: 24,
              backgroundColor: const Color(0xFFE5E7EB),
              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF7DD3FC)),
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

class _DistributionRow extends StatelessWidget {
  const _DistributionRow({required this.item, required this.total});

  final DistributionItem item;
  final int total;

  @override
  Widget build(BuildContext context) {
    final ratio = total == 0 ? 0.0 : item.count / total;
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        children: [
          Row(
            children: [
              Text(item.label, style: const TextStyle(fontSize: 14, color: Color(0xFF374151))),
              const Spacer(),
              Text('${item.count}명', style: const TextStyle(fontWeight: FontWeight.w700)),
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

class _PatternRow extends StatelessWidget {
  const _PatternRow({required this.item});

  final DistributionItem item;

  @override
  Widget build(BuildContext context) {
    final ratio = (item.percentage ?? 0) / 100;
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        children: [
          Row(
            children: [
              Text(item.label, style: const TextStyle(fontSize: 14, color: Color(0xFF374151))),
              const Spacer(),
              Text('${item.count}명 (${item.percentage}%)', style: const TextStyle(fontWeight: FontWeight.w700)),
            ],
          ),
          const SizedBox(height: 8),
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

class _WeeklyStackBar extends StatelessWidget {
  const _WeeklyStackBar({required this.point});

  final WeeklyTrendPoint point;

  @override
  Widget build(BuildContext context) {
    final total = point.primary + point.secondary;
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
                    flex: point.secondary,
                    child: Container(
                      width: double.infinity,
                      decoration: const BoxDecoration(
                        color: Color(0xFF6FA05C),
                        borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
                      ),
                    ),
                  ),
                  Flexible(
                    flex: point.primary,
                    child: Container(
                      width: double.infinity,
                      decoration: const BoxDecoration(
                        color: Color(0xFFB5E0F5),
                        borderRadius: BorderRadius.vertical(bottom: Radius.circular(8)),
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
            Expanded(child: Text(label, style: const TextStyle(fontSize: 14, color: Color(0xFF374151)))),
            Text(valueLabel, style: const TextStyle(fontWeight: FontWeight.w700)),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: LinearProgressIndicator(
            value: ratio,
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
            child: Text(item.label, style: const TextStyle(fontWeight: FontWeight.w700)),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('${item.count}', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: item.color)),
              Text('${item.percentage}% 설정', style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280))),
            ],
          ),
        ],
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
              Text('${item.count}명', style: const TextStyle(fontWeight: FontWeight.w700)),
              const SizedBox(width: 12),
              Text('${item.rate}%', style: const TextStyle(color: Color(0xFF6B7280))),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: item.rate / 100,
              minHeight: 14,
              backgroundColor: const Color(0xFFE5E7EB),
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoMessage extends StatelessWidget {
  const _InfoMessage({required this.text, required this.background});

  final String text;
  final Color background;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: background, borderRadius: BorderRadius.circular(16)),
      child: Text(text, style: const TextStyle(fontSize: 14, color: Color(0xFF374151), height: 1.5)),
    );
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
            const Icon(Icons.error_outline_rounded, color: Color(0xFFD14343), size: 48),
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
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              ),
              child: const Text('다시 시도'),
            ),
          ],
        ),
      ),
    );
  }
}
