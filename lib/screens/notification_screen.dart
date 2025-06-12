import 'package:flutter/material.dart';
import '../db/notification_database.dart';
import '../models/notification_item.dart';
import 'campaign_detail_screen.dart';
import 'volunteer_list_screen.dart';
import '../db/campaign_database.dart';
import '../models/campaign.dart';
import '../db/volunteer_campaign_database.dart';
import '../models/volunteer_campaign.dart';
import 'admin_campaign_approval_screen.dart';
// Tambahkan import berikut:
import 'my_campaign_detail_screen.dart';
import 'my_volunteer_campaign_detail_screen.dart';

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
    } else if (notif.type == 'campaign_pending') {
      // Langsung buka halaman approval admin tanpa parameter
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AdminCampaignApprovalScreen(),
        ),
      );
    } else if (notif.type == 'campaign_approved' || notif.type == 'campaign_rejected') {
      // Cek donasi atau volunteer, lalu buka detail campaign user
      final campaignId = int.tryParse(notif.relatedId ?? '');
      if (campaignId != null) {
        // Cek donasi dulu
        final campaign = await CampaignDatabase.instance.getCampaignById(campaignId);
        if (campaign != null) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => MyCampaignDetailScreen(campaign: campaign),
            ),
          );
          return;
        }
        // Jika volunteer
        final vCampaign = await VolunteerCampaignDatabase.instance.getCampaignById(campaignId);
        if (vCampaign != null) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => MyVolunteerCampaignDetailScreen(campaign: vCampaign),
            ),
          );
          return;
        }
      }
      // Fallback: buka halaman "Campaign Saya"
      Navigator.pushNamed(context, '/my_campaigns');
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
            } else if (n.type == 'campaign_pending') {
              icon = Icons.pending;
            } else if (n.type == 'campaign_approved') {
              icon = Icons.check_circle;
            } else if (n.type == 'campaign_rejected') {
              icon = Icons.cancel;
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