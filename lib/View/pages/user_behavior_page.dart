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
    final hasContent = vm.metrics.isNotEmpty ||
        vm.funnelSteps.isNotEmpty ||
        vm.sessionDurations.isNotEmpty ||
        vm.returnPatterns.isNotEmpty ||
        vm.weeklyActiveUsers.isNotEmpty ||
        vm.featureFrequency.isNotEmpty ||
        vm.notificationStats.isNotEmpty ||
        vm.dropOff.isNotEmpty;

    return Container(
      color: const Color(0xFFF3F4F6),
      child: Column(
        children: [
          Expanded(
            child: vm.isLoading
                ? const Center(child: CircularProgressIndicator())
                : vm.errorMessage != null
                    ? _UserBehaviorErrorView(
                        message: vm.errorMessage!,
                        onRetry: vm.load,
                      )
                    : !hasContent
                        ? const _UserBehaviorEmptyView()
                        : LayoutBuilder(
                            builder: (context, constraints) {
                              final contentWidth =
                                  math.min(constraints.maxWidth, 1440.0);
                              final isCompact = contentWidth < 980;
                              final pairWidth = isCompact
                                  ? contentWidth
                                  : (contentWidth - 16) / 2;
                              final totalSessions =
                                  vm.sessionDurations.fold<int>(
                                0,
                                (sum, item) => sum + item.count,
                              );
                              final returningUsers = vm.returnPatterns
                                  .skip(1)
                                  .fold<int>(
                                      0, (sum, item) => sum + item.count);
                              final returnRate = vm.totalActiveUsersText == '0'
                                  ? 0.0
                                  : (returningUsers /
                                          math.max(
                                            1,
                                            int.tryParse(vm.totalActiveUsersText
                                                    .replaceAll(',', '')) ??
                                                0,
                                          )) *
                                      100;
                              final notificationTotal =
                                  vm.notificationStats.fold<int>(
                                0,
                                (sum, item) => sum + item.count,
                              );
                              final totalUsers = math.max(
                                1,
                                int.tryParse(
                                      vm.totalActiveUsersText
                                          .replaceAll(',', ''),
                                    ) ??
                                    0,
                              );
                              final notificationRate =
                                  ((notificationTotal / (totalUsers * 3)) *
                                          100)
                                      .clamp(0, 100);

                              return SingleChildScrollView(
                                padding: const EdgeInsets.all(24),
                                child: Center(
                                  child: ConstrainedBox(
                                    constraints:
                                        BoxConstraints(maxWidth: contentWidth),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Wrap(
                                          spacing: 16,
                                          runSpacing: 16,
                                          children: [
                                            _TopStatCard(
                                              icon: Icons.people_alt_rounded,
                                              iconColor:
                                                  const Color(0xFF2563EB),
                                              label: '총 활성 사용자',
                                              value: vm.totalActiveUsersText,
                                              caption: '오늘 전체',
                                            ),
                                            _TopStatCard(
                                              icon: Icons.refresh_rounded,
                                              iconColor:
                                                  const Color(0xFF16A34A),
                                              label: '재방문율',
                                              value:
                                                  '${returnRate.toStringAsFixed(1)}%',
                                              caption:
                                                  '${_formatCompact(returningUsers)}명 재방문',
                                            ),
                                            _TopStatCard(
                                              icon: Icons.schedule_rounded,
                                              iconColor:
                                                  const Color(0xFF7C3AED),
                                              label: '평균 세션 시간',
                                              value: _findMetric(
                                                vm.metrics,
                                                '평균 체류 시간',
                                              ),
                                              caption: '세션당 평균',
                                            ),
                                            _TopStatCard(
                                              icon:
                                                  Icons.notifications_active_rounded,
                                              iconColor:
                                                  const Color(0xFFEA580C),
                                              label: '알림 설정율',
                                              value:
                                                  '${notificationRate.round()}%',
                                              caption: '전체 알림 대비',
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 24),
                                        WideCard(
                                          title: '사용자 행동 퍼널',
                                          child: Column(
                                            children: [
                                              ...vm.funnelSteps
                                                  .asMap()
                                                  .entries
                                                  .map(
                                                    (entry) => Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                        bottom: 16,
                                                      ),
                                                      child: _FunnelRow(
                                                        item: entry.value,
                                                        previousRate:
                                                            entry.key == 0
                                                                ? null
                                                                : vm
                                                                    .funnelSteps[
                                                                        entry.key -
                                                                            1]
                                                                    .rate,
                                                      ),
                                                    ),
                                                  ),
                                              _InsightBox(
                                                text: vm.activeUserInsight,
                                                background:
                                                    const Color(0xFFEFF6FF),
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
                                                title: '세션 시간 분포',
                                                child: Column(
                                                  children: [
                                                    _DistributionSummary(
                                                      items:
                                                          vm.sessionDurations,
                                                      total: totalSessions,
                                                      valueSuffix: '명',
                                                    ),
                                                    const SizedBox(height: 16),
                                                    _InsightBox(
                                                      text: vm.sessionInsight,
                                                      background:
                                                          const Color(
                                                        0xFFF5F3FF,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                            SizedBox(
                                              width: pairWidth,
                                              child: WideCard(
                                                title: '재방문 패턴',
                                                child: Column(
                                                  children: [
                                                    ...vm.returnPatterns.map(
                                                      (item) => Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .only(
                                                          bottom: 16,
                                                        ),
                                                        child:
                                                            _ReturnPatternRow(
                                                          item: item,
                                                        ),
                                                      ),
                                                    ),
                                                    _InsightBox(
                                                      text: vm.returnInsight,
                                                      background:
                                                          const Color(
                                                        0xFFF0FDF4,
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
                                          title: '일주일간 활성 사용자 추이',
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              SizedBox(
                                                height: 280,
                                                child: _WeeklyUserBars(
                                                  items: vm.weeklyActiveUsers,
                                                ),
                                              ),
                                              const SizedBox(height: 16),
                                              const Wrap(
                                                spacing: 16,
                                                runSpacing: 8,
                                                children: [
                                                  _LegendChip(
                                                    color: Color(0xFFB5E0F5),
                                                    label: '신규 사용자',
                                                  ),
                                                  _LegendChip(
                                                    color: Color(0xFF6FA05C),
                                                    label: '재방문 사용자',
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 16),
                                              Wrap(
                                                spacing: 16,
                                                runSpacing: 16,
                                                children: _weeklySummaryChips(
                                                  vm.weeklyActiveUsers,
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
                                                title: '기능별 사용 빈도 (세션당 평균)',
                                                child: Column(
                                                  children:
                                                      vm.featureFrequency
                                                          .map(
                                                            (item) => Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .only(
                                                                bottom: 16,
                                                              ),
                                                              child: _ValueBar(
                                                                label:
                                                                    item.label,
                                                                value:
                                                                    (item.count /
                                                                            10)
                                                                        .toStringAsFixed(
                                                                  1,
                                                                ),
                                                                ratio: _ratioFor(
                                                                  vm.featureFrequency,
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
                                                title: '알림 설정 현황',
                                                child: Column(
                                                  children: [
                                                    ...vm.notificationStats.map(
                                                      (item) => Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .only(
                                                          bottom: 14,
                                                        ),
                                                        child:
                                                            _NotificationTile(
                                                          item: item,
                                                        ),
                                                      ),
                                                    ),
                                                    const SizedBox(height: 8),
                                                    _FooterCount(
                                                      totalUsersText:
                                                          vm.totalActiveUsersText,
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
                                            children: [
                                              if (isCompact)
                                                ...vm.dropOff.map(
                                                  (item) => _DropOffCard(
                                                    item: item,
                                                  ),
                                                )
                                              else
                                                Column(
                                                  children: [
                                                    const Padding(
                                                      padding:
                                                          EdgeInsets.only(
                                                        bottom: 12,
                                                      ),
                                                      child: Row(
                                                        children: [
                                                          Expanded(
                                                            child: Text(
                                                              '이탈 지점',
                                                              style: TextStyle(
                                                                fontSize: 13,
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
                                                            width: 110,
                                                            child: Text(
                                                              '이탈자 수',
                                                              textAlign:
                                                                  TextAlign
                                                                      .right,
                                                              style: TextStyle(
                                                                fontSize: 13,
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
                                                            width: 110,
                                                            child: Text(
                                                              '누적 이탈률',
                                                              textAlign:
                                                                  TextAlign
                                                                      .right,
                                                              style: TextStyle(
                                                                fontSize: 13,
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
                                                            width: 220,
                                                            child: Text(
                                                              '진행률',
                                                              textAlign:
                                                                  TextAlign
                                                                      .right,
                                                              style: TextStyle(
                                                                fontSize: 13,
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
                                                    ...vm.dropOff.map(
                                                      (item) => _DropOffRow(
                                                        item: item,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              const SizedBox(height: 12),
                                              const _InsightBox(
                                                text:
                                                    '지도와 즐겨찾기 단계로 이어지는 안내를 강화하면 전체 전환율 개선에 도움이 됩니다.',
                                                background:
                                                    Color(0xFFFFFBEB),
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
  });

  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;
  final String caption;

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
            style: const TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.w800,
              color: Color(0xFF111827),
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

class _FunnelRow extends StatelessWidget {
  const _FunnelRow({required this.item, this.previousRate});

  final FunnelStepData item;
  final int? previousRate;

  @override
  Widget build(BuildContext context) {
    final drop = previousRate == null ? null : previousRate! - item.rate;

    return Column(
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
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
            const SizedBox(width: 8),
            Text(
              '(${item.rate}%)',
              style: const TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
            ),
            if (drop != null) ...[
              const SizedBox(width: 10),
              Text(
                '-$drop%p 이탈',
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
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: LinearProgressIndicator(
            value: item.rate / 100,
            minHeight: 22,
            backgroundColor: const Color(0xFFE5E7EB),
            valueColor: const AlwaysStoppedAnimation<Color>(
              Color(0xFF7DD3FC),
            ),
          ),
        ),
      ],
    );
  }
}

class _DistributionSummary extends StatelessWidget {
  const _DistributionSummary({
    required this.items,
    required this.total,
    required this.valueSuffix,
  });

  final List<DistributionItem> items;
  final int total;
  final String valueSuffix;

  @override
  Widget build(BuildContext context) {
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
                      value: total == 0 ? 0 : items.first.count / total,
                      strokeWidth: 22,
                      backgroundColor: Colors.transparent,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        items.isEmpty
                            ? const Color(0xFFB5E0F5)
                            : items.first.color,
                      ),
                    ),
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _formatCompact(total),
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF111827),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '전체 세션$valueSuffix',
                      style: const TextStyle(
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
        const SizedBox(height: 20),
        ...items.map(
          (item) => Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: _ValueBar(
              label: item.label,
              value: '${_formatCompact(item.count)}$valueSuffix',
              ratio: total == 0 ? 0 : item.count / total,
              color: item.color,
            ),
          ),
        ),
      ],
    );
  }
}

class _ReturnPatternRow extends StatelessWidget {
  const _ReturnPatternRow({required this.item});

  final DistributionItem item;

  @override
  Widget build(BuildContext context) {
    return _ValueBar(
      label: item.label,
      value: '${_formatCompact(item.count)}명 (${item.percentage ?? 0}%)',
      ratio: ((item.percentage ?? 0) / 100).clamp(0.0, 1.0),
      color: item.color,
    );
  }
}

class _WeeklyUserBars extends StatelessWidget {
  const _WeeklyUserBars({required this.items});

  final List<WeeklyTrendPoint> items;

  @override
  Widget build(BuildContext context) {
    final maxValue = items.fold<int>(
      0,
      (max, item) => math.max(max, item.primary + item.secondary),
    );

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: items
          .map(
            (item) => Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      _formatCompact(item.primary + item.secondary),
                      style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFF6B7280),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      child: Align(
                        alignment: Alignment.bottomCenter,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Expanded(
                              child: Container(
                                height: maxValue == 0
                                    ? 0
                                    : (item.primary / maxValue) * 200,
                                decoration: const BoxDecoration(
                                  color: Color(0xFFB5E0F5),
                                  borderRadius: BorderRadius.vertical(
                                    top: Radius.circular(8),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Container(
                                height: maxValue == 0
                                    ? 0
                                    : (item.secondary / maxValue) * 200,
                                decoration: const BoxDecoration(
                                  color: Color(0xFF6FA05C),
                                  borderRadius: BorderRadius.vertical(
                                    top: Radius.circular(8),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      item.label,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF6B7280),
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
}

class _LegendChip extends StatelessWidget {
  const _LegendChip({required this.color, required this.label});

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

class _SummaryChip extends StatelessWidget {
  const _SummaryChip({
    required this.label,
    required this.value,
    required this.background,
  });

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
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: Color(0xFF111827),
            ),
          ),
        ],
      ),
    );
  }
}

class _ValueBar extends StatelessWidget {
  const _ValueBar({
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
            Text(value, style: const TextStyle(fontWeight: FontWeight.w700)),
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
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: item.background,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Icon(item.icon, color: item.color, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              item.label,
              style: const TextStyle(fontWeight: FontWeight.w700),
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
                  color: item.color,
                ),
              ),
              Text(
                '${item.percentage}% 설정',
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

class _FooterCount extends StatelessWidget {
  const _FooterCount({required this.totalUsersText});

  final String totalUsersText;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Text(
          '총 사용자',
          style: TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
        ),
        const Spacer(),
        Text(
          '$totalUsersText명',
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
        ),
      ],
    );
  }
}

class _DropOffRow extends StatelessWidget {
  const _DropOffRow({required this.item});

  final DropOffItem item;

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
              '${item.rate}%',
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
                valueColor: AlwaysStoppedAnimation<Color>(_dropColor(item.rate)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DropOffCard extends StatelessWidget {
  const _DropOffCard({required this.item});

  final DropOffItem item;

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
          Text(
            item.label,
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Text(
                '${_formatCompact(item.count)}명',
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              const SizedBox(width: 10),
              Text(
                '${item.rate}%',
                style: const TextStyle(color: Color(0xFF6B7280)),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: item.rate / 100,
              minHeight: 12,
              backgroundColor: const Color(0xFFE5E7EB),
              valueColor: AlwaysStoppedAnimation<Color>(_dropColor(item.rate)),
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
            const Icon(
              Icons.error_outline_rounded,
              color: Color(0xFFD14343),
              size: 48,
            ),
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
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
              ),
              child: const Text('다시 시도'),
            ),
          ],
        ),
      ),
    );
  }
}

class _UserBehaviorEmptyView extends StatelessWidget {
  const _UserBehaviorEmptyView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 520,
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: const [
            BoxShadow(
              color: Color(0x14000000),
              blurRadius: 18,
              offset: Offset(0, 8),
            ),
          ],
        ),
        child: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.analytics_outlined, size: 44, color: Color(0xFF6B7280)),
            SizedBox(height: 16),
            Text(
              '표시할 사용자 행동 데이터가 없습니다',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 10),
            Text(
              '현재 화면에 표시할 항목이 비어 있습니다. 백엔드 응답과 집계 데이터를 다시 확인해 주세요.',
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF6B7280),
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

List<Widget> _weeklySummaryChips(List<WeeklyTrendPoint> items) {
  final weekday = items.take(math.min(5, items.length)).toList();
  final weekend = items.skip(math.min(5, items.length)).toList();

  int total(List<WeeklyTrendPoint> source) =>
      source.fold<int>(0, (sum, item) => sum + item.primary + item.secondary);

  final weekdayAverage = weekday.isEmpty ? 0 : total(weekday) ~/ weekday.length;
  final weekendAverage = weekend.isEmpty ? 0 : total(weekend) ~/ weekend.length;
  final growth = weekdayAverage == 0
      ? 0
      : (((weekendAverage - weekdayAverage) / weekdayAverage) * 100).round();

  return [
    _SummaryChip(
      label: '주중 평균',
      value: '${_formatCompact(weekdayAverage)}명/일',
      background: const Color(0xFFEFF6FF),
    ),
    _SummaryChip(
      label: '주말 평균',
      value: '${_formatCompact(weekendAverage)}명/일',
      background: const Color(0xFFF0FDF4),
    ),
    _SummaryChip(
      label: '주말 증가율',
      value: '${growth >= 0 ? '+' : ''}$growth%',
      background: const Color(0xFFF5F3FF),
    ),
  ];
}

String _findMetric(List<AdminMetric> metrics, String label) {
  for (final metric in metrics) {
    if (metric.label == label) return metric.value;
  }
  return '-';
}

double _ratioFor(List<DistributionItem> items, int count) {
  final maxCount = items.fold<int>(0, (max, item) => math.max(max, item.count));
  if (maxCount == 0) return 0;
  return count / maxCount;
}

Color _dropColor(int rate) {
  if (rate < 30) return const Color(0xFF16A34A);
  if (rate < 50) return const Color(0xFFD97706);
  return const Color(0xFFDC2626);
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
