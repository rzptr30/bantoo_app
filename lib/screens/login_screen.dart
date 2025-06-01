import 'package:flutter/material.dart';
import '../db/user_database.dart';
import '../models/user.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _controllerUser = TextEditingController();
  final _controllerPass = TextEditingController();
  String _error = '';

  void _login() async {
    final user = await UserDatabase.instance.getUser(
      _controllerUser.text.trim(),
      _controllerPass.text.trim(),
    );
    if (user != null) {
      // TODO: Ganti dengan halaman dashboard nanti
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Login Sukses!')));
    } else {
      setState(() => _error = 'Username/Email atau Password salah');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFEFF3F6),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Image.asset('assets/header_img.png'), // tambahkan gambar header sesuai desain
            Container(
              margin: EdgeInsets.only(top: -30),
              padding: EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text("Sign in to your account", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  SizedBox(height: 24),
                  TextField(
                    controller: _controllerUser,
                    decoration: InputDecoration(
                      labelText: "Email or Username",
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
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {},
                      child: Text("Forgot Password?"),
                    ),
                  ),
                  if (_error.isNotEmpty)
                    Text(_error, style: TextStyle(color: Colors.red)),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _login,
                    child: Text("Log In"),
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
                      Text("Don't have an account? "),
                      GestureDetector(
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => RegisterScreen())),
                        child: Text("Sign Up", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)),
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