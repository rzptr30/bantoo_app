import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'login_screen.dart';
import 'user_info_screen.dart';
import 'user_campaign_archive_screen.dart';
import 'transaction_history_screen.dart';

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

  @override
  void initState() {
    super.initState();
    _menuItems = [
      {
        'icon': Icons.archive,
        'label': 'Campaign Archive',
        'onTap': () {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => UserCampaignArchiveScreen(username: widget.username)),
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
        'onTap': () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => TransactionHistoryScreen(username: widget.username),
            ),
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
        'onTap': () {},
      },
      // Tambahkan item logout di sini
      {
        'icon': Icons.logout,
        'label': 'Logout',
        'onTap': () async {
          final prefs = await SharedPreferences.getInstance();
          await prefs.clear(); // Hapus semua data login
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => LoginScreen()),
            (route) => false,
          );
        },
      },
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Profile")),
      body: ListView.builder(
        itemCount: _menuItems.length,
        itemBuilder: (context, index) {
          return ListTile(
            leading: Icon(_menuItems[index]['icon']),
            title: Text(_menuItems[index]['label']),
            onTap: _menuItems[index]['onTap'],
          );
        },
      ),
    );
  }
}