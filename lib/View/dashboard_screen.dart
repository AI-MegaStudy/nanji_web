import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../Model/parking_models.dart';
import '../VM/dashboard_viewmodel.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<DashboardViewModel>(context);
    final selectedPark = viewModel.selectedPark;
    final parkingLots = selectedPark?.parkingLots ?? [];

    final totalSpaces = parkingLots.fold<int>(0, (sum, lot) => sum + lot.totalSpaces);
    final occupiedSpaces = parkingLots.fold<int>(0, (sum, lot) => sum + lot.occupiedSpaces);
    final availableSpaces = totalSpaces - occupiedSpaces;
    final occupancyRate = totalSpaces > 0 ? occupiedSpaces / totalSpaces : 0.0;
    final statusLabel = occupancyRate < 0.5
        ? '여유'
        : occupancyRate < 0.8
            ? '보통'
            : '만차';
    final statusColor = occupancyRate < 0.5
        ? const Color(0xFF6FA05C)
        : occupancyRate < 0.8
            ? const Color(0xFFE59548)
            : const Color(0xFFC85A54);

    final metricCards = [
      _DashboardMetric(
        icon: Icons.people_rounded,
        label: '오늘 방문자',
        value: '2,847명',
        color: const Color(0xFF3B82F6),
      ),
      _DashboardMetric(
        icon: Icons.remove_red_eye_rounded,
        label: '혼잡도 조회',
        value: '5,234회',
        color: const Color(0xFF8B5CF6),
      ),
      _DashboardMetric(
        icon: Icons.trending_up_rounded,
        label: '예측 조회',
        value: '3,892회',
        color: const Color(0xFFFB923C),
      ),
      _DashboardMetric(
        icon: Icons.schedule_rounded,
        label: '출발 타이밍',
        value: '1,456회',
        color: const Color(0xFF16A34A),
      ),
      _DashboardMetric(
        icon: Icons.map_rounded,
        label: '지도 클릭',
        value: '2,341회',
        color: const Color(0xFF22C55E),
      ),
      _DashboardMetric(
        icon: Icons.star_rounded,
        label: '즐겨찾기',
        value: '387건',
        color: const Color(0xFFFBBF24),
      ),
    ];

    final hourlyUsage = List.generate(24, (index) {
      final base = index >= 8 && index <= 20 ? 180 : 80;
      return _HourlyUsage(hour: index, value: base + (index % 6) * 12);
    });

    final featureUsage = [
      _FeatureUsage(name: '혼잡도 조회', value: 5234, color: const Color(0xFFB5E0F5)),
      _FeatureUsage(name: '예측 조회', value: 3892, color: const Color(0xFF7DD3FC)),
      _FeatureUsage(name: '출발 타이밍', value: 1456, color: const Color(0xFFFBBF24)),
      _FeatureUsage(name: '지도 보기', value: 2341, color: const Color(0xFF6FA05C)),
      _FeatureUsage(name: '즐겨찾기', value: 387, color: const Color(0xFFFDE68A)),
    ];

    final funnel = [
      _FunnelStep(step: '로그인', count: 2847, rate: 100),
      _FunnelStep(step: '혼잡도 확인', count: 2534, rate: 89),
      _FunnelStep(step: '예측 확인', count: 1892, rate: 66),
      _FunnelStep(step: '출발 타이밍', count: 1456, rate: 51),
      _FunnelStep(step: '지도/즐겨찾기', count: 987, rate: 35),
    ];

    final insights = [
      _Insight(message: '접속 사용자의 68%가 재방문 사용자입니다', type: InsightType.info, time: '10분 전'),
      _Insight(message: '혼잡도 확인 후 예측 조회 전환율이 평소보다 15% 낮습니다', type: InsightType.warning, time: '25분 전'),
      _Insight(message: '오후 2시~4시 사이 접속자 수가 평소 대비 28% 증가했습니다', type: InsightType.info, time: '1시간 전'),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      appBar: AppBar(
        title: const Text('난지 주차장 서비스 운영 대시보드'),
        backgroundColor: Colors.white,
        elevation: 1,
        foregroundColor: Colors.black87,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context, selectedPark?.name ?? '주차장 정보'),
              const SizedBox(height: 24),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: metricCards
                    .map((metric) => _buildMetricCard(context, metric))
                    .toList(),
              ),
              const SizedBox(height: 24),
              _buildParkingSummaryCard(
                context,
                selectedPark,
                totalSpaces,
                occupiedSpaces,
                availableSpaces,
                occupancyRate,
                statusLabel,
                statusColor,
              ),
              const SizedBox(height: 24),
              _buildInsightsCard(context, insights),
              const SizedBox(height: 24),
              LayoutBuilder(
                builder: (context, constraints) {
                  if (constraints.maxWidth >= 900) {
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: _buildHourlyUsageCard(context, hourlyUsage)),
                        const SizedBox(width: 16),
                        Expanded(child: _buildFeatureUsageCard(context, featureUsage)),
                      ],
                    );
                  }
                  return Column(
                    children: [
                      _buildHourlyUsageCard(context, hourlyUsage),
                      const SizedBox(height: 16),
                      _buildFeatureUsageCard(context, featureUsage),
                    ],
                  );
                },
              ),
              const SizedBox(height: 24),
              _buildFunnelCard(context, funnel),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, String title) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
        ),
        const SizedBox(height: 8),
        Text(
          '사용자 이용 분석 및 서비스 모니터링을 한눈에 확인하세요.',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Colors.grey[700],
                height: 1.5,
              ),
        ),
      ],
    );
  }

  Widget _buildMetricCard(BuildContext context, _DashboardMetric metric) {
    return Container(
      width: 260,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 18,
            offset: Offset(0, 6),
          ),
        ],
      ),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: metric.color.withAlpha((0.14 * 255).round()),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(metric.icon, color: metric.color, size: 20),
          ),
          const SizedBox(height: 14),
          Text(
            metric.label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[700],
                ),
          ),
          const SizedBox(height: 6),
          Text(
            metric.value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildParkingSummaryCard(
    BuildContext context,
    Park? selectedPark,
    int totalSpaces,
    int occupiedSpaces,
    int availableSpaces,
    double occupancyRate,
    String statusLabel,
    Color statusColor,
  ) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D000000),
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${selectedPark?.name ?? '선택된 주차장'} 현황',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
          ),
          const SizedBox(height: 18),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _buildStatusTile(context, '총 주차면', totalSpaces.toString(), '대'),
              _buildStatusTile(context, '남은 자리', availableSpaces.toString(), '대'),
              _buildStatusTile(context, '현재 주차', occupiedSpaces.toString(), '대'),
              _buildStatusTile(context, '사용률', '${(occupancyRate * 100).round()}%', ''),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '실시간 혼잡도',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[700],
                    ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: statusColor.withAlpha((0.16 * 255).round()),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text(
                  statusLabel,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: statusColor,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: LinearProgressIndicator(
              value: occupancyRate,
              minHeight: 12,
              backgroundColor: Colors.grey[200],
              valueColor: AlwaysStoppedAnimation(statusColor),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusTile(BuildContext context, String label, String value, String unit) {
    return Container(
      width: 170,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF6FF),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFDBEAFE)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey[600],
                ),
          ),
          const SizedBox(height: 8),
          Text(
            '$value$unit',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildInsightsCard(BuildContext context, List<_Insight> insights) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D000000),
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.insights_rounded, color: Colors.black87),
              const SizedBox(width: 10),
              Text(
                '운영 인사이트',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Column(
            children: insights.map((insight) => _buildInsightRow(context, insight)).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildInsightRow(BuildContext context, _Insight insight) {
    final color = insight.type == InsightType.warning
        ? const Color(0xFFFDE68A)
        : const Color(0xFFDBEAFE);
    final borderColor = insight.type == InsightType.warning
        ? const Color(0xFFF59E0B)
        : const Color(0xFF3B82F6);

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: borderColor, width: 1),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.trending_up_rounded,
            color: borderColor,
            size: 22,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  insight.message,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                ),
                const SizedBox(height: 6),
                Text(
                  insight.time,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[700],
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHourlyUsageCard(BuildContext context, List<_HourlyUsage> data) {
    final maxValue = data.map((e) => e.value).reduce((a, b) => a > b ? a : b);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D000000),
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '시간대별 사용자 접속 현황',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
          ),
          const SizedBox(height: 18),
          SizedBox(
            height: 250,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: data.map((usage) {
                  final barHeight = (usage.value / maxValue) * 180;
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Container(
                          width: 18,
                          height: 180,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF3F4F6),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          alignment: Alignment.bottomCenter,
                          child: Container(
                            width: 18,
                            height: barHeight,
                            decoration: BoxDecoration(
                              color: const Color(0xFF93C5FD),
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${usage.hour}시',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Colors.grey[700],
                              ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureUsageCard(BuildContext context, List<_FeatureUsage> features) {
    final total = features.fold<int>(0, (sum, item) => sum + item.value);
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D000000),
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '기능별 사용 비율',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
          ),
          const SizedBox(height: 18),
          Column(
            children: features.map((feature) {
              final ratio = total > 0 ? feature.value / total : 0.0;
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: feature.color,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        feature.name,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.grey[800],
                            ),
                      ),
                    ),
                    Text(
                      '${(ratio * 100).round()}%',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey[700],
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 14),
          Column(
            children: features.map((feature) {
              final ratio = total > 0 ? feature.value / total : 0.0;
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: LinearProgressIndicator(
                    value: ratio,
                    minHeight: 12,
                    backgroundColor: Colors.grey[200],
                    valueColor: AlwaysStoppedAnimation(feature.color),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildFunnelCard(BuildContext context, List<_FunnelStep> funnel) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D000000),
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '사용자 행동 퍼널',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
          ),
          const SizedBox(height: 18),
          Column(
            children: funnel.map((step) => _buildFunnelRow(context, step)).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildFunnelRow(BuildContext context, _FunnelStep step) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                step.step,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Colors.grey[800],
                    ),
              ),
              Text(
                '${step.count.toString().replaceAllMapped(RegExp(r"\B(?=(\d{3})+(?!\d))"), (match) => ',') }명',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[700],
                    ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: LinearProgressIndicator(
              value: step.rate / 100,
              minHeight: 16,
              backgroundColor: Colors.grey[200],
              valueColor: const AlwaysStoppedAnimation(Color(0xFF93C5FD)),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '${step.rate}% 전환율',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey[600],
                ),
          ),
        ],
      ),
    );
  }
}

class _DashboardMetric {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  _DashboardMetric({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });
}

class _HourlyUsage {
  final int hour;
  final int value;

  _HourlyUsage({required this.hour, required this.value});
}

class _FeatureUsage {
  final String name;
  final int value;
  final Color color;

  _FeatureUsage({required this.name, required this.value, required this.color});
}

class _FunnelStep {
  final String step;
  final int count;
  final int rate;

  _FunnelStep({required this.step, required this.count, required this.rate});
}

enum InsightType { info, warning }

class _Insight {
  final String message;
  final InsightType type;
  final String time;

  _Insight({required this.message, required this.type, required this.time});
}
