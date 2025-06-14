import 'dart:async';
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

class NotificationScreen extends StatefulWidget {
  final String username;
  const NotificationScreen({Key? key, required this.username}) : super(key: key);

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  List<NotificationItem> _notifs = [];
  bool _loading = true;
  Timer? _notifTimer;

  @override
  void initState() {
    super.initState();
    _fetchNotifications();

    // Polling setiap 5 detik agar real-time
    _notifTimer = Timer.periodic(Duration(seconds: 5), (timer) {
      _fetchNotifications();
    });
  }

  @override
  void dispose() {
    _notifTimer?.cancel();
    super.dispose();
  }

  Future<void> _fetchNotifications() async {
    setState(() {
      _loading = true;
    });
    final notifs = await NotificationDatabase.instance.getNotificationsForUser(widget.username);
    setState(() {
      _notifs = notifs;
      _loading = false;
    });
  }

  Future<void> _onNotifTap(BuildContext context, NotificationItem notif) async {
    // ... (isi sama seperti sebelumnya, tidak perlu diubah)
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
                campaignTitle: vCampaign.title ?? '',
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
                currentUsername: widget.username,
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
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_notifs.isEmpty) {
      return const Center(child: Text("Belum ada notifikasi."));
    }
    return RefreshIndicator(
      onRefresh: _fetchNotifications,
      child: ListView.separated(
        itemCount: _notifs.length,
        separatorBuilder: (context, index) => Divider(height: 1),
        itemBuilder: (context, i) {
          final n = _notifs[i];
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
      ),
    );
  }
}