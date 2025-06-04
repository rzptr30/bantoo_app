import 'dart:io';
import 'package:flutter/material.dart';
import '../models/campaign.dart';

class AdminCampaignDetailScreen extends StatelessWidget {
  final Campaign campaign;
  const AdminCampaignDetailScreen({Key? key, required this.campaign}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final expired = DateTime.tryParse(campaign.endDate);
    return Scaffold(
      appBar: AppBar(title: Text("Detail Campaign")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            if (campaign.imagePath.isNotEmpty && File(campaign.imagePath).existsSync())
              Container(
                height: 180,
                width: double.infinity,
                margin: const EdgeInsets.only(bottom: 16),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.file(File(campaign.imagePath), fit: BoxFit.cover),
                ),
              )
            else
              Container(
                height: 180,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(Icons.image, size: 80, color: Colors.grey[600]),
              ),
            Text(
              campaign.title,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF183B56)),
            ),
            SizedBox(height: 8),
            Text(
              "Oleh: ${campaign.creator}",
              style: TextStyle(fontSize: 16, color: Colors.grey[800]),
            ),
            SizedBox(height: 8),
            Row(
              children: [
                Chip(
                  label: Text(
                    campaign.status.toUpperCase(),
                    style: TextStyle(
                      color: campaign.status == "approved"
                          ? Colors.green
                          : campaign.status == "pending"
                              ? Colors.orange
                              : Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  backgroundColor: Colors.grey[200],
                ),
                SizedBox(width: 16),
                if (expired != null)
                  Text(
                    "Sampai: ${expired.day.toString().padLeft(2, '0')}/${expired.month.toString().padLeft(2, '0')}/${expired.year}",
                    style: TextStyle(fontSize: 15, color: Colors.grey[700]),
                  ),
              ],
            ),
            SizedBox(height: 16),
            Text(
              "Deskripsi",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 4),
            Text(
              campaign.description,
              style: TextStyle(fontSize: 15),
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Target Dana", style: TextStyle(fontSize: 15, color: Colors.grey[700])),
                      Text(
                        "Rp${campaign.targetFund}",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Terkumpul", style: TextStyle(fontSize: 15, color: Colors.grey[700])),
                      Text(
                        "Rp${campaign.collectedFund}",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}