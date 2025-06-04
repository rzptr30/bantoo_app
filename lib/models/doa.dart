class Doa {
  final int? id;
  final int campaignId;
  final String name;
  final String message;
  final String time;

  Doa({
    this.id,
    required this.campaignId,
    required this.name,
    required this.message,
    required this.time,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'campaignId': campaignId,
    'name': name,
    'message': message,
    'time': time,
  };

  factory Doa.fromMap(Map<String, dynamic> map) => Doa(
    id: map['id'],
    campaignId: map['campaignId'],
    name: map['name'],
    message: map['message'],
    time: map['time'],
  );
}