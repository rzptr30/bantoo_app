import 'package:flutter/material.dart';
import '../db/volunteer_db.dart';
import '../models/volunteer.dart';

class VolunteerScreen extends StatefulWidget {
  const VolunteerScreen({Key? key}) : super(key: key);

  @override
  State<VolunteerScreen> createState() => _VolunteerScreenState();
}

class _VolunteerScreenState extends State<VolunteerScreen> {
  List<Volunteer> _volunteers = [];
  int _page = 1;
  final int _perPage = 10;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadVolunteers();
  }

  Future<void> _loadVolunteers() async {
    setState(() => _isLoading = true);
    final data = await VolunteerDB().getVolunteers(
      offset: (_page - 1) * _perPage,
      limit: _perPage,
    );
    setState(() {
      _volunteers = data;
      _isLoading = false;
    });
  }

  void _changePage(int page) {
    setState(() => _page = page);
    _loadVolunteers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEFF3F6),
      appBar: AppBar(
        backgroundColor: const Color(0xFF222E3A),
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "Bantoo Volunteer",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        child: Column(
          children: [
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ListView.separated(
                      itemCount: _volunteers.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, i) {
                        final v = _volunteers[i];
                        return Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          elevation: 2,
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.asset(
                                    v.image,
                                    width: 70,
                                    height: 70,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          const Text(
                                            "Agency: ",
                                            style: TextStyle(fontWeight: FontWeight.w600),
                                          ),
                                          Expanded(
                                            child: Text(
                                              v.agency,
                                              style: const TextStyle(fontWeight: FontWeight.w400),
                                            ),
                                          ),
                                        ],
                                      ),
                                      Row(
                                        children: [
                                          const Text(
                                            "Location: ",
                                            style: TextStyle(fontWeight: FontWeight.w600),
                                          ),
                                          Expanded(
                                            child: Text(
                                              v.location,
                                              style: const TextStyle(fontWeight: FontWeight.w400),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      const Text(
                                        "Description",
                                        style: TextStyle(fontWeight: FontWeight.w600),
                                      ),
                                      Text(
                                        v.description,
                                        maxLines: 3,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 8),
                                      Row(
                                        children: [
                                          const Text(
                                            "Expired date: ",
                                            style: TextStyle(
                                              fontWeight: FontWeight.w600,
                                              fontSize: 13,
                                            ),
                                          ),
                                          Text(
                                            v.expired,
                                            style: const TextStyle(fontSize: 13),
                                          ),
                                        ],
                                      ),
                                      Row(
                                        children: [
                                          const Text(
                                            "Registration Fee: ",
                                            style: TextStyle(
                                              fontWeight: FontWeight.w600,
                                              fontSize: 13,
                                            ),
                                          ),
                                          Text(
                                            v.fee,
                                            style: TextStyle(
                                              fontSize: 13,
                                              color: v.fee == 'Free'
                                                  ? Colors.green
                                                  : Colors.red,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(width: 10),
                                          const Text(
                                            "Applicant quota: ",
                                            style: TextStyle(
                                              fontWeight: FontWeight.w600,
                                              fontSize: 13,
                                            ),
                                          ),
                                          Text(
                                            v.quota.toString(),
                                            style: const TextStyle(fontSize: 13),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      SizedBox(
                                        width: 110,
                                        child: ElevatedButton(
                                          onPressed: () {},
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: const Color(0xFF222E3A),
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                            padding: const EdgeInsets.symmetric(vertical: 8),
                                          ),
                                          child: const Text(
                                            "Join now",
                                            style: TextStyle(fontWeight: FontWeight.bold),
                                          ),
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
                _PageButton(
                  number: 1,
                  isActive: _page == 1,
                  onTap: () => _changePage(1),
                ),
                const SizedBox(width: 8),
                _PageButton(
                  number: 2,
                  isActive: _page == 2,
                  onTap: () => _changePage(2),
                ),
                const SizedBox(width: 8),
                _PageButton(
                  number: 3,
                  isActive: _page == 3,
                  onTap: () => _changePage(3),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Text(
              "Copyright © 2025 Kitabisa. All Rights Reserved",
              style: TextStyle(color: Colors.grey, fontSize: 13),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

class _PageButton extends StatelessWidget {
  final int number;
  final bool isActive;
  final VoidCallback? onTap;

  const _PageButton({
    required this.number,
    this.isActive = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFF222E3A) : Colors.transparent,
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
      ),
    );
  }
}