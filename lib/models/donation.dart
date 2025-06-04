class Donation {
  final int? id;
  final int campaignId;
  final String name;
  final int amount;
  final String time;

  Donation({
    this.id,
    required this.campaignId,
    required this.name,
    required this.amount,
    required this.time,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'campaignId': campaignId,
    'name': name,
    'amount': amount,
    'time': time,
  };

  factory Donation.fromMap(Map<String, dynamic> map) => Donation(
    id: map['id'],
    campaignId: map['campaignId'],
    name: map['name'],
    amount: map['amount'],
    time: map['time'],
  );
}