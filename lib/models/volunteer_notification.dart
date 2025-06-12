class VolunteerNotification {
  final int? id;
  final int campaignId;
  final String creator;       // username creator campaign (penerima notifikasi)
  final String registrant;    // username/email pendaftar volunteer
  final String registrantName;
  final DateTime createdAt;
  final bool isRead;

  VolunteerNotification({
    this.id,
    required this.campaignId,
    required this.creator,
    required this.registrant,
    required this.registrantName,
    required this.createdAt,
    this.isRead = false,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'campaignId': campaignId,
    'creator': creator,
    'registrant': registrant,
    'registrantName': registrantName,
    'createdAt': createdAt.toIso8601String(),
    'isRead': isRead ? 1 : 0,
  };

  factory VolunteerNotification.fromMap(Map<String, dynamic> map) => VolunteerNotification(
    id: map['id'],
    campaignId: map['campaignId'],
    creator: map['creator'],
    registrant: map['registrant'],
    registrantName: map['registrantName'],
    createdAt: DateTime.parse(map['createdAt']),
    isRead: map['isRead'] == 1,
  );
}