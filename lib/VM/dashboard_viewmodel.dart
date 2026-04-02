import 'package:flutter/material.dart';
import '../Model/parking_models.dart';

class DashboardViewModel extends ChangeNotifier {
  List<Park> _parks = [];
  Park? _selectedPark;
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();
  List<CongestionData> _congestionData = [];

  List<Park> get parks => _parks;
  Park? get selectedPark => _selectedPark;
  DateTime get selectedDate => _selectedDate;
  TimeOfDay get selectedTime => _selectedTime;
  List<CongestionData> get congestionData => _congestionData;

  DashboardViewModel() {
    _loadMockData();
  }

  void _loadMockData() {
    // Mock data
    _parks = [
      Park(
        id: '1',
        name: '난지공원',
        parkingLots: [
          ParkingLot(id: '1', name: '주차장 A', totalSpaces: 100, occupiedSpaces: 70, congestionLevel: 0.7),
          ParkingLot(id: '2', name: '주차장 B', totalSpaces: 150, occupiedSpaces: 50, congestionLevel: 0.33),
        ],
      ),
      Park(
        id: '2',
        name: '뚝섬공원',
        parkingLots: [
          ParkingLot(id: '3', name: '주차장 C', totalSpaces: 200, occupiedSpaces: 180, congestionLevel: 0.9),
        ],
      ),
    ];
    _selectedPark = _parks.first;
    _generateCongestionData();
    notifyListeners();
  }

  void selectPark(Park park) {
    _selectedPark = park;
    _generateCongestionData();
    notifyListeners();
  }

  void selectDate(DateTime date) {
    _selectedDate = date;
    _generateCongestionData();
    notifyListeners();
  }

  void selectTime(TimeOfDay time) {
    _selectedTime = time;
    notifyListeners();
  }

  void _generateCongestionData() {
    // Mock prediction data
    _congestionData = List.generate(24, (index) {
      final hour = index;
      final congestion = (hour >= 8 && hour <= 18) ? 0.5 + (hour - 8) * 0.05 : 0.2;
      return CongestionData(
        dateTime: DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day, hour),
        predictedCongestion: congestion.clamp(0.0, 1.0),
      );
    });
  }

  Color getCongestionColor(double level) {
    if (level < 0.3) return Colors.green;
    if (level < 0.7) return Colors.yellow;
    return Colors.red;
  }
}