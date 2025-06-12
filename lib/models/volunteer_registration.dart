class VolunteerRegistration {
  final int? id;
  final int campaignId;       // id campaign volunteer
  final String user;          // username/email pendaftar
  final String name;          // nama lengkap
  final String phone;         // nomor HP
  final String status;        // "pending", "approved", "rejected"
  final String? adminFeedback;// feedback admin (jika rejected)
  final DateTime registeredAt;// waktu daftar

  VolunteerRegistration({
    this.id,
    required this.campaignId,
    required this.user,
    required this.name,
    required this.phone,
    required this.status,
    this.adminFeedback,
    required this.registeredAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'campaignId': campaignId,
      'user': user,
      'name': name,
      'phone': phone,
      'status': status,
      'adminFeedback': adminFeedback,
      'registeredAt': registeredAt.toIso8601String(),
    };
  }

  factory VolunteerRegistration.fromMap(Map<String, dynamic> map) {
    return VolunteerRegistration(
      id: map['id'],
      campaignId: map['campaignId'],
      user: map['user'],
      name: map['name'],
      phone: map['phone'],
      status: map['status'],
      adminFeedback: map['adminFeedback'],
      registeredAt: DateTime.parse(map['registeredAt']),
    );
  }
}