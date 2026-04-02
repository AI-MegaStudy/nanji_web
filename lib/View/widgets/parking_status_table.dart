import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../VM/dashboard_viewmodel.dart';

class ParkingStatusTable extends StatelessWidget {
  const ParkingStatusTable({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<DashboardViewModel>(context);
    final parkingLots = viewModel.selectedPark?.parkingLots ?? [];

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '전체 주차장 현황',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columns: const [
                  DataColumn(label: Text('주차장명')),
                  DataColumn(label: Text('총 공간')),
                  DataColumn(label: Text('점유 공간')),
                  DataColumn(label: Text('가용 공간')),
                  DataColumn(label: Text('혼잡도')),
                ],
                rows: parkingLots.map((lot) {
                  return DataRow(cells: [
                    DataCell(Text(lot.name)),
                    DataCell(Text(lot.totalSpaces.toString())),
                    DataCell(Text(lot.occupiedSpaces.toString())),
                    DataCell(Text(lot.availableSpaces.toString())),
                    DataCell(
                      Container(
                        width: 20,
                        height: 20,
                        color: viewModel.getCongestionColor(lot.congestionLevel),
                      ),
                    ),
                  ]);
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}