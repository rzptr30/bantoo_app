import 'dart:io';
import 'package:flutter/material.dart';
import '../db/campaign_database.dart';
import '../db/volunteer_campaign_database.dart';
import '../models/campaign.dart';
import '../models/volunteer_campaign.dart';

class ArchiveCampaignScreen extends StatefulWidget {
  const ArchiveCampaignScreen({Key? key}) : super(key: key);

  @override
  State<ArchiveCampaignScreen> createState() => _ArchiveCampaignScreenState();
}

class _ArchiveCampaignScreenState extends State<ArchiveCampaignScreen> with SingleTickerProviderStateMixin {
  late Future<List<Campaign>> _donasiArchiveFuture;
  late Future<List<VolunteerCampaign>> _volunteerArchiveFuture;

  @override
  void initState() {
    super.initState();
    _donasiArchiveFuture = CampaignDatabase.instance.getArchivedCampaigns();
    _volunteerArchiveFuture = VolunteerCampaignDatabase.instance.getArchivedVolunteerCampaigns();
  }

  Color _statusColor(String status) {
    switch (status) {
      case "approved":
        return Colors.green;
      case "rejected":
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _statusLabel(String status) {
    switch (status) {
      case "approved":
        return "Disetujui";
      case "rejected":
        return "Ditolak";
      default:
        return status;
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text("Campaign Archive"),
          bottom: TabBar(
            tabs: [
              Tab(icon: Icon(Icons.campaign), text: "Donasi"),
              Tab(icon: Icon(Icons.volunteer_activism), text: "Volunteer"),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // Donasi Campaign Archive
            FutureBuilder<List<Campaign>>(
              future: _donasiArchiveFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                final campaigns = snapshot.data ?? [];
                if (campaigns.isEmpty) {
                  return Center(child: Text("Belum ada campaign donasi yang diarsipkan."));
                }
                return ListView.builder(
                  itemCount: campaigns.length,
                  itemBuilder: (context, i) {
                    final c = campaigns[i];
                    final expired = DateTime.tryParse(c.endDate);
                    return Card(
                      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      child: ListTile(
                        leading: c.imagePath.isNotEmpty && File(c.imagePath).existsSync()
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.file(File(c.imagePath), width: 60, height: 60, fit: BoxFit.cover),
                              )
                            : Container(
                                width: 60,
                                height: 60,
                                decoration: BoxDecoration(
                                  color: Colors.grey[300],
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(Icons.image, size: 32),
                              ),
                        title: Text(
                          c.title,
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Pembuat: ${c.creator}"),
                            Text("Target: Rp${c.targetFund}"),
                            Text("Sampai: ${expired != null ? "${expired.day.toString().padLeft(2, '0')}/${expired.month.toString().padLeft(2, '0')}/${expired.year}" : "-"}"),
                            Row(
                              children: [
                                Text(
                                  _statusLabel(c.status),
                                  style: TextStyle(
                                    color: _statusColor(c.status),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            if (c.status == "rejected")
                              Text(
                                "Keterangan: Campaign ditolak (cek deskripsi/komentar admin di halaman approval)",
                                style: TextStyle(color: Colors.red[700], fontSize: 12),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
            // Volunteer Campaign Archive
            FutureBuilder<List<VolunteerCampaign>>(
              future: _volunteerArchiveFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                final campaigns = snapshot.data ?? [];
                if (campaigns.isEmpty) {
                  return Center(child: Text("Belum ada campaign volunteer yang diarsipkan."));
                }
                return ListView.builder(
                  itemCount: campaigns.length,
                  itemBuilder: (context, i) {
                    final c = campaigns[i];
                    return Card(
                      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      child: ListTile(
                        leading: c.imagePath.isNotEmpty && File(c.imagePath).existsSync()
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.file(File(c.imagePath), width: 60, height: 60, fit: BoxFit.cover),
                              )
                            : Container(
                                width: 60,
                                height: 60,
                                decoration: BoxDecoration(
                                  color: Colors.grey[300],
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(Icons.image, size: 32),
                              ),
                        title: Text(
                          c.title,
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Pembuat: ${c.creator}"),
                            Text("Tanggal Event: ${c.eventDate.day.toString().padLeft(2, '0')}/${c.eventDate.month.toString().padLeft(2, '0')}/${c.eventDate.year}"),
                            Row(
                              children: [
                                Text(
                                  _statusLabel(c.status),
                                  style: TextStyle(
                                    color: _statusColor(c.status),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            if (c.status == "rejected")
                              Text(
                                "Keterangan: Campaign volunteer ditolak.",
                                style: TextStyle(color: Colors.red[700], fontSize: 12),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}