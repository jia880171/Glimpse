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
  bool isVisiting;

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
    required this.isVisiting, double? distance,
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
    required bool isVisiting,
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
      isVisiting: isVisiting
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'sequenceNumber': sequenceNumber,
      'name': name,
      'memo': memo,
      'latitude': latitude,
      'longitude': longitude,
      'date': date,
      'arrivalTime': arrivalTime,
      'departureTime': departureTime,
      'arrivalStation': arrivalStation,
      'departureStation': departureStation,
      'isVisited': isVisited ? 1 : 0, // Convert bool to int
      'isNavigating': isNavigating ? 1 : 0, // Convert bool to int
      'isVisiting': isVisiting ? 1 : 0, // Convert bool to int
    };
  }

  Attraction copyWith({
    int? id,
    int? sequenceNumber,
    String? name,
    String? memo,
    String? date,
    double? latitude,
    double? longitude,
    String? arrivalTime,
    String? departureTime,
    String? arrivalStation,
    String? departureStation,
    double? distance,
    bool? isVisited,
    bool? isNavigating,
    bool? isVisiting,
  }) {
    return Attraction(
      id: id ?? this.id,
      sequenceNumber: sequenceNumber ?? this.sequenceNumber,
      name: name ?? this.name,
      memo: memo ?? this.memo,
      date: date ?? this.date,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      arrivalTime: arrivalTime ?? this.arrivalTime,
      departureTime: departureTime ?? this.departureTime,
      arrivalStation: arrivalStation ?? this.arrivalStation,
      departureStation: departureStation ?? this.departureStation,
      distance: distance ?? this.distance,
      isVisited: isVisited ?? this.isVisited,
      isNavigating: isNavigating ?? this.isNavigating,
      isVisiting: isVisiting ?? this.isVisiting,
    );
  }
}
