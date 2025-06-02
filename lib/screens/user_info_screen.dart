import 'package:flutter/material.dart';

class UserInfoScreen extends StatefulWidget {
  final String username;
  final String email;
  final String avatarAsset;

  const UserInfoScreen({
    Key? key,
    required this.username,
    required this.email,
    this.avatarAsset = 'assets/profile_avatar.png',
  }) : super(key: key);

  @override
  State<UserInfoScreen> createState() => _UserInfoScreenState();
}

class _UserInfoScreenState extends State<UserInfoScreen> {
  late TextEditingController _usernameController;
  late TextEditingController _emailController;
  late TextEditingController _passwordController;
  late TextEditingController _phoneController;
  String _country = 'Indonesia';

  @override
  void initState() {
    super.initState();
    _usernameController = TextEditingController(text: widget.username);
    _emailController = TextEditingController(text: widget.email);
    _passwordController = TextEditingController(text: '********');
    _phoneController = TextEditingController(text: '081********48');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFEFF3F6),
      appBar: AppBar(
        backgroundColor: Color(0xFF222E3A),
        elevation: 0,
        centerTitle: true,
        title: Text("User Information", style: TextStyle(fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(24),
        child: Column(
          children: [
            Center(
              child: Column(
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.white,
                    radius: 44,
                    child: Stack(
                      children: [
                        Image.asset(widget.avatarAsset, width: 72),
                        Positioned(
                          right: 0, bottom: 0,
                          child: CircleAvatar(
                            radius: 13,
                            backgroundColor: Colors.white,
                            child: Icon(Icons.edit, size: 16, color: Colors.grey),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 12),
                  Text(
                    "Hi! ${widget.username}",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFF183B56)),
                  ),
                  SizedBox(height: 2),
                  Text("Bantoo's Guardian Angel", style: TextStyle(fontSize: 13, color: Colors.grey[700])),
                ],
              ),
            ),
            SizedBox(height: 24),
            TextField(
              controller: _usernameController,
              decoration: InputDecoration(
                labelText: "Username",
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _emailController,
                    readOnly: true,
                    decoration: InputDecoration(
                      labelText: "Email Address",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                SizedBox(width: 8),
                TextButton(
                  child: Text("Change Email Address"),
                  onPressed: () {
                    // Implement change email logic
                  },
                ),
              ],
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _passwordController,
                    obscureText: true,
                    readOnly: true,
                    decoration: InputDecoration(
                      labelText: "Password",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                SizedBox(width: 8),
                TextButton(
                  child: Text("Change Password"),
                  onPressed: () {
                    // Implement change password logic
                  },
                ),
              ],
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _phoneController,
                    readOnly: true,
                    decoration: InputDecoration(
                      labelText: "Phone Number",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                SizedBox(width: 8),
                TextButton(
                  child: Text("Change Phone Number"),
                  onPressed: () {
                    // Implement change phone logic
                  },
                ),
              ],
            ),
            SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _country,
              items: ['Indonesia', 'Malaysia', 'Singapore', 'Thailand']
                  .map((c) => DropdownMenuItem(child: Text(c), value: c))
                  .toList(),
              onChanged: (val) => setState(() => _country = val!),
              decoration: InputDecoration(
                labelText: "Country",
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                // Implement save logic
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Saved!")),
                );
              },
              child: Text("Save Changes"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF222E3A),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                padding: EdgeInsets.symmetric(vertical: 16, horizontal: 32),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 3,
        backgroundColor: Color(0xFF222E3A),
        selectedItemColor: Color(0xFF222E3A),
        unselectedItemColor: Colors.white,
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          // Implement navigation to other tabs if needed
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.favorite), label: "Volunteer"),
          BottomNavigationBarItem(icon: Icon(Icons.notifications), label: "Notification"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ],
      ),
    );
  }
}