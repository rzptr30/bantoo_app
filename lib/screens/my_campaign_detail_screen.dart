import 'dart:io';
import 'package:flutter/material.dart';
import '../models/campaign.dart';

class MyCampaignDetailScreen extends StatelessWidget {
  final Campaign campaign;
  const MyCampaignDetailScreen({required this.campaign});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Detail Campaign Donasi'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (campaign.imagePath.isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.file(
                  File(campaign.imagePath),
                  width: double.infinity,
                  height: 180,
                  fit: BoxFit.cover,
                ),
              ),
            SizedBox(height: 16),
            Text(
              campaign.title,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
            ),
            SizedBox(height: 8),
            Text("Status: ${campaign.status.toUpperCase()}",
                style: TextStyle(
                  color: campaign.status == "approved"
                      ? Colors.green
                      : (campaign.status == "pending" ? Colors.orange : Colors.red),
                  fontWeight: FontWeight.bold,
                )),
            SizedBox(height: 10),
            Text("Target Donasi: Rp ${campaign.targetFund}"),
            Text("Terkumpul: Rp ${campaign.collectedFund}"),
            Text("Batas: ${campaign.endDate}"),
            SizedBox(height: 12),
            Text(
              campaign.description,
              style: TextStyle(fontSize: 16),
            ),
            // Feedback jika rejected
            if (campaign.status == "rejected" &&
                campaign.adminFeedback != null &&
                campaign.adminFeedback!.trim().isNotEmpty)
              Container(
                margin: EdgeInsets.only(top: 15),
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  border: Border.all(color: Colors.red),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.info_outline, color: Colors.red, size: 22),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        "Ditolak admin:\n${campaign.adminFeedback}",
                        style: TextStyle(
                            color: Colors.red[700], fontStyle: FontStyle.italic),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}