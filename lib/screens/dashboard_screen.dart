import 'package:flutter/material.dart';

class DashboardScreen extends StatefulWidget {
  final String username;
  DashboardScreen({required this.username});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;

  final List<Map<String, dynamic>> _navItems = [
    {"icon": Icons.home, "label": "Home"},
    {"icon": Icons.favorite, "label": "Volunteer"},
    {"icon": Icons.notifications, "label": "Notification"},
    {"icon": Icons.person, "label": "Profile"},
  ];

  String get _appBarTitle {
    // Jika di tab Profile, judul "Profile", lainnya "Dashboard"
    return _selectedIndex == 3 ? "Profile" : "Dashboard";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFEFF3F6),
      appBar: AppBar(
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
      body: _selectedIndex == 0
          ? _DashboardHome(username: widget.username)
          : Center(child: Text(_navItems[_selectedIndex]['label'] + " Page")),
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
  const _DashboardHome({required this.username});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          // HEADER
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
          // SEARCH BAR
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
          // MOCKUP CONTENT, SILAKAN ISI SESUAI FITUR NANTI
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              "Contoh konten dashboard di sini.\nSilakan tambahkan menu, card, dsb sesuai gambar.",
              style: TextStyle(color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(height: 36),
        ],
      ),
    );
  }
}