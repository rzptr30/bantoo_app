import 'package:flutter/material.dart';

class VolunteerScreen extends StatelessWidget {
  const VolunteerScreen({Key? key}) : super(key: key);

  // Dummy data volunteer
  final List<Map<String, String>> _volunteers = const [
    {
      'image': 'assets/volunteer_1.png', // Ganti dengan asset gambar asli
      'agency': 'YATC Indonesia',
      'location': 'Yogyakarta, Jawa Tengah',
      'description': 'One day, Thousand Smiles (OTS) adalah projek kemanusiaan ...',
      'expired': '08 Januari 2025',
      'fee': 'Free',
      'quota': '50',
    },
    {
      'image': 'assets/volunteer_1.png',
      'agency': 'YATC Indonesia',
      'location': 'Yogyakarta, Jawa Tengah',
      'description': 'One day, Thousand Smiles (OTS) adalah projek kemanusiaan ...',
      'expired': '08 Januari 2025',
      'fee': 'Paid',
      'quota': '50',
    },
    // Tambah data lain jika mau
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFEFF3F6),
      appBar: AppBar(
        backgroundColor: Color(0xFF222E3A),
        elevation: 0,
        centerTitle: true,
        title: Text("Bantoo Volunteer", style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        child: Column(
          children: [
            Expanded(
              child: ListView.separated(
                itemCount: _volunteers.length,
                separatorBuilder: (_, __) => SizedBox(height: 12),
                itemBuilder: (context, i) {
                  final v = _volunteers[i];
                  return Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    elevation: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.asset(
                              v['image']!,
                              width: 70,
                              height: 70,
                              fit: BoxFit.cover,
                            ),
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text("Agency: ", style: TextStyle(fontWeight: FontWeight.w600)),
                                    Expanded(child: Text(v['agency']!, style: TextStyle(fontWeight: FontWeight.w400))),
                                  ],
                                ),
                                Row(
                                  children: [
                                    Text("Location: ", style: TextStyle(fontWeight: FontWeight.w600)),
                                    Expanded(child: Text(v['location']!, style: TextStyle(fontWeight: FontWeight.w400))),
                                  ],
                                ),
                                SizedBox(height: 4),
                                Text("Description", style: TextStyle(fontWeight: FontWeight.w600)),
                                Text(v['description']!, maxLines: 3, overflow: TextOverflow.ellipsis),
                                SizedBox(height: 8),
                                Row(
                                  children: [
                                    Text("Expired date: ", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                                    Text(v['expired']!, style: TextStyle(fontSize: 13)),
                                  ],
                                ),
                                Row(
                                  children: [
                                    Text("Registration Fee: ", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                                    Text(
                                      v['fee']!,
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: v['fee'] == 'Free' ? Colors.green : Colors.red,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    SizedBox(width: 10),
                                    Text("Applicant quota: ", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                                    Text(v['quota']!, style: TextStyle(fontSize: 13)),
                                  ],
                                ),
                                SizedBox(height: 8),
                                SizedBox(
                                  width: 110,
                                  child: ElevatedButton(
                                    onPressed: () {},
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Color(0xFF222E3A),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                      padding: EdgeInsets.symmetric(vertical: 8),
                                    ),
                                    child: Text("Join now", style: TextStyle(fontWeight: FontWeight.bold)),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            // Pagination
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _PageButton(number: 1, isActive: true),
                SizedBox(width: 8),
                _PageButton(number: 2),
                SizedBox(width: 8),
                _PageButton(number: 3),
              ],
            ),
            SizedBox(height: 12),
            Text(
              "Copyright © 2025 Kitabisa. All Rights Reserved",
              style: TextStyle(color: Colors.grey, fontSize: 13),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8),
          ],
        ),
      ),
      // BottomNavigationBar akan otomatis muncul jika ini dipakai di DashboardScreen/tab bar
    );
  }
}

class _PageButton extends StatelessWidget {
  final int number;
  final bool isActive;
  const _PageButton({required this.number, this.isActive = false});
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: isActive ? Color(0xFF222E3A) : Colors.transparent,
        border: Border.all(color: Colors.grey.shade400),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: Text(
          number.toString(),
          style: TextStyle(
            color: isActive ? Colors.white : Colors.black87,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}