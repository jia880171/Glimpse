class Ticket {
  final int? id;
  final String memo;
  final String date;

  final String departureTime;
  final String arrivalTime;
  final String trainName;
  final String trainNumber;

  final String carNumber;
  final String row;
  final String seat;

  final String departureStation;
  final String arrivalStation;

  bool isUsed;

  Ticket({
    this.id,
    required this.memo,
    required this.date,

    required this.departureTime,
    required this.arrivalTime,
    required this.trainName,
    required this.trainNumber,

    required this.carNumber,
    required this.row,
    required this.seat,

    required this.departureStation,
    required this.arrivalStation,

    required this.isUsed,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'memo': memo,
      'date': date,
      'departureTime': departureTime,
      'arrivalTime': arrivalTime,
      'trainName': trainName,
      'trainNumber': trainNumber,
      'carNumber': carNumber,
      'row': row,
      'seat': seat,
      'departureStation': departureStation,
      'arrivalStation': arrivalStation,
      'isUsed': isUsed,
    };
  }
}
