import 'package:flutter/material.dart';

class CampaignRequestCard extends StatelessWidget {
  final VoidCallback onButtonPressed;
  const CampaignRequestCard({Key? key, required this.onButtonPressed}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(16),
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/images/hands_bg.jpg'), // Ganti dengan path gambar kamu
          fit: BoxFit.cover,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 12,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Container(
        padding: EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.5),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "BANTOO CAMPAIGN",
              style: TextStyle(
                  fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 1.5),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 12),
            Text(
              "This programme aims to have users report to us if there are disasters, circumstances, or people who may not be publicly known and need help.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.white),
            ),
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: onButtonPressed,
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                shape: StadiumBorder(),
                backgroundColor: Colors.white,
              ),
              child: Text("Bantoo!", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
            ),
            SizedBox(height: 16),
            Text(
              "\"YOU DON’T NEED MONEY TO HELP OTHERS, YOU JUST NEED A HEART TO HELP THEM\"",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}