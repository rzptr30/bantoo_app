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
}