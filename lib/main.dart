import 'package:flutter/material.dart';
import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/profile_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bantoo App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'Montserrat',
      ),
      // SplashScreen sebagai halaman pertama
      initialRoute: '/splash',
      routes: {
        '/splash': (context) => SplashScreen(),
        '/': (context) => LoginScreen(),
        '/register': (context) => RegisterScreen(),
        '/dashboard': (context) => DashboardScreen(username: '', role: ''),
        '/profile': (context) => ProfileScreen(
              username: 'User',
              email: 'user@email.com',
              role: '',
              avatarAsset: "assets/images/default_avatar.png",
            ),
      },
    );
  }
}