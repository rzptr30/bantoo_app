class Donation {
  final int? id;
  final int campaignId;
  final String name;
  final int amount;
  final String time;
  final String paymentMethod;

  Donation({
    this.id,
    required this.campaignId,
    required this.name,
    required this.amount,
    required this.time,
    required this.paymentMethod,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'campaignId': campaignId,
    'name': name,
    'amount': amount,
    'time': time,
    'paymentMethod': paymentMethod,
  };

  factory Donation.fromMap(Map<String, dynamic> map) => Donation(
    id: map['id'],
    campaignId: map['campaignId'],
    name: map['name'],
    amount: map['amount'],
    time: map['time'],
    paymentMethod: map['paymentMethod'] ?? '', 
  );
}