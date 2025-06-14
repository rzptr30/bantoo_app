import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'user_info_screen.dart';
import 'archive_campaign_screen.dart';
import 'transaction_history_screen.dart';
import '../db/campaign_database.dart';
import 'login_screen.dart';
import 'my_campaigns_screen.dart';
import 'admin_campaign_approval_screen.dart';
import 'my_volunteer_history_screen.dart';
import '../db/volunteer_campaign_database.dart';
import '../db/volunteer_registration_database.dart';
import '../db/volunteer_notification_database.dart';
import '../db/notification_database.dart';
import '../db/user_database.dart'; // tambahkan ini
import '../models/user.dart'; // tambahkan ini
import 'dart:io';
  
class ProfileScreen extends StatefulWidget {
  final String username;
  final String email;
  final String role;
  final String avatarAsset;

  const ProfileScreen({
    required this.username,
    required this.email,
    required this.role,
    required this.avatarAsset,
  });

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late List<Map<String, dynamic>> _menuItems;
  User? _user;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final user = await UserDatabase.instance.getUserByUsername(widget.username);
    setState(() {
      _user = user;
      _isLoading = false;
    });
  }

  void _reloadAfterEdit() async {
    await _loadUser();
  }

  @override
  Widget build(BuildContext context) {
    // Siapkan menu setelah user selesai loading
    _menuItems = [
      {
        'icon': Icons.campaign,
        'label': 'Campaign Saya',
        'onTap': () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => MyCampaignsScreen(creator: widget.username)),
        ),
      },
      {
        'icon': Icons.person,
        'label': 'User Information',
        'onTap': () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => UserInfoScreen(
                username: widget.username,
                email: _user?.email ?? widget.email,
                avatarAsset: _user?.avatarAsset ?? widget.avatarAsset,
              ),
            ),
          );
          _reloadAfterEdit();
        },
      },
      {
        'icon': Icons.volunteer_activism,
        'label': 'Volunteer History',
        'onTap': () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => MyVolunteerHistoryScreen(username: widget.username)),
          );
        },
      },
      {
        'icon': Icons.history,
        'label': 'Transaction History',
        'onTap': () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => TransactionHistoryScreen(username: widget.username)),
          );
        },
      },
      {
        'icon': Icons.settings,
        'label': 'Setting',
        'onTap': () {},
      },
      {
        'icon': Icons.delete_forever,
        'label': 'Reset Database Donasi',
        'onTap': () async {
          final confirm = await showDialog(
            context: context,
            builder: (_) => AlertDialog(
              title: Text('Konfirmasi'),
              content: Text('Hapus semua data campaign, donasi, dan doa? Data user TIDAK akan dihapus.'),
              actions: [
                TextButton(onPressed: () => Navigator.pop(context, false), child: Text('Batal')),
                TextButton(onPressed: () => Navigator.pop(context, true), child: Text('Hapus')),
              ],
            ),
          );
          if (confirm == true) {
            await CampaignDatabase.instance.deleteAllCampaignRelated();
            await VolunteerCampaignDatabase.instance.deleteAllCampaigns();
            await VolunteerRegistrationDatabase.instance.deleteAllRegistrations();
            await VolunteerNotificationDatabase.instance.deleteAllNotifications();
            await NotificationDatabase.instance.deleteAllNotifications();
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Semua data campaign berhasil dihapus!\nData user tetap aman.')),
              );
            }
          }
        },
      },
      {
        'icon': Icons.logout,
        'label': 'Logout',
        'onTap': () async {
          final prefs = await SharedPreferences.getInstance();
          await prefs.clear();
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => LoginScreen()),
            (route) => false,
          );
        },
      },
    ];
    if (widget.role == "admin") {
      _menuItems.insert(0, {
        'icon': Icons.verified,
        'label': 'Approval Campaign',
        'onTap': () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => AdminCampaignApprovalScreen()),
          );
        },
      });
      _menuItems.insert(1, {
        'icon': Icons.archive,
        'label': 'Campaign Archive',
        'onTap': () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => ArchiveCampaignScreen()),
          );
        },
      });
    }

    return Scaffold(
      backgroundColor: Color(0xFFEFF3F6),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 48.0, bottom: 24),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 44,
                        backgroundImage: (_user?.avatarAsset != null && _user!.avatarAsset!.isNotEmpty && !_user!.avatarAsset!.contains('assets'))
                            ? FileImage(File(_user!.avatarAsset!))
                            : AssetImage(_user?.avatarAsset ?? widget.avatarAsset) as ImageProvider,
                      ),
                      SizedBox(height: 12),
                      Text(_user?.username ?? widget.username, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
                      Text(_user?.email ?? widget.email, style: TextStyle(color: Colors.blueGrey)),
                      if (widget.role == "admin")
                        Container(
                          margin: EdgeInsets.only(top: 6),
                          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.orange[900],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text('Admin', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.separated(
                    itemCount: _menuItems.length,
                    separatorBuilder: (_, __) => Divider(height: 1),
                    itemBuilder: (context, i) {
                      final item = _menuItems[i];
                      return ListTile(
                        leading: Icon(item['icon'], color: Color(0xFF183B56)),
                        title: Text(item['label']),
                        onTap: item['onTap'],
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
}