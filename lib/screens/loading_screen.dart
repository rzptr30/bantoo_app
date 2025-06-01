import 'package:flutter/material.dart';
import 'login_screen.dart';

class LoadingScreen extends StatefulWidget {
  @override
  _LoadingScreenState createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(seconds: 2), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => LoginScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFEFF3F6),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/logo_bantoo.png', width: 120), // tambahkan logo di assets
            SizedBox(height: 16),
            Text(
              "Bantoo",
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.black87),
            )
          ],
        ),
      ),
    );
  }
}