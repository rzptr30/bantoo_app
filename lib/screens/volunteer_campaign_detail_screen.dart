import 'dart:io';
import 'package:flutter/material.dart';
import '../models/volunteer_campaign.dart';

class VolunteerCampaignDetailScreen extends StatelessWidget {
  final VolunteerCampaign campaign;
  const VolunteerCampaignDetailScreen({Key? key, required this.campaign}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(campaign.title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            if (campaign.imagePath.isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: Image.file(
                  File(campaign.imagePath),
                  height: 180,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
            SizedBox(height: 18),
            Text(campaign.title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
            SizedBox(height: 6),
            Text("Lokasi: ${campaign.location}"),
            Text("Kuota: ${campaign.quota}"),
            // Text("Biaya: ${campaign.fee}"),
            Text("Tanggal Event: ${campaign.eventDate.day}/${campaign.eventDate.month}/${campaign.eventDate.year}"),
            Text("Oprec: ${campaign.registrationStart.day}/${campaign.registrationStart.month}/${campaign.registrationStart.year} - ${campaign.registrationEnd.day}/${campaign.registrationEnd.month}/${campaign.registrationEnd.year}"),
            SizedBox(height: 16),
            Text(campaign.description),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Tambah aksi join volunteer, dsb
              },
              child: Text("Join Now"),
            ),
          ],
        ),
      ),
    );
  }
}