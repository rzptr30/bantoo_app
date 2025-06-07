import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
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
    this.avatarAsset = 'assets/dashboard_avatar.png',
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
  int? _userId;

  File? _profileImageFile;
  String? _profileImagePath;

  @override
  void initState() {
    super.initState();
    _usernameController = TextEditingController(text: widget.username);
    _emailController = TextEditingController(text: widget.email);
    _passwordController = TextEditingController(text: '');
    _phoneController = TextEditingController(text: '');
    _profileImagePath = null;
    _loadUserDetails();
  }

  Future<void> _loadUserDetails() async {
    setState(() => _isLoading = true);
    final user = await UserDatabase.instance.getUserByUsername(widget.username);
    if (user != null) {
      _userId = user.id;
      _usernameController.text = user.username;
      _emailController.text = user.email;
      _passwordController.text = user.password;
      _phoneController.text = user.phone ?? '';
      _country = user.country ?? 'Indonesia';
      if (user.avatarAsset != null && user.avatarAsset!.isNotEmpty) {
        setState(() {
          _profileImagePath = user.avatarAsset;
        });
      }
    }
    setState(() => _isLoading = false);
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        _profileImageFile = File(picked.path);
        _profileImagePath = picked.path;
      });
    }
  }

  Future<void> _saveChanges() async {
    setState(() => _isLoading = true);

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

    final user = User(
      id: _userId,
      username: _usernameController.text.trim(),
      email: _emailController.text.trim(),
      password: _passwordController.text.trim(),
      phone: _phoneController.text.trim(),
      country: _country,
      avatarAsset: _profileImagePath ?? widget.avatarAsset,
    );
    await UserDatabase.instance.updateUser(user);

    setState(() => _isLoading = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Data berhasil disimpan!")),
    );
    Navigator.pop(context);
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
              child: Column(
                children: [
                  SizedBox(height: 24),
                  // FOTO + PENSIL
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      CircleAvatar(
                        radius: 52,
                        backgroundColor: Colors.white,
                        backgroundImage: _profileImageFile != null
                            ? FileImage(_profileImageFile!)
                            : (_profileImagePath != null && _profileImagePath!.isNotEmpty && !_profileImagePath!.contains('assets'))
                                ? FileImage(File(_profileImagePath!))
                                : AssetImage('assets/dashboard_avatar.png') as ImageProvider,
                      ),
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: GestureDetector(
                          onTap: _pickImage,
                          child: CircleAvatar(
                            backgroundColor: Colors.grey[300],
                            radius: 18,
                            child: Icon(Icons.edit, color: Colors.black, size: 20),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12),
                  Text(
                    "Hi! ${_usernameController.text}",
                    style: TextStyle(
                        fontSize: 22,
                        color: Color(0xFF183B56),
                        fontWeight: FontWeight.bold),
                  ),
                  Text(
                    "Bantoo's Guardian Angel",
                    style: TextStyle(fontSize: 16, color: Colors.blueGrey),
                  ),
                  SizedBox(height: 18),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Column(
                      children: [
                        TextField(
                          controller: _usernameController,
                          decoration: InputDecoration(labelText: "Username"),
                        ),
                        SizedBox(height: 10),
                        TextField(
                          controller: _emailController,
                          decoration: InputDecoration(labelText: "Email Address"),
                        ),
                        SizedBox(height: 10),
                        TextField(
                          controller: _passwordController,
                          decoration: InputDecoration(labelText: "Password"),
                          obscureText: true,
                        ),
                        SizedBox(height: 10),
                        TextField(
                          controller: _phoneController,
                          decoration: InputDecoration(labelText: "Phone Number"),
                        ),
                        SizedBox(height: 10),
                        DropdownButtonFormField<String>(
                          value: _country,
                          decoration: InputDecoration(labelText: "Country"),
                          items: ["Indonesia", "Malaysia", "Singapore", "Thailand"]
                              .map((e) => DropdownMenuItem(
                                    value: e,
                                    child: Text(e),
                                  ))
                              .toList(),
                          onChanged: (value) {
                            setState(() {
                              _country = value ?? 'Indonesia';
                            });
                          },
                        ),
                        SizedBox(height: 30),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xFF222E3A),
                              padding: EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(32)),
                            ),
                            onPressed: _saveChanges,
                            child: Text("Save Changes", style: TextStyle(fontSize: 16)),
                          ),
                        ),
                        SizedBox(height: 20),
                      ],
                    ),
                  )
                ],
              ),
            ),
    );
  }
}