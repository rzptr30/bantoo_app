import 'dart:io';
import 'package:flutter/material.dart';
import '../db/campaign_database.dart';
import '../models/campaign.dart';

class EmergencyBantooSection extends StatefulWidget {
  final String role;
  final String username;
  const EmergencyBantooSection({Key? key, required this.role, required this.username}) : super(key: key);

  @override
  EmergencyBantooSectionState createState() => EmergencyBantooSectionState();
}

class EmergencyBantooSectionState extends State<EmergencyBantooSection> {
  late Future<List<Campaign>> _campaignsFuture;

  @override
  void initState() {
    super.initState();
    _loadCampaigns();
  }

  void _loadCampaigns() {
    if (widget.role == "admin") {
      // Admin bisa melihat semua campaign (pending, approved, rejected)
      _campaignsFuture = CampaignDatabase.instance.getAllCampaigns();
    } else {
      // User hanya melihat campaign yang sudah di-ACC
      _campaignsFuture = CampaignDatabase.instance.getCampaignsByStatus("approved");
    }
  }

  /// Panggil ini setelah tambah campaign untuk refresh tampilan
  void refreshCampaigns() {
    setState(() {
      _loadCampaigns();
    });
  }

  Color _statusColor(String status) {
    switch (status) {
      case "pending":
        return Colors.orange;
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
      case "pending":
        return "Pending";
      case "approved":
        return "Active";
      case "rejected":
        return "Rejected";
      default:
        return status;
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Campaign>>(
      future: _campaignsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Padding(
            padding: const EdgeInsets.all(24.0),
            child: Text(
              widget.role == "admin"
                  ? "Belum ada campaign."
                  : "Belum ada campaign emergency.\nKlik tombol '+' untuk menambah.",
              style: TextStyle(color: Colors.grey, fontSize: 16),
              textAlign: TextAlign.center,
            ),
          );
        }
        final campaigns = snapshot.data!;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
              child: Row(
                children: [
                  Text(
                    "Emergency Bantoo!",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 22,
                      color: Color(0xFF183B56),
                    ),
                  ),
                  Spacer(),
                  TextButton(
                    onPressed: () {},
                    child: Text("View all"),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 250,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: campaigns.length,
                itemBuilder: (context, i) {
                  final c = campaigns[i];
                  final percent = (c.targetFund == 0)
                      ? 0.0
                      : (c.collectedFund / c.targetFund).clamp(0.0, 1.0);
                  final expired = DateTime.tryParse(c.endDate);
                  return Container(
                    width: 250,
                    margin: EdgeInsets.only(
                        left: i == 0 ? 16 : 8, right: 8, bottom: 8),
                    child: Stack(
                      children: [
                        Card(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18)),
                          elevation: 2,
                          child: Padding(
                            padding: const EdgeInsets.all(10),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: c.imagePath.isNotEmpty &&
                                          File(c.imagePath).existsSync()
                                      ? Image.file(
                                          File(c.imagePath),
                                          width: double.infinity,
                                          height: 80,
                                          fit: BoxFit.cover,
                                        )
                                      : Container(
                                          width: double.infinity,
                                          height: 80,
                                          color: Colors.grey[300],
                                          child: Icon(Icons.image, size: 40),
                                        ),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  c.creator,
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold, fontSize: 14),
                                ),
                                Text(
                                  c.title,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold, fontSize: 17),
                                ),
                                SizedBox(height: 5),
                                Row(
                                  children: [
                                    Expanded(
                                      child: LinearProgressIndicator(
                                        value: percent,
                                        backgroundColor: Colors.grey[300],
                                        color: Colors.green,
                                      ),
                                    ),
                                    SizedBox(width: 8),
                                    Text("${(percent * 100).toInt()}%"),
                                  ],
                                ),
                                SizedBox(height: 5),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text("collected",
                                            style: TextStyle(
                                                fontSize: 13,
                                                color: Colors.grey[700])),
                                        Text(
                                          "Rp${c.collectedFund.toString()}",
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 15),
                                        ),
                                      ],
                                    ),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: [
                                        Text("expired",
                                            style: TextStyle(
                                                fontSize: 13,
                                                color: Colors.grey[700])),
                                        Text(
                                          expired != null
                                              ? "${expired.day.toString().padLeft(2, '0')}/${expired.month.toString().padLeft(2, '0')}/${expired.year}"
                                              : "-",
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 15),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        // Status badge di pojok kanan atas untuk admin
                        if (widget.role == "admin")
                          Positioned(
                            right: 14,
                            top: 14,
                            child: Container(
                              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: _statusColor(c.status).withOpacity(0.13),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: _statusColor(c.status)),
                              ),
                              child: Text(
                                _statusLabel(c.status),
                                style: TextStyle(
                                  color: _statusColor(c.status),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}