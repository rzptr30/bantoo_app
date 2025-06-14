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
import 'my_campaign_detail_screen.dart';
import 'my_volunteer_campaign_detail_screen.dart';
import 'volunteer_applicant_list_screen.dart';

class NotificationScreen extends StatelessWidget {
  final String username;
  const NotificationScreen({Key? key, required this.username}) : super(key: key);

  Future<void> _onNotifTap(BuildContext context, NotificationItem notif) async {
    if (notif.type == 'donation_new' || notif.type == 'volunteer_approved') {
      final campaignId = int.tryParse(notif.relatedId ?? '');
      if (campaignId != null) {
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
        final vCampaign = await VolunteerCampaignDatabase.instance.getCampaignById(campaignId);
        if (vCampaign != null) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => VolunteerApplicantListScreen(
                campaignId: vCampaign.id!,
                campaignTitle: vCampaign.title ?? '', // FIX: pastikan String, bukan String?
              ),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Campaign volunteer tidak ditemukan')),
          );
        }
      }
    } else if (notif.type == 'campaign_pending') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AdminCampaignApprovalScreen(),
        ),
      );
    } else if (notif.type == 'campaign_approved' || notif.type == 'campaign_rejected') {
      final campaignId = int.tryParse(notif.relatedId ?? '');
      if (campaignId != null) {
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
        final vCampaign = await VolunteerCampaignDatabase.instance.getCampaignById(campaignId);
        if (vCampaign != null) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => MyVolunteerCampaignDetailScreen(
                campaign: vCampaign,
                currentUsername: username,
              ),
            ),
          );
          return;
        }
      }
      Navigator.pushNamed(context, '/my_campaigns');
    }
    // Untuk type lain, bisa tambahkan navigasi lain
  }

  IconData _iconForType(String type) {
    switch (type) {
      case 'donation_new':
        return Icons.attach_money;
      case 'volunteer_new':
        return Icons.people;
      case 'volunteer_approved':
        return Icons.check_circle;
      case 'volunteer_rejected':
        return Icons.cancel;
      case 'campaign_pending':
        return Icons.pending;
      case 'campaign_approved':
        return Icons.check_circle;
      case 'campaign_rejected':
        return Icons.cancel;
      default:
        return Icons.notifications;
    }
  }

  Color? _iconColorForType(String type) {
    switch (type) {
      case 'volunteer_approved':
      case 'campaign_approved':
        return Colors.green;
      case 'volunteer_rejected':
      case 'campaign_rejected':
        return Colors.red;
      case 'campaign_pending':
        return Colors.orange;
      case 'donation_new':
        return Colors.blue;
      case 'volunteer_new':
        return Colors.blueGrey;
      default:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<NotificationItem>>(
      future: NotificationDatabase.instance.getNotificationsForUser(username),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text("Belum ada notifikasi."));
        }
        final notifs = snapshot.data!;
        return ListView.separated(
          itemCount: notifs.length,
          separatorBuilder: (context, index) => Divider(height: 1),
          itemBuilder: (context, i) {
            final n = notifs[i];
            return ListTile(
              leading: Icon(
                _iconForType(n.type ?? ''),
                color: _iconColorForType(n.type ?? ''),
              ),
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