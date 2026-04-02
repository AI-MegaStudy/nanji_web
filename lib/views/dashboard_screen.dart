import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../viewmodels/dashboard_viewmodel.dart';
import '../models/parking_models.dart';
import 'widgets/parking_status_table.dart';
import 'widgets/congestion_chart.dart';
import 'widgets/congestion_map.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<DashboardViewModel>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('한강공원 주차장 모니터링 대시보드'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth > 800) {
            // Desktop layout
            return Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Column(
                    children: [
                      _buildFilters(context, viewModel),
                      Expanded(child: CongestionMap()),
                    ],
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Column(
                    children: [
                      Expanded(child: ParkingStatusTable()),
                      Expanded(child: CongestionChart()),
                    ],
                  ),
                ),
              ],
            );
          } else {
            // Mobile layout
            return SingleChildScrollView(
              child: Column(
                children: [
                  _buildFilters(context, viewModel),
                  CongestionMap(),
                  ParkingStatusTable(),
                  CongestionChart(),
                ],
              ),
            );
          }
        },
      ),
    );
  }

  Widget _buildFilters(BuildContext context, DashboardViewModel viewModel) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          Expanded(
            child: DropdownButton<Park>(
              value: viewModel.selectedPark,
              onChanged: (Park? newValue) {
                if (newValue != null) {
                  viewModel.selectPark(newValue);
                }
              },
              items: viewModel.parks.map<DropdownMenuItem<Park>>((Park park) {
                return DropdownMenuItem<Park>(
                  value: park,
                  child: Text(park.name),
                );
              }).toList(),
              hint: const Text('공원 선택'),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: ElevatedButton(
              onPressed: () async {
                final DateTime? picked = await showDatePicker(
                  context: context,
                  initialDate: viewModel.selectedDate,
                  firstDate: DateTime(2020),
                  lastDate: DateTime(2030),
                );
                if (picked != null) {
                  viewModel.selectDate(picked);
                }
              },
              child: Text('날짜: ${viewModel.selectedDate.toLocal().toString().split(' ')[0]}'),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: ElevatedButton(
              onPressed: () async {
                final TimeOfDay? picked = await showTimePicker(
                  context: context,
                  initialTime: viewModel.selectedTime,
                );
                if (picked != null) {
                  viewModel.selectTime(picked);
                }
              },
              child: Text('시간: ${viewModel.selectedTime.format(context)}'),
            ),
          ),
        ],
      ),
    );
  }
}