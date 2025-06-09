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
  final String status; // pending, approved, rejected
  final DateTime createdAt;

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
    );
  }

  // Tambah method copyWith
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
    );
  }
}