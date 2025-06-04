import 'package:flutter/material.dart';
import '../db/campaign_database.dart';
import '../models/campaign.dart';
import '../db/notification_database.dart';
import '../models/notification_item.dart';
import 'admin_campaign_detail_screen.dart'; // Tambahkan import ini

class AdminCampaignApprovalScreen extends StatefulWidget {
  @override
  State<AdminCampaignApprovalScreen> createState() => _AdminCampaignApprovalScreenState();
}

class _AdminCampaignApprovalScreenState extends State<AdminCampaignApprovalScreen> {
  late Future<List<Campaign>> _allCampaignsFuture;

  @override
  void initState() {
    super.initState();
    _loadAllCampaigns();
  }

  void _loadAllCampaigns() {
    _allCampaignsFuture = CampaignDatabase.instance.getAllCampaigns();
  }

  void _refresh() {
    setState(() {
      _loadAllCampaigns();
    });
  }

  Future<void> _approveCampaign(Campaign c) async {
    await CampaignDatabase.instance.updateCampaignStatus(c.id!, "approved");
    await NotificationDatabase.instance.insertNotification(NotificationItem(
      user: c.creator,
      message: 'Campaign "${c.title}" kamu telah DISETUJUI Admin!',
      date: DateTime.now(),
    ));
    _refresh();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Campaign "${c.title}" di-ACC!')));
  }

  Future<void> _rejectCampaign(Campaign c) async {
    await CampaignDatabase.instance.updateCampaignStatus(c.id!, "rejected");
    await NotificationDatabase.instance.insertNotification(NotificationItem(
      user: c.creator,
      message: 'Campaign "${c.title}" kamu DITOLAK Admin.',
      date: DateTime.now(),
    ));
    _refresh();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Campaign "${c.title}" ditolak!')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("ACC Campaign (Admin)")),
      body: FutureBuilder<List<Campaign>>(
        future: _allCampaignsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Text(
                "Belum ada campaign yang diajukan.",
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            );
          }
          final campaigns = snapshot.data!;
          return ListView.builder(
            itemCount: campaigns.length,
            itemBuilder: (context, i) {
              final c = campaigns[i];
              return Card(
                margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  title: Text(c.title),
                  subtitle: Text("Oleh: ${c.creator}\nTarget: Rp${c.targetFund}\nStatus: ${c.status}"),
                  isThreeLine: true,
                  onTap: () {
                    // Navigasi ke halaman detail campaign
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => AdminCampaignDetailScreen(campaign: c),
                      ),
                    );
                  },
                  trailing: c.status == "pending"
                      ? Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(Icons.check, color: Colors.green),
                              tooltip: "ACC",
                              onPressed: () => _approveCampaign(c),
                            ),
                            IconButton(
                              icon: Icon(Icons.close, color: Colors.red),
                              tooltip: "Tolak",
                              onPressed: () => _rejectCampaign(c),
                            ),
                          ],
                        )
                      : null,
                ),
              );
            },
          );
        },
      ),
    );
  }
}