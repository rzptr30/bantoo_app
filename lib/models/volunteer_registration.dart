class VolunteerRegistration {
  final int? id;
  final int campaignId;
  final String user;
  final String name;
  final String phone;
  final String email;         // NEW
  final String gender;        // NEW
  final int umur;             // NEW
  final String experience;    // NEW
  final String status;
  final String? adminFeedback;
  final DateTime registeredAt;

  VolunteerRegistration({
    this.id,
    required this.campaignId,
    required this.user,
    required this.name,
    required this.phone,
    required this.email,         // NEW
    required this.gender,        // NEW
    required this.umur,          // NEW
    required this.experience,    // NEW
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
      'email': email,           // NEW
      'gender': gender,         // NEW
      'umur': umur,             // NEW
      'experience': experience, // NEW
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
      email: map['email'] ?? '',
      gender: map['gender'] ?? '',
      umur: map['umur'] ?? 0,
      experience: map['experience'] ?? '',
      status: map['status'],
      adminFeedback: map['adminFeedback'],
      registeredAt: DateTime.parse(map['registeredAt']),
    );
  }
}