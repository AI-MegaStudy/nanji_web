import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../VM/dashboard_viewmodel.dart';
import '../Model/parking_models.dart';
import 'widgets/parking_status_table.dart';
import 'widgets/congestion_chart.dart';
import 'widgets/congestion_map.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  static const Color bgTop = Color(0xFFE9E2FF);
  static const Color bgMid = Color(0xFFF6F3FF);
  static const Color bgBottom = Color(0xFFEAEFFF);

  static const Color primaryText = Color(0xFF1F2A44);
  static const Color secondaryText = Color(0xFF6B7280);

  static const Color accentPurple = Color(0xFFB9A7F8);
  static const Color accentBlue = Color(0xFF5B8DEF);
  static const Color accentRed = Color(0xFFFF6B6B);
  static const Color accentYellow = Color(0xFFF4D35E);

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<DashboardViewModel>(context);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [bgTop, bgMid, bgBottom],
          ),
        ),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final double width = constraints.maxWidth;
              final bool isDesktop = width >= 1200;
              final bool isTablet = width >= 760 && width < 1200;
              final double horizontalPadding = isDesktop ? 32 : 16;
              final double maxContentWidth = isDesktop ? 1400 : 1200;

              return Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: maxContentWidth),
                  child: SingleChildScrollView(
                    padding: EdgeInsets.symmetric(
                      horizontal: horizontalPadding,
                      vertical: 20,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildHeroHeader(context, viewModel, isDesktop, isTablet),
                        const SizedBox(height: 24),
                        _buildDashboardBody(isDesktop: isDesktop, isTablet: isTablet),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildHeroHeader(
    BuildContext context,
    DashboardViewModel viewModel,
    bool isDesktop,
    bool isTablet,
  ) {
    return _glassContainer(
      padding: EdgeInsets.all(isDesktop ? 28 : 20),
      borderRadius: 28,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  '난지 한강공원 주차 모니터링 대시보드',
                  style: TextStyle(
                    fontSize: isDesktop ? 30 : 22,
                    fontWeight: FontWeight.w800,
                    color: primaryText,
                    letterSpacing: -0.5,
                  ),
                ),
              ),
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.55),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white.withOpacity(0.65)),
                ),
                child: const Icon(
                  Icons.menu_rounded,
                  color: primaryText,
                  size: 28,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            '실시간 현황과 시간대별 빈자리 예측을 한 화면에서 확인하세요.',
            style: TextStyle(
              fontSize: isDesktop ? 15 : 13,
              color: secondaryText,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 22),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _infoChip(
                icon: Icons.wb_sunny_rounded,
                label: '날씨',
                value: '20°C',
                iconColor: const Color(0xFFF4B400),
              ),
              _infoChip(
                icon: Icons.calendar_today_rounded,
                label: '날짜',
                value: _formatDate(viewModel.selectedDate),
                iconColor: accentBlue,
                onTap: () => _pickDate(context, viewModel),
              ),
              _infoChip(
                icon: Icons.access_time_rounded,
                label: '시간',
                value: viewModel.selectedTime.format(context),
                iconColor: accentPurple,
                onTap: () => _pickTime(context, viewModel),
              ),
              _parkSelectorChip(viewModel),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDashboardBody({
    required bool isDesktop,
    required bool isTablet,
  }) {
    if (isDesktop) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 6,
            child: Column(
              children: [
                _sectionCard(
                  title: '실시간 주차장 현황',
                  subtitle: '주차장별 현재 상태를 확인할 수 있어요.',
                  height: 280,
                  child: _buildRealtimeStatusContent(),
                ),
                const SizedBox(height: 24),
                _sectionCard(
                  title: '시간대별 주차장 빈자리 예측',
                  subtitle: '예상 빈자리 추이를 그래프로 확인할 수 있어요.',
                  height: 520,
                  child: const CongestionChart(),
                ),
              ],
            ),
          ),
          const SizedBox(width: 24),
          Expanded(
            flex: 4,
            child: _sectionCard(
              title: '주차장 지도 현황',
              subtitle: '현재 위치와 구역 상태를 한눈에 볼 수 있어요.',
              height: 824,
              child: const CongestionMap(),
            ),
          ),
        ],
      );
    }

    if (isTablet) {
      return Column(
        children: [
          _sectionCard(
            title: '실시간 주차장 현황',
            subtitle: '주차장별 현재 상태를 확인할 수 있어요.',
            height: 280,
            child: _buildRealtimeStatusContent(),
          ),
          const SizedBox(height: 20),
          _sectionCard(
            title: '주차장 지도 현황',
            subtitle: '현재 위치와 구역 상태를 한눈에 볼 수 있어요.',
            height: 420,
            child: const CongestionMap(),
          ),
          const SizedBox(height: 20),
          _sectionCard(
            title: '시간대별 주차장 빈자리 예측',
            subtitle: '예상 빈자리 추이를 그래프로 확인할 수 있어요.',
            height: 460,
            child: const CongestionChart(),
          ),
        ],
      );
    }

    return Column(
      children: [
        _sectionCard(
          title: '실시간 주차장 현황',
          subtitle: '주차장별 현재 상태를 확인할 수 있어요.',
          height: 330,
          child: _buildRealtimeStatusContent(isMobile: true),
        ),
        const SizedBox(height: 16),
        _sectionCard(
          title: '주차장 지도 현황',
          subtitle: '현재 위치와 구역 상태를 한눈에 볼 수 있어요.',
          height: 340,
          child: const CongestionMap(),
        ),
        const SizedBox(height: 16),
        _sectionCard(
          title: '시간대별 주차장 빈자리 예측',
          subtitle: '예상 빈자리 추이를 그래프로 확인할 수 있어요.',
          height: 380,
          child: const CongestionChart(),
        ),
      ],
    );
  }

  Widget _buildRealtimeStatusContent({bool isMobile = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (isMobile)
          Column(
            children: [
              _statusSummaryCard(
                title: '주차장 A',
                value: '70%',
                description: '혼잡',
                color: accentRed,
                icon: Icons.local_parking_rounded,
              ),
              const SizedBox(height: 12),
              _statusSummaryCard(
                title: '주차장 B',
                value: '33%',
                description: '여유',
                color: accentYellow,
                icon: Icons.local_parking_rounded,
                darkText: true,
              ),
              const SizedBox(height: 12),
              _statusSummaryCard(
                title: '총 잔여',
                value: '244',
                description: '예상 가능',
                color: const Color(0xFFDDE6FF),
                icon: Icons.ev_station_rounded,
                darkText: true,
              ),
            ],
          )
        else
          Row(
            children: [
              Expanded(
                child: _statusSummaryCard(
                  title: '주차장 A',
                  value: '70%',
                  description: '혼잡',
                  color: accentRed,
                  icon: Icons.local_parking_rounded,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: _statusSummaryCard(
                  title: '총 잔여',
                  value: '244',
                  description: '예상 가능',
                  color: const Color(0xFFDDE6FF),
                  icon: Icons.ev_station_rounded,
                  darkText: true,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: _statusSummaryCard(
                  title: '주차장 B',
                  value: '33%',
                  description: '여유',
                  color: accentYellow,
                  icon: Icons.local_parking_rounded,
                  darkText: true,
                ),
              ),
            ],
          ),
        const SizedBox(height: 18),
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.55),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withOpacity(0.7)),
            ),
            padding: const EdgeInsets.all(14),
            child: const ParkingStatusTable(),
          ),
        ),
      ],
    );
  }

  Widget _sectionCard({
    required String title,
    required String subtitle,
    required Widget child,
    required double height,
  }) {
    return _glassContainer(
      height: height,
      padding: const EdgeInsets.all(20),
      borderRadius: 28,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: primaryText,
                  ),
                ),
              ),
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: accentPurple.withOpacity(0.18),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: const Text(
                  'i',
                  style: TextStyle(
                    color: secondaryText,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            style: const TextStyle(
              fontSize: 13,
              color: secondaryText,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 16),
          Expanded(child: child),
        ],
      ),
    );
  }

  Widget _statusSummaryCard({
    required String title,
    required String value,
    required String description,
    required Color color,
    required IconData icon,
    bool darkText = false,
  }) {
    final Color textColor = darkText ? primaryText : Colors.white;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color,
            color.withOpacity(0.88),
          ],
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.20),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.20),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: textColor, size: 30),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    color: textColor,
                    height: 1,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: textColor.withOpacity(0.95),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoChip({
    required IconData icon,
    required String label,
    required String value,
    required Color iconColor,
    VoidCallback? onTap,
  }) {
    final child = Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.58),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withOpacity(0.75)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 20, color: iconColor),
          const SizedBox(width: 10),
          Text(
            '$label  ',
            style: const TextStyle(
              color: secondaryText,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: primaryText,
              fontWeight: FontWeight.w800,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );

    if (onTap == null) return child;

    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: child,
    );
  }

  Widget _parkSelectorChip(DashboardViewModel viewModel) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.60),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withOpacity(0.75)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<Park>(
          value: viewModel.selectedPark,
          icon: const Icon(Icons.keyboard_arrow_down_rounded, color: primaryText),
          borderRadius: BorderRadius.circular(16),
          dropdownColor: Colors.white,
          style: const TextStyle(
            color: primaryText,
            fontWeight: FontWeight.w700,
            fontSize: 16,
          ),
          onChanged: (Park? newValue) {
            if (newValue != null) {
              viewModel.selectPark(newValue);
            }
          },
          items: viewModel.parks.map((park) {
            return DropdownMenuItem<Park>(
              value: park,
              child: Text(park.name),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _glassContainer({
    required Widget child,
    EdgeInsetsGeometry? padding,
    double? height,
    double borderRadius = 24,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
        child: Container(
          height: height,
          padding: padding,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.42),
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(
              color: Colors.white.withOpacity(0.70),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 24,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }

  Future<void> _pickDate(BuildContext context, DashboardViewModel viewModel) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: viewModel.selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: accentBlue,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      viewModel.selectDate(picked);
    }
  }

  Future<void> _pickTime(BuildContext context, DashboardViewModel viewModel) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: viewModel.selectedTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            timePickerTheme: const TimePickerThemeData(
              hourMinuteTextColor: primaryText,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      viewModel.selectTime(picked);
    }
  }

  String _formatDate(DateTime date) {
    final String yy = (date.year % 100).toString().padLeft(2, '0');
    final String mm = date.month.toString().padLeft(2, '0');
    final String dd = date.day.toString().padLeft(2, '0');
    return '$yy-$mm-$dd';
  }
}