class AppNotification {
  final int? id;
  final String targetUser; // username (atau "admin" untuk admin), atau "all" untuk broadcast
  final String type; // campaign_submitted, campaign_feedback, donation, volunteer_register, dst
  final String title;
  final String message;
  final String? relatedId; // id campaign/donation/volunteer, dsb (opsional)
  final DateTime createdAt;

  AppNotification({
    this.id,
    required this.targetUser,
    required this.type,
    required this.title,
    required this.message,
    this.relatedId,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'targetUser': targetUser,
    'type': type,
    'title': title,
    'message': message,
    'relatedId': relatedId,
    'createdAt': createdAt.toIso8601String(),
  };

  factory AppNotification.fromMap(Map<String, dynamic> map) => AppNotification(
    id: map['id'],
    targetUser: map['targetUser'],
    type: map['type'],
    title: map['title'],
    message: map['message'],
    relatedId: map['relatedId'],
    createdAt: DateTime.parse(map['createdAt']),
  );
}