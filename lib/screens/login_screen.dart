import 'package:flutter/material.dart';
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

  void _login() async {
    setState(() {
      _error = '';
      _isLoading = true;
    });
    final user = await UserDatabase.instance.getUserByEmailAndPassword(
      _controllerEmail.text.trim(),
      _controllerPass.text.trim(),
    );
    setState(() {
      _isLoading = false;
    });
    if (user != null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => DashboardScreen(username: user.username)),
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