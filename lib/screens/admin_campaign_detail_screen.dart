import 'dart:io';
import 'package:flutter/material.dart';
import '../models/campaign.dart';
import '../models/volunteer_campaign.dart';

class AdminCampaignDetailScreen extends StatelessWidget {
  final dynamic campaign; // Campaign atau VolunteerCampaign
  final bool isDonasi;

  const AdminCampaignDetailScreen({Key? key, required this.campaign, required this.isDonasi}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final campaignImage = (campaign.imagePath != null && campaign.imagePath.isNotEmpty)
        ? File(campaign.imagePath)
        : null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isDonasi ? "Detail Campaign Donasi" : "Detail Campaign Volunteer"),
      ),
      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          Align(
            alignment: Alignment.centerRight,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: isDonasi ? Colors.blue : Colors.orange,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(isDonasi ? 'Donasi' : 'Volunteer', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ),
          SizedBox(height: 12),
          Text(campaign.title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22)),
          SizedBox(height: 8),
          Text("Oleh: ${campaign.creator}", style: TextStyle(fontSize: 13, color: Colors.grey[700])),
          SizedBox(height: 8),
          Text("Status: ${_statusLabel(campaign.status)}", style: TextStyle(fontSize: 13)),
          SizedBox(height: 8),
          // Untuk Campaign: tanggal = endDate (String), untuk VolunteerCampaign: pakai createdAt
          Text("Tanggal: ${isDonasi ? campaign.endDate : _formatDate(campaign.createdAt)}", style: TextStyle(fontSize: 13)),
          SizedBox(height: 16),
          if (campaignImage != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.file(
                campaignImage,
                width: double.infinity,
                height: 180,
                fit: BoxFit.cover,
              ),
            ),
          SizedBox(height: 16),
          Text(campaign.description ?? "-"),
          SizedBox(height: 16),
          Divider(),
          if (isDonasi) ...[
            Text('Target Donasi: Rp ${campaign.targetFund}'),
            Text('Terkumpul: Rp ${campaign.collectedFund}'),
            Text('Batas Akhir: ${campaign.endDate}'),
          ],
          if (!isDonasi) ...[
            Text('Lokasi: ${campaign.location}'),
            Text('Tanggal Event: ${_formatDate(campaign.eventDate)}'),
            Text('Kuota: ${campaign.quota}'),
            Text('Biaya: ${campaign.fee}'),
            Text('Terms: ${campaign.terms ?? "-"}'),
            Text('Disclaimer: ${campaign.disclaimer ?? "-"}'),
          ]
        ],
      ),
    );
  }

  String _formatDate(DateTime? dt) {
    if (dt == null) return "-";
    return "${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}";
  }

  String _statusLabel(String status) {
    switch (status) {
      case "approved": return "Disetujui";
      case "pending": return "Menunggu";
      case "rejected": return "Ditolak";
      default: return status;
    }
  }
}