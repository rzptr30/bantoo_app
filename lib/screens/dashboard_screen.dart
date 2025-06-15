import 'package:flutter/material.dart';
import 'dart:io';
import 'add_campaign_screen.dart';
import 'dashboard_emergency_section.dart';
import 'profile_screen.dart';
import 'notification_screen.dart';
import '../db/campaign_database.dart';
import '../models/campaign.dart';
import 'admin_campaign_approval_screen.dart';
import 'request_campaign_screen.dart';
import '../widgets/bantoo_campaign_card.dart';
import '../widgets/volunteer_campaign_horizontal_card.dart';
import '../models/volunteer_campaign.dart';
import '../db/volunteer_campaign_database.dart';
import 'campaign_detail_screen.dart';
import 'volunteer_campaign_detail_screen.dart';
// import 'volunteer_screen.dart'; // Sudah tidak dipakai di nav bar
import '../services/reminder_service.dart';

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
    {"icon": Icons.notifications, "label": "Notification"},
    {"icon": Icons.person, "label": "Profile"},
  ];

  String get _appBarTitle {
    if (_selectedIndex == 2) return "Profile";
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
                    builder: (_) => AddCampaignScreen(creator: widget.username),
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
          if (_selectedIndex != 2)
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
                    showCampaignSelectionDialog: _showCampaignSelectionDialog,
                  )
                : _selectedIndex == 1
                    ? NotificationScreen(username: widget.username)
                    : ProfileScreen(
                        username: widget.username,
                        email: '',
                        role: widget.role,
                        avatarAsset: "assets/images/default_avatar.png",
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

class _DashboardHome extends StatefulWidget {
  final String username;
  final String role;
  final GlobalKey<EmergencyBantooSectionState> emergencyKey;
  final Function(BuildContext) showCampaignSelectionDialog;
  const _DashboardHome({
    required this.username,
    required this.emergencyKey,
    required this.role,
    required this.showCampaignSelectionDialog,
  });

  @override
  State<_DashboardHome> createState() => __DashboardHomeState();
}

class __DashboardHomeState extends State<_DashboardHome> {
  late Future<List<Campaign>> _donasiApprovedFuture;
  late Future<List<VolunteerCampaign>> _volunteerApprovedFuture;

  @override
  void initState() {
    super.initState();
    _donasiApprovedFuture = CampaignDatabase.instance.getActiveDonasiCampaigns();
    _volunteerApprovedFuture = VolunteerCampaignDatabase.instance.getActiveOprecVolunteerCampaigns();

    // PANGGIL REMINDER DI SINI (agar tiap user login/dash, volunteer dapat notifikasi event besok)
    ReminderService.sendVolunteerReminders(widget.username);
  }

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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // WELCOME CARD FULL WIDTH
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            margin: EdgeInsets.symmetric(horizontal: 8, vertical: 16),
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: 28, horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Image.asset('assets/logo_bantoo.png', height: 48),                  
                  SizedBox(height: 10),
                  Text(
                    "Welcome To Bantoo!",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
                    textAlign: TextAlign.center,
                  ),
                  Text(
                    widget.username,
                    style: TextStyle(fontSize: 16, color: Colors.blueGrey, fontWeight: FontWeight.w600),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 6),
                  Text(
                    "Sharing together for Bantoo those in need",
                    style: TextStyle(fontSize: 15, color: Colors.grey[600]),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
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
          // if (widget.role == "admin") _pendingCampaignSection(context),
          // EmergencyBantooSection(key: widget.emergencyKey, role: widget.role, username: widget.username),
          // SizedBox(height: 16),

          // EMERGENCY BANTOO SECTION (donasi approved)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: Text(
              "Emergency Bantoo",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            ),
          ),
          FutureBuilder<List<Campaign>>(
            future: _donasiApprovedFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return SizedBox(height: 160, child: Center(child: CircularProgressIndicator()));
              }
              final list = snapshot.data ?? [];
              if (list.isEmpty) {
                return Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text("Tidak ada campaign donasi emergency."),
                );
              }
              return SizedBox(
                height: 210,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  itemCount: list.length,
                  itemBuilder: (context, idx) {
                    final c = list[idx];
                    return BantooCampaignCard(
                      campaign: c,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => CampaignDetailScreen(campaign: c),
                          ),
                        );
                      },
                    );
                  },
                  separatorBuilder: (_, __) => SizedBox(width: 12),
                ),
              );
            },
          ),

          // THE EVENT IS ABOUT TO EXPIRE SECTION (volunteer approved)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: Text(
              "The Event Is About To Expire",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            ),
          ),
          FutureBuilder<List<VolunteerCampaign>>(
            future: _volunteerApprovedFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return SizedBox(height: 190, child: Center(child: CircularProgressIndicator()));
              }
              final list = snapshot.data ?? [];
              if (list.isEmpty) {
                return Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text("Tidak ada campaign volunteer aktif."),
                );
              }
              return SizedBox(
                height: 210,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  itemCount: list.length,
                  itemBuilder: (context, idx) {
                    final v = list[idx];
                    return VolunteerCampaignHorizontalCard(
                      campaign: v,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => VolunteerCampaignDetailScreen(campaign: v),
                          ),
                        );
                      },
                    );
                  },
                  separatorBuilder: (_, __) => SizedBox(width: 12),
                ),
              );
            },
          ),

          // ASK FOR NEW CAMPAIGN
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Ask For New Campaign", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                SizedBox(height: 12),
                GestureDetector(
                  onTap: () => widget.showCampaignSelectionDialog(context),
                  child: BantooCampaignCard(onTap: () => widget.showCampaignSelectionDialog(context)),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 18),
            child: Text(
              "Copyright © 2025 Bantoo. All Rights Reserved",
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ),
        ],
      ),
    );
  }
}