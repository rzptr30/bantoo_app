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
    };
  }

  factory Campaign.fromMap(Map<String, dynamic> map) {
    return Campaign(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      targetFund: map['targetFund'],
      collectedFund: map['collectedFund'],
      endDate: map['endDate'],
      imagePath: map['imagePath'],
      status: map['status'] ?? 'pending',
      creator: map['creator'] ?? '',
    );
  }
}