import 'package:flutter/material.dart';

class CongestionChart extends StatelessWidget {
  const CongestionChart({super.key});

  @override
  Widget build(BuildContext context) {
    final parkingList = [
      ParkingStatus(
        name: '주차장 A',
        occupied: 70,
        total: 100,
        available: 30,
        barColor: const Color(0xFFF44336),
        badgeBackground: const Color(0xFFFFF3E0),
        badgeTextColor: const Color(0xFFFF9800),
      ),
      ParkingStatus(
        name: '주차장 B',
        occupied: 50,
        total: 150,
        available: 100,
        barColor: const Color(0xFFFFEB3B),
        badgeBackground: const Color(0xFFE8F5E9),
        badgeTextColor: const Color(0xFF4CAF50),
      ),
    ];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F8F8),
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '주차장 상세 모니터링',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: Color(0xFF111111),
            ),
          ),
          const SizedBox(height: 24),
          ...parkingList.map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 18),
                child: _ParkingCard(item: item),
              )),
        ],
      ),
    );
  }
}

class _ParkingCard extends StatelessWidget {
  final ParkingStatus item;

  const _ParkingCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final percent = item.occupied / item.total;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: const Color(0xFFE7E7E7),
          width: 1.4,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.name,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF111111),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${item.occupied}/${item.total} 주차중',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF757575),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: item.badgeBackground,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text(
                  '${item.available}자리',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: item.badgeTextColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 26),
          const Text(
            '혼잡도',
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF8A8A8A),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: percent,
              minHeight: 10,
              backgroundColor: const Color(0xFFE3E3E3),
              valueColor: AlwaysStoppedAnimation<Color>(item.barColor),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            '${(percent * 100).round()}%',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: Color(0xFF222222),
            ),
          ),
        ],
      ),
    );
  }
}

class ParkingStatus {
  final String name;
  final int occupied;
  final int total;
  final int available;
  final Color barColor;
  final Color badgeBackground;
  final Color badgeTextColor;

  ParkingStatus({
    required this.name,
    required this.occupied,
    required this.total,
    required this.available,
    required this.barColor,
    required this.badgeBackground,
    required this.badgeTextColor,
  });
}