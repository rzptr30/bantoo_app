class NotificationItem {
  final int? id;
  final String user;
  final String message;
  final DateTime date;
  final String? type;      // opsional, tipe notifikasi (misal: campaign_feedback, donation, volunteer_register, dll)
  final String? relatedId; // opsional, id campaign/donasi/volunteer terkait

  NotificationItem({
    this.id,
    required this.user,
    required this.message,
    required this.date,
    this.type,
    this.relatedId,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user': user,
      'message': message,
      'date': date.toIso8601String(),
      'type': type,
      'relatedId': relatedId,
    };
  }

  factory NotificationItem.fromMap(Map<String, dynamic> map) {
    return NotificationItem(
      id: map['id'],
      user: map['user'],
      message: map['message'],
      date: DateTime.parse(map['date']),
      type: map['type'],
      relatedId: map['relatedId'],
    );
  }
}