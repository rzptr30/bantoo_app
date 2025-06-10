import 'dart:io';
import 'package:flutter/material.dart';
import '../db/campaign_database.dart';
import '../models/campaign.dart';
import '../models/donation.dart';
import 'campaign_detail_screen.dart';

String formatRupiah(int value) {
  return value.toString().replaceAllMapped(
    RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
    (m) => '${m[1]}.',
  );
}

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
      _campaignsFuture = CampaignDatabase.instance.getAllCampaigns();
    } else {
      _campaignsFuture = CampaignDatabase.instance.getCampaignsByStatus("approved");
    }
  }

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
        final campaigns = snapshot.data ?? [];
        if (campaigns.isEmpty) {
          // Tidak menampilkan apapun jika kosong
          return SizedBox.shrink();
        }
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
                  final expired = DateTime.tryParse(c.endDate);
                  return FutureBuilder<List<Donation>>(
                    future: CampaignDatabase.instance.getDonationsByCampaign(c.id!),
                    builder: (context, snap) {
                      int totalTerkumpul = 0;
                      if (snap.hasData) {
                        totalTerkumpul = snap.data!.fold<int>(0, (sum, d) => sum + d.amount);
                      }
                      final percent = (c.targetFund == 0)
                          ? 0.0
                          : (totalTerkumpul / c.targetFund).clamp(0.0, 1.0);

                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => CampaignDetailScreen(campaign: c),
                            ),
                          );
                        },
                        child: Container(
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
                                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                      ),
                                      Text(
                                        c.title,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
                                      ),
                                      SizedBox(height: 5),
                                      Text(
                                        "Tersedia",
                                        style: TextStyle(fontSize: 13, color: Colors.grey[700])),
                                      Text(
                                        "Rp${formatRupiah(totalTerkumpul)}",
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 15,
                                            color: Colors.blue[800]),
                                      ),
                                      SizedBox(height: 8),
                                      LinearProgressIndicator(
                                        value: percent,
                                        backgroundColor: Colors.grey[300],
                                        color: Colors.blue,
                                        minHeight: 4,
                                      ),
                                      SizedBox(height: 4),
                                      Text(
                                        "${(percent * 100).toStringAsFixed(1)}%",
                                        style: TextStyle(fontSize: 13, color: Colors.grey[700]),
                                      ),
                                      SizedBox(height: 3),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            "Target: Rp${formatRupiah(c.targetFund)}",
                                            style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                                          ),
                                          Text(
                                            expired != null
                                                ? "Sampai: ${expired.day.toString().padLeft(2, '0')}/${expired.month.toString().padLeft(2, '0')}/${expired.year}"
                                                : "-",
                                            style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
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
                        ),
                      );
                    },
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