class User {
  final int? id;
  final String username;
  final String email;
  final String password;
  final String? phone;
  final String? country;
  final String? avatarAsset; // Tambahkan ini!

  User({
    this.id,
    required this.username,
    required this.email,
    required this.password,
    this.phone,
    this.country,
    this.avatarAsset, // Tambahkan ini!
  });

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'],
      username: map['username'],
      email: map['email'],
      password: map['password'],
      phone: map['phone'],
      country: map['country'],
      avatarAsset: map['avatarAsset'], // Tambahkan ini!
    );
  }

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'username': username,
      'email': email,
      'password': password,
      'phone': phone,
      'country': country,
      'avatarAsset': avatarAsset, // Tambahkan ini!
    };
    if (id != null) map['id'] = id;
    return map;
  }
}