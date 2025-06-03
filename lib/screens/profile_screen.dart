import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../db/campaign_database.dart';
import 'user_info_screen.dart';
import 'login_screen.dart';
import 'admin_campaign_approval_screen.dart';
import 'user_campaign_archive_screen.dart'; // Tambah ini

class ProfileScreen extends StatefulWidget {
  final String username;
  final String email;
  final String avatarAsset;
  final String tagline;
  final String role;

  const ProfileScreen({
    Key? key,
    required this.username,
    required this.email,
    this.avatarAsset = 'assets/profile_avatar.png',
    this.tagline = "Bantoo's Guardian Angel",
    required this.role,
  }) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    final menus = [
      if (widget.role == "admin")
        {
          'icon': Icons.admin_panel_settings,
          'label': 'ACC Campaign (Admin)',
          'onTap': () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => AdminCampaignApprovalScreen()),
            );
          },
        },
      {
        'icon': Icons.archive,
        'label': 'Arsip Campaign Saya',
        'onTap': () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => UserCampaignArchiveScreen(username: widget.username)),
          );
        },
      },
      {
        'icon': Icons.person,
        'label': 'User Information',
        'onTap': () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => UserInfoScreen(
                username: widget.username,
                email: widget.email,
                avatarAsset: widget.avatarAsset,
              ),
            ),
          );
        },
      },
      {
        'icon': Icons.volunteer_activism,
        'label': 'Volunteer History',
        'onTap': () {},
      },
      {
        'icon': Icons.history,
        'label': 'Transaction History',
        'onTap': () {},
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
          final shouldDelete = await showDialog<bool>(
            context: context,
            builder: (ctx) => AlertDialog(
              title: Text('Konfirmasi'),
              content: Text('Apakah Anda yakin ingin menghapus semua data donasi?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx, false),
                  child: Text('Batal'),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.pop(ctx, true),
                  child: Text('Hapus'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                  ),
                ),
              ],
            ),
          );
          if (shouldDelete == true) {
            await CampaignDatabase.instance.deleteAllCampaigns();
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Semua data donasi berhasil dihapus!')),
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

    return SingleChildScrollView(
      child: Column(
        children: [
          SizedBox(height: 32),
          CircleAvatar(
            backgroundColor: Colors.white,
            radius: 50,
            child: Image.asset(widget.avatarAsset, width: 80),
          ),
          SizedBox(height: 16),
          Text(
            "Hi! ${widget.username}",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22, color: Color(0xFF183B56)),
          ),
          SizedBox(height: 4),
          Text(widget.tagline, style: TextStyle(fontSize: 14, color: Colors.grey[700])),
          SizedBox(height: 32),
          ...menus.map((menu) => Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            child: Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              elevation: 2,
              child: ListTile(
                leading: Icon(menu['icon'] as IconData, color: Colors.black54, size: 28),
                title: Text(menu['label'] as String, style: TextStyle(fontWeight: FontWeight.w500)),
                trailing: Icon(Icons.arrow_forward_ios, size: 18, color: Colors.grey),
                onTap: menu['onTap'] as void Function()?,
              ),
            ),
          )),
        ],
      ),
    );
  }
}