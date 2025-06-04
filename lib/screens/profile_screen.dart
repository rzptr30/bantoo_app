import 'package:flutter/material.dart';
import 'admin_campaign_approval_screen.dart';
import 'user_campaign_archive_screen.dart';
import 'user_info_screen.dart';

class ProfileScreen extends StatefulWidget {
  final String username;
  final String email;
  final String role;
  final String avatarAsset;
  const ProfileScreen(
      {Key? key,
      required this.username,
      required this.email,
      required this.role,
      required this.avatarAsset})
      : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> items = [
      if (widget.role == "admin")
        {
          'icon': Icons.check,
          'label': 'ACC Campaign (Admin)',
          'onTap': () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => AdminCampaignApprovalScreen()),
            );
          },
        },
      if (widget.role != "admin")
        {
          'icon': Icons.archive,
          'label': 'Arsip Campaign Saya',
          'onTap': () {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) =>
                      UserCampaignArchiveScreen(username: widget.username)),
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
        'onTap': () {},
      },
    ];

    return Scaffold(
      appBar: AppBar(title: Text("Profile")),
      body: ListView.builder(
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];
          return ListTile(
            leading: Icon(item['icon']),
            title: Text(item['label']),
            onTap: item['onTap'],
          );
        },
      ),
    );
  }
}