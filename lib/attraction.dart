class Attraction {
  final int? id;
  final int sequenceNumber;
  final String name;
  final String memo;
  final String date;

  final double latitude;
  final double longitude;

  final String arrivalTime;
  final String departureTime;

  final String arrivalStation;
  final String departureStation;

  double? distance;

  bool isVisited;
  bool isNavigating;

  Attraction({
    this.id,
    required this.sequenceNumber,
    required this.name,
    required this.memo,
    required this.date,
    required this.longitude,
    required this.latitude,
    required this.arrivalTime,
    required this.departureTime,
    required this.arrivalStation,
    required this.departureStation,
    required this.isVisited,
    required this.isNavigating,
  });

  factory Attraction.withAutoIncrement({
    int? id,
    // required int sequenceNumber,
    required String name,
    required String memo,
    required double longitude,
    required double latitude,
    required String date,
    required String arrivalTime,
    required String departureTime,
    required String arrivalStation,
    required String departureStation,
    required bool isVisited,
    required bool isNavigating,
  }) {
    return Attraction(
      id: id,
      sequenceNumber: 0,
      // Default value, will be set dynamically during insertion
      name: name,
      memo: memo,
      latitude: latitude,
      longitude: longitude,
      date: date,
      arrivalTime: arrivalTime,
      departureTime: departureTime,
      arrivalStation: arrivalStation,
      departureStation: departureStation,
      isVisited: isVisited,
      isNavigating: isNavigating,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'sequenceNumber': sequenceNumber,
      // Default value, will be set dynamically during insertion
      'name': name,
      'memo': memo,
      'latitude': latitude,
      'longitude': longitude,
      'date': date,
      'departureTime': departureTime,
      'arrivalTime': arrivalTime,
      'departureStation': departureStation,
      'arrivalStation': arrivalStation,
      'isVisited': isVisited,
      'isNavigating': isNavigating,
    };
  }
}
