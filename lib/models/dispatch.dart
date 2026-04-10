class Dispatch {
  int? id;
  String plate;
  String origin;
  String destination;
  double? estimatedPrice;
  DateTime dispatchDate;

  Dispatch({
    this.id,
    required this.plate,
    this.origin = "Jumbo la 65",
    required this.destination,
    this.estimatedPrice = 0.0,
    required this.dispatchDate,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'plate': plate,
      'origin': origin,
      'destination': destination,
      'estimatedPrice': estimatedPrice,
      'dispatchDate': dispatchDate.toIso8601String(),
    };
  }

  factory Dispatch.fromMap(Map<String, dynamic> map) {
    return Dispatch(
      id: map['id'],
      plate: map['plate'],
      origin: map['origin'],
      destination: map['destination'],
      estimatedPrice: map['estimatedPrice'] ?? 0.0,
      dispatchDate: DateTime.parse(map['dispatchDate']),
    );
  }
  
}