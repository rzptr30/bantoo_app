import 'dart:async';
import 'dart:io';
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

// Fungsi untuk format waktu relatif
String timeAgo(DateTime date) {
  final now = DateTime.now();
  final diff = now.difference(date);

  if (diff.inSeconds < 60) return 'Baru saja';
  if (diff.inMinutes < 60) return '${diff.inMinutes} menit yang lalu';
  if (diff.inHours < 24) return '${diff.inHours} jam yang lalu';
  if (diff.inDays < 7) return '${diff.inDays} hari yang lalu';
  return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
}

class _NotificationScreenState extends State<NotificationScreen> {
  List<NotificationItem> _notifs = [];
  bool _loading = true;
  Timer? _notifTimer;

  @override
  void initState() {
    super.initState();
    _fetchNotifications();
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

    // Jika username adalah admin, ambil notifikasi untuk admin saja
    final notifs = widget.username == 'admin'
        ? await NotificationDatabase.instance.getNotificationsForUser('admin')
        : await NotificationDatabase.instance.getNotificationsForUser(widget.username);

    setState(() {
      _notifs = notifs;
      _loading = false;
    });
  }

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
      if (widget.username == 'admin') {
        // Admin: ke halaman approval
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AdminCampaignApprovalScreen(),
          ),
        );
      } else {
        // Creator: ke detail campaign sendiri jika ada, fallback ke "Campaign Saya"
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
        }
        Navigator.pushNamed(context, '/my_campaigns');
      }
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

  Widget _statusBadge(String? status) {
    if (status == null) return SizedBox.shrink();
    String label = status.toUpperCase();
    Color color = Colors.orange;
    if (status == "approved") color = Colors.green;
    if (status == "rejected") color = Colors.red;
    return Chip(
      label: Text(label, style: TextStyle(color: color)),
      backgroundColor: color.withOpacity(0.15),
      visualDensity: VisualDensity.compact,
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 0),
    );
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
          final isVolunteerCampaignNotif = n.type == 'campaign_approved' ||
              n.type == 'campaign_rejected' ||
              n.type == 'volunteer_new';
          final campaignId = int.tryParse(n.relatedId ?? '');
          if (isVolunteerCampaignNotif && campaignId != null) {
            return FutureBuilder<VolunteerCampaign?>(
              future: VolunteerCampaignDatabase.instance.getCampaignById(campaignId),
              builder: (context, snap) {
                if (snap.connectionState != ConnectionState.done) {
                  return ListTile(
                    leading: Icon(_iconForType(n.type ?? ''), color: _iconColorForType(n.type ?? '')),
                    title: Text(n.message),
                    subtitle: Text(timeAgo(n.date)),
                    onTap: () => _onNotifTap(context, n),
                  );
                }
                final campaign = snap.data;
                return ListTile(
                  leading: (campaign != null && campaign.imagePath != null && campaign.imagePath!.isNotEmpty)
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.file(
                            File(campaign.imagePath!),
                            width: 48,
                            height: 48,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stack) =>
                                Icon(_iconForType(n.type ?? ''), color: _iconColorForType(n.type ?? '')),
                          ),
                        )
                      : Icon(_iconForType(n.type ?? ''), color: _iconColorForType(n.type ?? '')),
                  title: Text(n.message),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(timeAgo(n.date)),
                      if (campaign != null && campaign.status != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: _statusBadge(campaign.status),
                        ),
                    ],
                  ),
                  onTap: () => _onNotifTap(context, n),
                );
              },
            );
          }
          return ListTile(
            leading: Icon(
              _iconForType(n.type ?? ''),
              color: _iconColorForType(n.type ?? ''),
            ),
            title: Text(n.message),
            subtitle: Text(timeAgo(n.date)),
            onTap: () => _onNotifTap(context, n),
          );
        },
      ),
    );
  }
}