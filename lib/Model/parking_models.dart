class Park {
  final String id;
  final String name;
  final List<ParkingLot> parkingLots;

  Park({required this.id, required this.name, required this.parkingLots});
}

class ParkingLot {
  final String id;
  final String name;
  final int totalSpaces;
  final int occupiedSpaces;
  final double congestionLevel; // 0.0 to 1.0

  ParkingLot({
    required this.id,
    required this.name,
    required this.totalSpaces,
    required this.occupiedSpaces,
    required this.congestionLevel,
  });

  int get availableSpaces => totalSpaces - occupiedSpaces;
}

class CongestionData {
  final DateTime dateTime;
  final double predictedCongestion;

  CongestionData({required this.dateTime, required this.predictedCongestion});
}