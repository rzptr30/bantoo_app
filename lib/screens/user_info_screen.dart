import 'package:flutter/material.dart';
import '../db/user_database.dart';
import '../models/user.dart';

class UserInfoScreen extends StatefulWidget {
  final String username;
  final String email;
  final String avatarAsset;

  const UserInfoScreen({
    Key? key,
    required this.username,
    required this.email,
    this.avatarAsset = 'assets/profile_avatar.png',
  }) : super(key: key);

  @override
  State<UserInfoScreen> createState() => _UserInfoScreenState();
}

class _UserInfoScreenState extends State<UserInfoScreen> {
  late TextEditingController _usernameController;
  late TextEditingController _emailController;
  late TextEditingController _passwordController;
  late TextEditingController _phoneController;
  String _country = 'Indonesia';

  bool _isLoading = false;
  int? _userId; // <--- TAMBAHKAN ID USER

  @override
  void initState() {
    super.initState();
    // Inisialisasi dengan data awal
    _usernameController = TextEditingController(text: widget.username);
    _emailController = TextEditingController(text: widget.email);
    _passwordController = TextEditingController(text: '');
    _phoneController = TextEditingController(text: '');
    _loadUserDetails();
  }

  Future<void> _loadUserDetails() async {
    setState(() => _isLoading = true);
    final user = await UserDatabase.instance.getUserByUsername(widget.username);
    if (user != null) {
      _userId = user.id; // <--- SIMPAN ID USER
      _usernameController.text = user.username;
      _emailController.text = user.email;
      _passwordController.text = user.password;
      _phoneController.text = user.phone ?? '';
      _country = user.country ?? 'Indonesia';
      setState(() {}); // Update tampilan
    }
    setState(() => _isLoading = false);
  }

  Future<void> _saveChanges() async {
    setState(() => _isLoading = true);

    // Validasi sederhana
    if (_usernameController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Semua field harus diisi!")),
      );
      setState(() => _isLoading = false);
      return;
    }

    if (_userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Terjadi kesalahan, user tidak ditemukan.")),
      );
      setState(() => _isLoading = false);
      return;
    }

    // Update ke database, sekarang menggunakan ID user yang benar
    final user = User(
      id: _userId, // <-- pastikan id ikut diisi
      username: _usernameController.text.trim(),
      email: _emailController.text.trim(),
      password: _passwordController.text.trim(),
      phone: _phoneController.text.trim(),
      country: _country,
    );
    await UserDatabase.instance.updateUser(user);

    setState(() => _isLoading = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Data berhasil disimpan!")),
    );
    Navigator.pop(context); // Kembali ke halaman sebelumnya (Profile)
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFEFF3F6),
      appBar: AppBar(
        backgroundColor: Color(0xFF222E3A),
        elevation: 0,
        centerTitle: true,
        title: Text("User Information", style: TextStyle(fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: EdgeInsets.all(24),
              child: Column(
                children: [
                  Center(
                    child: Column(
                      children: [
                        CircleAvatar(
                          backgroundColor: Colors.white,
                          radius: 44,
                          child: Stack(
                            children: [
                              Image.asset(widget.avatarAsset, width: 72),
                              Positioned(
                                right: 0,
                                bottom: 0,
                                child: CircleAvatar(
                                  radius: 13,
                                  backgroundColor: Colors.white,
                                  child: Icon(Icons.edit, size: 16, color: Colors.grey),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 12),
                        Text(
                          "Hi! ${_usernameController.text}",
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFF183B56)),
                        ),
                        SizedBox(height: 2),
                        Text("Bantoo's Guardian Angel", style: TextStyle(fontSize: 13, color: Colors.grey[700])),
                      ],
                    ),
                  ),
                  SizedBox(height: 24),
                  TextField(
                    controller: _usernameController,
                    decoration: InputDecoration(
                      labelText: "Username",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 16),
                  TextField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      labelText: "Email Address",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 16),
                  TextField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: "Password",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 16),
                  TextField(
                    controller: _phoneController,
                    decoration: InputDecoration(
                      labelText: "Phone Number",
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.phone,
                  ),
                  SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: _country,
                    items: ['Indonesia', 'Malaysia', 'Singapore', 'Thailand']
                        .map((c) => DropdownMenuItem(child: Text(c), value: c))
                        .toList(),
                    onChanged: (val) => setState(() => _country = val!),
                    decoration: InputDecoration(
                      labelText: "Country",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _saveChanges,
                      child: _isLoading
                          ? CircularProgressIndicator(color: Colors.white)
                          : Text("Save Changes"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF222E3A),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                        padding: EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}