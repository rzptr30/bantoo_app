import 'dart:io';
import 'package:flutter/material.dart';
import '../models/volunteer_campaign.dart';
import 'volunteer_applicant_list_screen.dart'; // <- pastikan sudah import

class MyVolunteerCampaignDetailScreen extends StatelessWidget {
  final VolunteerCampaign campaign;
  final String currentUsername; // <-- WAJIB

  const MyVolunteerCampaignDetailScreen({
    required this.campaign,
    required this.currentUsername,
    Key? key,
  }) : super(key: key);

  String _formatDate(DateTime dt) =>
      "${dt.day}/${dt.month}/${dt.year}";

  @override
  Widget build(BuildContext context) {
    final bool isCreator = campaign.creator == currentUsername; // <-- ganti di sini

    return Scaffold(
      appBar: AppBar(
        title: Text('Detail Campaign Volunteer'),
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
            Text("Lokasi: ${campaign.location}"),
            Text("Tanggal Event: ${_formatDate(campaign.eventDate)}"),
            Text("Kuota: ${campaign.quota}"),
            Text("Biaya: ${campaign.fee}"),
            SizedBox(height: 12),
            Text(
              campaign.description,
              style: TextStyle(fontSize: 16),
            ),
            if (campaign.terms.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Text("Terms: ${campaign.terms}"),
              ),
            if (campaign.disclaimer.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 5),
                child: Text("Disclaimer: ${campaign.disclaimer}"),
              ),
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
            // ==== TOMBOL LIHAT PENDAFTAR (hanya untuk creator) ====
            if (isCreator) ...[
              SizedBox(height: 24),
              Center(
                child: ElevatedButton.icon(
                  icon: Icon(Icons.people),
                  label: Text("Lihat Pendaftar"),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => VolunteerApplicantListScreen(
                          campaignId: campaign.id!,
                          campaignTitle: campaign.title,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
            // =======================================================
          ],
        ),
      ),
    );
  }
}