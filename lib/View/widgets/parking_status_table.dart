import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/dashboard_viewmodel.dart';

class ParkingStatusTable extends StatelessWidget {
  const ParkingStatusTable({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<DashboardViewModel>(context);
    final parkingLots = viewModel.selectedPark?.parkingLots ?? [];

    if (parkingLots.isEmpty) {
      return Center(
        child: Text(
          '주차장 정보가 없습니다',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Colors.grey[500],
          ),
        ),
      );
    }

    return ListView.builder(
      itemCount: parkingLots.length,
      itemBuilder: (context, index) {
        final lot = parkingLots[index];
        final occupancyRate = lot.totalSpaces > 0
            ? lot.occupiedSpaces / lot.totalSpaces
            : 0.0;
        final availableSpaces = lot.availableSpaces;

        return Padding(
          padding: EdgeInsets.only(bottom: index < parkingLots.length - 1 ? 12 : 0),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              border: Border.all(color: Colors.grey[200]!, width: 1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            lot.name,
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${lot.occupiedSpaces}/${lot.totalSpaces} 주차중',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: _getAvailabilityColor(availableSpaces, lot.totalSpaces)
                            .withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${availableSpaces}자리',
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: _getAvailabilityColor(availableSpaces, lot.totalSpaces),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '혼잡도',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 6),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: occupancyRate,
                        minHeight: 6,
                        backgroundColor: Colors.grey[300],
                        valueColor: AlwaysStoppedAnimation(
                          viewModel.getCongestionColor(lot.congestionLevel),
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${(lot.congestionLevel * 100).toInt()}%',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Color _getAvailabilityColor(int available, int total) {
    final rate = total > 0 ? available / total : 0.0;
    if (rate > 0.5) return Colors.green;
    if (rate > 0.2) return Colors.orange;
    return Colors.red;
  }
}
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            lot.name,
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${lot.occupiedSpaces}/${lot.totalSpaces} 주차중',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: _getAvailabilityColor(availableSpaces, lot.totalSpaces)
                            .withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${availableSpaces}자리',
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: _getAvailabilityColor(availableSpaces, lot.totalSpaces),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '혼잡도',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 6),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: occupancyRate,
                        minHeight: 6,
                        backgroundColor: Colors.grey[300],
                        valueColor: AlwaysStoppedAnimation(
                          viewModel.getCongestionColor(lot.congestionLevel),
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${(lot.congestionLevel * 100).toInt()}%',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Color _getAvailabilityColor(int available, int total) {
    final rate = total > 0 ? available / total : 0.0;
    if (rate > 0.5) return Colors.green;
    if (rate > 0.2) return Colors.orange;
    return Colors.red;
  }
}