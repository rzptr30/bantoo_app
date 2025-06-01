import 'package:flutter/material.dart';
import 'screens/loading_screen.dart';

void main() {
  runApp(BantooApp());
}

class BantooApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bantoo',
      debugShowCheckedModeBanner: false,
      home: LoadingScreen(),
    );
  }
}