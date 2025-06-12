class VolunteerApplicant {
  final int? id;
  final int campaignId;      // ID campaign volunteer yang didaftar
  final String userId;       // ID atau username user yang mendaftar
  final String name;         // Nama user (opsional, untuk display)
  final String email;        // Email user (opsional)
  final String phone;        // No HP user (opsional)
  final DateTime appliedAt;  // Tanggal mendaftar
  final String status;       // 'pending', 'approved', 'rejected' (opsional, jika ada proses verifikasi)
  final String? note;        // Catatan tambahan (opsional, misal: alasan, dsb)

  VolunteerApplicant({
    this.id,
    required this.campaignId,
    required this.userId,
    required this.name,
    required this.email,
    required this.phone,
    required this.appliedAt,
    this.status = 'pending',
    this.note,
  });

  VolunteerApplicant copyWith({
    int? id,
    int? campaignId,
    String? userId,
    String? name,
    String? email,
    String? phone,
    DateTime? appliedAt,
    String? status,
    String? note,
  }) {
    return VolunteerApplicant(
      id: id ?? this.id,
      campaignId: campaignId ?? this.campaignId,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      appliedAt: appliedAt ?? this.appliedAt,
      status: status ?? this.status,
      note: note ?? this.note,
    );
  }

  factory VolunteerApplicant.fromMap(Map<String, dynamic> map) {
    return VolunteerApplicant(
      id: map['id'] as int?,
      campaignId: map['campaignId'] as int,
      userId: map['userId'] as String,
      name: map['name'] as String,
      email: map['email'] as String,
      phone: map['phone'] as String,
      appliedAt: DateTime.parse(map['appliedAt']),
      status: map['status'] ?? 'pending',
      note: map['note'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'campaignId': campaignId,
      'userId': userId,
      'name': name,
      'email': email,
      'phone': phone,
      'appliedAt': appliedAt.toIso8601String(),
      'status': status,
      'note': note,
    };
  }
}