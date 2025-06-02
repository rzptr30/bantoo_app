import 'dart:io';
import 'package:flutter/material.dart';
import '../db/campaign_database.dart';
import '../models/campaign.dart';

class EmergencyBantooSection extends StatefulWidget {
  const EmergencyBantooSection({Key? key}) : super(key: key);

  @override
  State<EmergencyBantooSection> createState() => _EmergencyBantooSectionState();
}

class _EmergencyBantooSectionState extends State<EmergencyBantooSection> {
  late Future<List<Campaign>> _campaignsFuture;

  @override
  void initState() {
    super.initState();
    _campaignsFuture = CampaignDatabase.instance.getAllCampaigns();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Campaign>>(
      future: _campaignsFuture,
      builder: (context, snapshot) {
        if (!snapshot.hasData) return Center(child: CircularProgressIndicator());
        final campaigns = snapshot.data!;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
              child: Row(
                children: [
                  Text("Emergency Bantoo!", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22, color: Color(0xFF183B56))),
                  Spacer(),
                  TextButton(onPressed: () {}, child: Text("View all"))
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
                  final percent = (c.collectedFund / c.targetFund).clamp(0.0, 1.0);
                  final expired = DateTime.parse(c.endDate);
                  return Container(
                    width: 250,
                    margin: EdgeInsets.only(left: i == 0 ? 16 : 8, right: 8, bottom: 8),
                    child: Card(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                      elevation: 2,
                      child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.file(File(c.imagePath), width: double.infinity, height: 100, fit: BoxFit.cover),
                            ),
                            SizedBox(height: 10),
                            Text("Fundraiser", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                            Text(c.title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
                            SizedBox(height: 6),
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
                            SizedBox(height: 6),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text("collected", style: TextStyle(fontSize: 13, color: Colors.grey[700])),
                                    Text("Rp${c.collectedFund.toString()}", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                                  ],
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text("expired", style: TextStyle(fontSize: 13, color: Colors.grey[700])),
                                    Text("${expired.day.toString().padLeft(2, '0')}/${expired.month.toString().padLeft(2, '0')}/${expired.year}", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                                  ],
                                ),
                              ],
                            )
                          ],
                        ),
                      ),
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