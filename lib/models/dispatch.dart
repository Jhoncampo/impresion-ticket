class Dispatch {
  int? id;
  String plate;
  String destination;
  double estimatedPrice;
  DateTime dispatchDate;

  Dispatch({
    this.id,
    required this.plate,
    required this.destination,
    required this.estimatedPrice,
    required this.dispatchDate,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'plate': plate,
      'destination': destination,
      'estimatedPrice': estimatedPrice,
      'dispatchDate': dispatchDate.toIso8601String(),
    };
  }

  factory Dispatch.fromMap(Map<String, dynamic> map) {
    return Dispatch(
      id: map['id'],
      plate: map['plate'],
      destination: map['destination'],
      estimatedPrice: map['estimatedPrice'],
      dispatchDate: DateTime.parse(map['dispatchDate']),
    );
  }
}