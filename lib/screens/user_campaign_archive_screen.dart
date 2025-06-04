import 'dart:io';
import 'package:flutter/material.dart';
import '../db/campaign_database.dart';
import '../models/campaign.dart';

class UserCampaignArchiveScreen extends StatelessWidget {
  final String username;
  const UserCampaignArchiveScreen({Key? key, required this.username}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Arsip Campaign Saya")),
      body: FutureBuilder<List<Campaign>>(
        future: CampaignDatabase.instance.getCampaignsByCreator(username),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            // Sama seperti admin: teks kalem di tengah
            return Center(
              child: Text(
                "Belum ada campaign yang diajukan.",
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            );
          }
          final campaigns = snapshot.data!;
          return ListView.builder(
            itemCount: campaigns.length,
            itemBuilder: (context, i) {
              final c = campaigns[i];
              return Card(
                margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  leading: c.imagePath.isNotEmpty && File(c.imagePath).existsSync()
                    ? Image.file(File(c.imagePath), width: 48, height: 48, fit: BoxFit.cover)
                    : Icon(Icons.image, size: 48),
                  title: Text(c.title),
                  subtitle: Text(
                    "Oleh: ${c.creator}\nTarget: Rp${c.targetFund}\nStatus: ${c.status}",
                  ),
                  isThreeLine: true,
                ),
              );
            },
          );
        },
      ),
    );
  }
}