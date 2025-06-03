import 'dart:io';
import 'package:flutter/material.dart';
import '../db/campaign_database.dart';
import '../models/campaign.dart';

class UserCampaignArchiveScreen extends StatelessWidget {
  final String username;
  const UserCampaignArchiveScreen({Key? key, required this.username}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Campaign>>(
      future: CampaignDatabase.instance.getCampaignsByCreator(username),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(child: Text("Kamu belum pernah mengajukan campaign."));
        }
        final campaigns = snapshot.data!;
        return ListView.builder(
          itemCount: campaigns.length,
          itemBuilder: (context, i) {
            final c = campaigns[i];
            Color statusColor;
            String statusLabel;
            switch (c.status) {
              case 'approved': statusColor = Colors.green; statusLabel = 'DISETUJUI'; break;
              case 'pending': statusColor = Colors.orange; statusLabel = 'MENUNGGU ACC'; break;
              case 'rejected': statusColor = Colors.red; statusLabel = 'DITOLAK'; break;
              default: statusColor = Colors.blueGrey; statusLabel = c.status; break;
            }
            return Card(
              margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: ListTile(
                leading: c.imagePath.isNotEmpty && File(c.imagePath).existsSync()
                  ? Image.file(File(c.imagePath), width: 48, height: 48, fit: BoxFit.cover)
                  : Icon(Icons.image, size: 48),
                title: Text(c.title),
                subtitle: Text('Status: $statusLabel', style: TextStyle(fontWeight: FontWeight.bold, color: statusColor)),
                trailing: Text(
                  c.status == 'pending' ? 'Menunggu' : c.status == 'approved' ? 'Aktif' : 'Arsip',
                  style: TextStyle(fontWeight: FontWeight.bold, color: statusColor),
                ),
              ),
            );
          },
        );
      },
    );
  }
}