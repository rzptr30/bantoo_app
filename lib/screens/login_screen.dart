import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../db/user_database.dart';
import 'dashboard_screen.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _controllerEmail = TextEditingController();
  final _controllerPass = TextEditingController();
  String _error = '';
  bool _isLoading = false;
  bool _showPassword = false; // Untuk toggle mata

  Future<void> _login() async {
    setState(() {
      _error = '';
      _isLoading = true;
    });

    final email = _controllerEmail.text.trim();
    final password = _controllerPass.text.trim();

    String? username;
    String? role;

    // Hardcode admin
    if (email == "wongcilik@gmail.com" && password == "bantuyuk123") {
      username = "AdminWongCilik";
      role = "admin";
    } else {
      final user = await UserDatabase.instance.getUserByEmailAndPassword(
        email,
        password,
      );
      if (user != null) {
        username = user.username;
        role = "user";
      }
    }

    setState(() {
      _isLoading = false;
    });

    if (username != null && role != null) {
      // Simpan ke SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('role', role);
      await prefs.setString('username', username);
      await prefs.setString('email', email);

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (_) => DashboardScreen(
                  username: username!,
                  role: role!,
                )),
      );
    } else {
      setState(() => _error = 'Email atau Password salah');
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
                  Text("Sign in to your account", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  SizedBox(height: 24),
                  TextField(
                    controller: _controllerEmail,
                    decoration: InputDecoration(
                      labelText: "Email",
                      prefixIcon: Icon(Icons.person_outline),
                    ),
                  ),
                  SizedBox(height: 16),
                  TextField(
                    controller: _controllerPass,
                    obscureText: !_showPassword,
                    decoration: InputDecoration(
                      labelText: "Password",
                      prefixIcon: Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        icon: Icon(_showPassword ? Icons.visibility : Icons.visibility_off),
                        onPressed: () {
                          setState(() {
                            _showPassword = !_showPassword;
                          });
                        },
                      ),
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
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Text(_error, style: TextStyle(color: Colors.red)),
                    ),
                  SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _login,
                    child: _isLoading
                        ? SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : Text("Log In"),
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
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => RegisterScreen()),
                        ),
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