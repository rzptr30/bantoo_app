import 'package:flutter/material.dart';
import '../db/user_database.dart';
import '../models/user.dart';

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _controllerEmail = TextEditingController();
  final _controllerUsername = TextEditingController();
  final _controllerPass = TextEditingController();
  final _controllerConfirm = TextEditingController();
  bool _accept = false;
  String _error = '';
  bool _isLoading = false;

  void _register() async {
    setState(() {
      _error = '';
      _isLoading = true;
    });
    try {
      if (!_accept) {
        setState(() {
          _error = 'Anda harus menyetujui Terms & Conditions';
          _isLoading = false;
        });
        return;
      }
      if (_controllerPass.text != _controllerConfirm.text) {
        setState(() {
          _error = 'Password tidak sama';
          _isLoading = false;
        });
        return;
      }
      if (_controllerEmail.text.isEmpty || _controllerUsername.text.isEmpty || _controllerPass.text.isEmpty) {
        setState(() {
          _error = 'Semua field harus diisi';
          _isLoading = false;
        });
        return;
      }

      // Cek username unik
      final existingUser = await UserDatabase.instance.getUserByUsername(_controllerUsername.text.trim());
      if (existingUser != null) {
        setState(() {
          _error = 'Username sudah terdaftar, silakan gunakan username lain';
          _isLoading = false;
        });
        return;
      }

      // Simpan user ke SQLite
      final user = User(
        username: _controllerUsername.text.trim(),
        email: _controllerEmail.text.trim(),
        password: _controllerPass.text.trim(),
      );
      await UserDatabase.instance.createUser(user);

      setState(() {
        _isLoading = false;
      });

      // Tampilkan pop-up sukses dan langsung ke login
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => AlertDialog(
          title: Text('Sign Up Success'),
          content: Text('Akun berhasil dibuat. Silakan login!'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // tutup dialog
                Navigator.pop(context); // kembali ke login
              },
              child: Text('OK'),
            ),
          ],
        ),
      );
    } catch (e) {
      setState(() {
        _error = 'Terjadi error saat register: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFEFF3F6),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Image.asset('assets/header_img.png'),
            Container(
              margin: EdgeInsets.only(top: 0),
              padding: EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text("Create new account", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  SizedBox(height: 24),
                  TextField(
                    controller: _controllerEmail,
                    decoration: InputDecoration(
                      labelText: "Email",
                      prefixIcon: Icon(Icons.email_outlined),
                    ),
                  ),
                  SizedBox(height: 16),
                  TextField(
                    controller: _controllerUsername,
                    decoration: InputDecoration(
                      labelText: "Username",
                      prefixIcon: Icon(Icons.person_outline),
                    ),
                  ),
                  SizedBox(height: 16),
                  TextField(
                    controller: _controllerPass,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: "Password",
                      prefixIcon: Icon(Icons.lock_outline),
                    ),
                  ),
                  SizedBox(height: 16),
                  TextField(
                    controller: _controllerConfirm,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: "Confirm Password",
                      prefixIcon: Icon(Icons.lock_outline),
                    ),
                  ),
                  SizedBox(height: 16),
                  Row(
                    children: [
                      Checkbox(
                        value: _accept,
                        onChanged: (val) => setState(() => _accept = val!),
                      ),
                      Expanded(
                        child: Text("I accept Terms & conditions and Privacy policy."),
                      ),
                    ],
                  ),
                  if (_error.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Text(_error, style: TextStyle(color: Colors.red)),
                    ),
                  SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _register,
                    child: _isLoading
                        ? SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : Text("Sign Up"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF222E3A),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                      padding: EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                  SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("Already have an account? "),
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Text("Log In", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)),
                      )
                    ],
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}