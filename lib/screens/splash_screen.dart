import 'dart:async';
import 'package:flutter/material.dart';
import 'login_screen.dart'; // Ganti sesuai route/layar utama Anda

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 2), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => LoginScreen()), // atau DashboardScreen jika auto-login
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Sesuaikan background
      body: Center(
        child: Image.asset(
          "assets/logo_bantoo.png",
          width: 180,
          height: 180,
        ),
      ),
    );
  }
}