class VolunteerCampaign {
  final int? id;
  final String title;
  final String description;
  final String location;
  final String quota;
  final String fee;
  final DateTime eventDate;
  final String imagePath;
  final String creator;
  final String status;
  final DateTime createdAt;
  final DateTime registrationStart;
  final DateTime registrationEnd;
  final String terms;       // NEW
  final String disclaimer;  // NEW
  final String? adminFeedback; // alasan/feedback dari admin (opsional, hanya jika rejected)

  VolunteerCampaign({
    this.id,
    required this.title,
    required this.description,
    required this.location,
    required this.quota,
    required this.fee,
    required this.eventDate,
    required this.imagePath,
    required this.creator,
    required this.status,
    required this.createdAt,
    required this.registrationStart,
    required this.registrationEnd,
    required this.terms,
    required this.disclaimer,
    this.adminFeedback,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'location': location,
      'quota': quota,
      'fee': fee,
      'eventDate': eventDate.toIso8601String(),
      'imagePath': imagePath,
      'creator': creator,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
      'registrationStart': registrationStart.toIso8601String(),
      'registrationEnd': registrationEnd.toIso8601String(),
      'terms': terms,
      'disclaimer': disclaimer,
      'adminFeedback': adminFeedback,
    };
  }

  factory VolunteerCampaign.fromMap(Map<String, dynamic> map) {
    return VolunteerCampaign(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      location: map['location'],
      quota: map['quota'],
      fee: map['fee'],
      eventDate: DateTime.parse(map['eventDate']),
      imagePath: map['imagePath'],
      creator: map['creator'],
      status: map['status'],
      createdAt: DateTime.parse(map['createdAt']),
      registrationStart: DateTime.parse(map['registrationStart']),
      registrationEnd: DateTime.parse(map['registrationEnd']),
      terms: map['terms'] ?? '',
      disclaimer: map['disclaimer'] ?? '',
      adminFeedback: map['adminFeedback'],
    );
  }

  VolunteerCampaign copyWith({
    int? id,
    String? title,
    String? description,
    String? location,
    String? quota,
    String? fee,
    DateTime? eventDate,
    String? imagePath,
    String? creator,
    String? status,
    DateTime? createdAt,
    DateTime? registrationStart,
    DateTime? registrationEnd,
    String? terms,
    String? disclaimer,
    String? adminFeedback,
  }) {
    return VolunteerCampaign(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      location: location ?? this.location,
      quota: quota ?? this.quota,
      fee: fee ?? this.fee,
      eventDate: eventDate ?? this.eventDate,
      imagePath: imagePath ?? this.imagePath,
      creator: creator ?? this.creator,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      registrationStart: registrationStart ?? this.registrationStart,
      registrationEnd: registrationEnd ?? this.registrationEnd,
      terms: terms ?? this.terms,
      disclaimer: disclaimer ?? this.disclaimer,
      adminFeedback: adminFeedback ?? this.adminFeedback,
    );
  }
}