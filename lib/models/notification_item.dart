class NotificationItem {
  final int? id;
  final String user;
  final String message;
  final DateTime date;

  NotificationItem({
    this.id,
    required this.user,
    required this.message,
    required this.date,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user': user,
      'message': message,
      'date': date.toIso8601String(),
    };
  }

  factory NotificationItem.fromMap(Map<String, dynamic> map) {
    return NotificationItem(
      id: map['id'],
      user: map['user'],
      message: map['message'],
      date: DateTime.parse(map['date']),
    );
  }
}