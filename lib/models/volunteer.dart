class Volunteer {
  final int? id;
  final String image;
  final String agency;
  final String location;
  final String description;
  final String expired;
  final String fee;
  final int quota;

  Volunteer({
    this.id,
    required this.image,
    required this.agency,
    required this.location,
    required this.description,
    required this.expired,
    required this.fee,
    required this.quota,
  });

  factory Volunteer.fromMap(Map<String, dynamic> map) {
    return Volunteer(
      id: map['id'],
      image: map['image'],
      agency: map['agency'],
      location: map['location'],
      description: map['description'],
      expired: map['expired'],
      fee: map['fee'],
      quota: map['quota'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'image': image,
      'agency': agency,
      'location': location,
      'description': description,
      'expired': expired,
      'fee': fee,
      'quota': quota,
    };
  }
}