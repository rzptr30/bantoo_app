class User {
  final int? id;
  String username;
  String email;
  String password;
  String? phone;
  String? country;

  User({
    this.id,
    required this.username,
    required this.email,
    required this.password,
    this.phone,
    this.country,
  });

  // Convert User object to Map for SQLite
  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'username': username,
      'email': email,
      'password': password,
      'phone': phone,
      'country': country,
    };
    if (id != null) map['id'] = id;
    return map;
  }

  // Create User object from Map (from SQLite)
  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'] as int?,
      username: map['username'] as String,
      email: map['email'] as String,
      password: map['password'] as String,
      phone: map['phone'] as String?,
      country: map['country'] as String?,
    );
  }
}