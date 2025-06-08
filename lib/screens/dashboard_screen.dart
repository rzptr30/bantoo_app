import 'package:flutter/material.dart';
import 'add_campaign_screen.dart';
import 'dashboard_emergency_section.dart';
import 'profile_screen.dart';
import 'notification_screen.dart';
import '../db/campaign_database.dart';
import '../models/campaign.dart';
import 'admin_campaign_approval_screen.dart';
import 'request_campaign_screen.dart';
import '../widgets/bantoo_campaign_card.dart';
import '../widgets/volunteer_horizontal_list.dart';
import '../models/volunteer.dart';
import 'volunteer_screen.dart';

class DashboardScreen extends StatefulWidget {
  final String username;
  final String role;
  DashboardScreen({required this.username, required this.role});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;
  final GlobalKey<EmergencyBantooSectionState> _emergencyKey = GlobalKey();

  final List<Map<String, dynamic>> _navItems = [
    {"icon": Icons.home, "label": "Home"},
    {"icon": Icons.favorite, "label": "Volunteer"},
    {"icon": Icons.notifications, "label": "Notification"},
    {"icon": Icons.person, "label": "Profile"},
  ];

  String get _appBarTitle {
    if (_selectedIndex == 3) return "Profile";
    return _selectedIndex == 0 ? "Dashboard" : _navItems[_selectedIndex]['label'];
  }

  void _showCampaignSelectionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Pilih Jenis Campaign'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ElevatedButton.icon(
              icon: Icon(Icons.attach_money),
              label: Text('Donasi'),
              onPressed: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => RequestCampaignScreen(creator: widget.username),
                  ),
                ).then((result) {
                  if (result == true) {
                    _emergencyKey.currentState?.refreshCampaigns();
                  }
                });
              },
            ),
            SizedBox(height: 16),
            ElevatedButton.icon(
              icon: Icon(Icons.volunteer_activism),
              label: Text('Volunteer'),
              onPressed: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => RequestCampaignScreen(creator: widget.username),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFEFF3F6),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Color(0xFFEFF3F6),
        elevation: 0,
        title: Text(
          _appBarTitle,
          style: TextStyle(
            color: Color(0xFF183B56),
            fontWeight: FontWeight.bold,
            fontSize: 28,
          ),
        ),
        actions: [
          if (_selectedIndex != 3)
            Padding(
              padding: const EdgeInsets.only(right: 16.0, top: 8, bottom: 8),
              child: CircleAvatar(
                radius: 22,
                backgroundColor: Colors.white,
                child: Image.asset('assets/dashboard_avatar.png', width: 32),
              ),
            ),
        ],
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: _selectedIndex == 0
                ? _DashboardHome(
                    username: widget.username,
                    emergencyKey: _emergencyKey,
                    role: widget.role,
                  )
                : _selectedIndex == 2
                    ? NotificationScreen(username: widget.username)
                    : _selectedIndex == 3
                        ? ProfileScreen(
                            username: widget.username,
                            email: '',
                            role: widget.role,
                            avatarAsset: "assets/images/default_avatar.png",
                          )
                        : VolunteerScreen(),
          ),
          if (_selectedIndex == 0)
            Positioned(
              left: 0,
              right: 0,
              bottom: 16 + 64,
              child: Center(
                child: BantooCampaignCard(
                  onTap: () {
                    _showCampaignSelectionDialog(context);
                  },
                ),
              ),
            ),
        ],
      ),
      floatingActionButton: null,
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Color(0xFF222E3A),
        selectedItemColor: Color(0xFF222E3A),
        unselectedItemColor: Colors.white,
        currentIndex: _selectedIndex,
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: _navItems.map((item) {
          return BottomNavigationBarItem(
            icon: Container(
              decoration: _selectedIndex == _navItems.indexOf(item)
                  ? BoxDecoration(
                      color: Colors.white, borderRadius: BorderRadius.circular(16))
                  : null,
              padding: EdgeInsets.all(6),
              child: Icon(
                item['icon'],
                color: _selectedIndex == _navItems.indexOf(item)
                    ? Color(0xFF222E3A)
                    : Colors.white,
              ),
            ),
            label: item['label'],
          );
        }).toList(),
      ),
    );
  }
}

class _DashboardHome extends StatelessWidget {
  final String username;
  final String role;
  final GlobalKey<EmergencyBantooSectionState> emergencyKey;
  const _DashboardHome({required this.username, required this.emergencyKey, required this.role});

  Widget _pendingCampaignSection(BuildContext context) {
    return FutureBuilder<List<Campaign>>(
      future: CampaignDatabase.instance.getCampaignsByStatus("pending"),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return SizedBox();
        }
        final pendingCampaigns = snapshot.data!;
        return Card(
          margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  "Campaign Pending Approval",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
              ),
              Divider(),
              ...pendingCampaigns.map((c) => ListTile(
                    title: Text(c.title),
                    subtitle: Text("Oleh: ${c.creator}"),
                    trailing: Icon(Icons.arrow_forward_ios_rounded, size: 16),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => AdminCampaignApprovalScreen()),
                      );
                    },
                  )),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 180),
      child: Column(
        children: [
          Container(
            margin: EdgeInsets.all(16),
            padding: EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                Image.asset('assets/logo_bantoo.png', height: 48),
                SizedBox(height: 8),
                Text("Welcome To Bantoo!", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                Text(
                  username,
                  style: TextStyle(fontSize: 16, color: Colors.blueGrey),
                ),
                SizedBox(height: 6),
                Text(
                  "Sharing together for Bantoo those in need",
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: TextField(
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                hintText: "Search activity",
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          SizedBox(height: 16),
          if (role == "admin") _pendingCampaignSection(context),
          EmergencyBantooSection(key: emergencyKey, role: role, username: username),
          SizedBox(height: 36),
        ],
      ),
    );
  }
}