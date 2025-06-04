import 'package:flutter/material.dart';

class CampaignSummaryCard extends StatefulWidget {
  final String profileName;
  final String profileStatus;
  final String campaignTitle;
  final int collectedFund;
  final String infoText;

  const CampaignSummaryCard({
    Key? key,
    required this.profileName,
    required this.profileStatus,
    required this.campaignTitle,
    required this.collectedFund,
    this.infoText = "Semakin banyak donasi yang tersedia, semakin besar bantuan yang bisa disalurkan oleh gerakan ini.",
  }) : super(key: key);

  @override
  State<CampaignSummaryCard> createState() => _CampaignSummaryCardState();
}

class _CampaignSummaryCardState extends State<CampaignSummaryCard> {
  bool expanded = false;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(8),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profil
            Row(
              children: [
                CircleAvatar(radius: 24, child: Icon(Icons.account_circle, size: 32)),
                SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(widget.profileName, style: TextStyle(fontWeight: FontWeight.bold)),
                        SizedBox(width: 6),
                        Icon(Icons.verified, color: Colors.blue, size: 16),
                      ],
                    ),
                    Text(widget.profileStatus, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                  ],
                )
              ],
            ),
            SizedBox(height: 12),
            Text(widget.campaignTitle, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            SizedBox(height: 14),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Donasi tersedia", style: TextStyle(fontSize: 13, color: Colors.grey[700])),
                    Text(
                      "Rp${widget.collectedFund.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => "${m[1]}.")}",
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.red[400]),
                    ),
                  ],
                ),
                TextButton(
                  onPressed: () => setState(() => expanded = !expanded),
                  child: Row(
                    children: [
                      Text(expanded ? "Sembunyikan" : "Lihat semua", style: TextStyle(fontSize: 13)),
                      Icon(expanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down, size: 16)
                    ],
                  ),
                ),
              ],
            ),
            if (expanded)
              Container(
                margin: EdgeInsets.only(top: 12),
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Color(0xFFEAF4FB),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.campaign, color: Colors.blue, size: 18),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        widget.infoText,
                        style: TextStyle(fontSize: 13, color: Colors.black87),
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