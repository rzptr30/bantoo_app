import 'package:flutter/material.dart';
import 'user_info_screen.dart';

class ProfileScreen extends StatelessWidget {
  final String username;
  final String email;
  final String avatarAsset;
  final String tagline;

  const ProfileScreen({
    Key? key,
    required this.username,
    required this.email,
    this.avatarAsset = 'assets/profile_avatar.png',
    this.tagline = "Bantoo's Guardian Angel",
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final menus = [
      {
        'icon': Icons.person,
        'label': 'User Information',
        'onTap': () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => UserInfoScreen(
                username: username,
                email: email,
                avatarAsset: avatarAsset,
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
    ];

    return SingleChildScrollView(
      child: Column(
        children: [
          SizedBox(height: 32),
          CircleAvatar(
            backgroundColor: Colors.white,
            radius: 50,
            child: Image.asset(avatarAsset, width: 80),
          ),
          SizedBox(height: 16),
          Text(
            "Hi! $username",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22, color: Color(0xFF183B56)),
          ),
          SizedBox(height: 4),
          Text(tagline, style: TextStyle(fontSize: 14, color: Colors.grey[700])),
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