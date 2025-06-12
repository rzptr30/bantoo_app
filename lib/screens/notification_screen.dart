import 'package:flutter/material.dart';
import '../db/notification_database.dart';
import '../models/notification_item.dart';
import 'campaign_detail_screen.dart';
import 'volunteer_list_screen.dart';
import '../db/campaign_database.dart';
import '../models/campaign.dart';

class NotificationScreen extends StatelessWidget {
  final String username;
  const NotificationScreen({Key? key, required this.username}) : super(key: key);

  Future<void> _onNotifTap(BuildContext context, NotificationItem notif) async {
    if (notif.type == 'donation_new' || notif.type == 'volunteer_approved') {
      // Ambil campaignId
      final campaignId = int.tryParse(notif.relatedId ?? '');
      if (campaignId != null) {
        // Ambil data campaign dari database
        final campaign = await CampaignDatabase.instance.getCampaignById(campaignId);
        if (campaign != null) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CampaignDetailScreen(campaign: campaign),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Campaign tidak ditemukan')),
          );
        }
      }
    } else if (notif.type == 'volunteer_new') {
      final campaignId = int.tryParse(notif.relatedId ?? '');
      if (campaignId != null) {
        // Asumsi currentUsername dan campaignCreator sama dengan username
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => VolunteerListScreen(
              campaignId: campaignId,
              currentUsername: username,
              campaignCreator: username,
            ),
          ),
        );
      }
    }
    // Untuk type lain, bisa tambahkan navigasi lain
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<NotificationItem>>(
      future: NotificationDatabase.instance.getNotificationsForUser(username),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(child: Text("Belum ada notifikasi."));
        }
        final notifs = snapshot.data!;
        return ListView.builder(
          itemCount: notifs.length,
          itemBuilder: (context, i) {
            final n = notifs[i];
            IconData icon;
            if (n.type == 'donation_new') {
              icon = Icons.attach_money;
            } else if (n.type == 'volunteer_new') {
              icon = Icons.people;
            } else {
              icon = Icons.notifications;
            }
            return ListTile(
              leading: Icon(icon),
              title: Text(n.message),
              subtitle: Text('${n.date.day.toString().padLeft(2, '0')}/'
                  '${n.date.month.toString().padLeft(2, '0')}/'
                  '${n.date.year} ${n.date.hour.toString().padLeft(2, '0')}:'
                  '${n.date.minute.toString().padLeft(2, '0')}'),
              onTap: () => _onNotifTap(context, n),
            );
          },
        );
      },
    );
  }
}