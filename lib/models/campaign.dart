class Campaign {
  int? id;
  String title;
  String description;
  int targetFund;
  int collectedFund;
  String endDate;
  String imagePath;
  String status;    // pending, approved, rejected
  String creator;   // username/email pembuat campaign
  String? adminFeedback; // alasan/feedback dari admin (opsional, hanya jika rejected)

  Campaign({
    this.id,
    required this.title,
    required this.description,
    required this.targetFund,
    required this.collectedFund,
    required this.endDate,
    required this.imagePath,
    required this.status,
    required this.creator,
    this.adminFeedback,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'targetFund': targetFund,
      'collectedFund': collectedFund,
      'endDate': endDate,
      'imagePath': imagePath,
      'status': status,
      'creator': creator,
      'adminFeedback': adminFeedback,
    };
  }

  factory Campaign.fromMap(Map<String, dynamic> map) {
    return Campaign(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      targetFund: map['targetFund'],
      collectedFund: map['collectedFund'] ?? 0,
      endDate: map['endDate'],
      imagePath: map['imagePath'],
      status: map['status'] ?? 'pending',
      creator: map['creator'] ?? '',
      adminFeedback: map['adminFeedback'],
    );
  }

  Campaign copyWith({
    int? id,
    String? title,
    String? description,
    int? targetFund,
    int? collectedFund,
    String? endDate,
    String? imagePath,
    String? status,
    String? creator,
    String? adminFeedback,
  }) {
    return Campaign(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      targetFund: targetFund ?? this.targetFund,
      collectedFund: collectedFund ?? this.collectedFund,
      endDate: endDate ?? this.endDate,
      imagePath: imagePath ?? this.imagePath,
      status: status ?? this.status,
      creator: creator ?? this.creator,
      adminFeedback: adminFeedback ?? this.adminFeedback,
    );
  }
}