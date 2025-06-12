import 'package:flutter/material.dart';
import '../models/campaign.dart';
import '../models/volunteer_campaign.dart';
import '../db/campaign_database.dart';
import '../db/volunteer_campaign_database.dart';
import 'admin_campaign_detail_screen.dart';

class AdminCampaignDashboardScreen extends StatefulWidget {
  const AdminCampaignDashboardScreen({Key? key}) : super(key: key);

  @override
  State<AdminCampaignDashboardScreen> createState() => _AdminCampaignDashboardScreenState();
}

class _AdminCampaignDashboardScreenState extends State<AdminCampaignDashboardScreen> {
  List<_UnifiedCampaign> _allCampaigns = [];
  String _selectedType = "all"; // all, donasi, volunteer
  String _selectedStatus = "all"; // all, approved, pending, rejected
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchCampaigns();
  }

  Future<void> _fetchCampaigns() async {
    setState(() => _isLoading = true);

    // Fetch all donasi campaigns
    final donasiList = await CampaignDatabase.instance.getAllCampaigns();
    final donasiWrapped = donasiList.map((c) => _UnifiedCampaign.donasi(c)).toList();

    // Fetch all volunteer campaigns
    final volunteerList = await VolunteerCampaignDatabase.instance.getAllCampaigns();
    final volunteerWrapped = volunteerList.map((v) => _UnifiedCampaign.volunteer(v)).toList();

    // Gabungkan dan filter sesuai pilihan
    List<_UnifiedCampaign> all = [];
    if (_selectedType == "all" || _selectedType == "donasi") all.addAll(donasiWrapped);
    if (_selectedType == "all" || _selectedType == "volunteer") all.addAll(volunteerWrapped);

    if (_selectedStatus != "all") {
      all = all.where((c) => c.status == _selectedStatus).toList();
    }

    // Urutkan: volunteer by createdAt, donasi by id descending (karena tidak ada tanggal buat donasi)
    all.sort((a, b) => b.sortKey.compareTo(a.sortKey));

    setState(() {
      _allCampaigns = all;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Dashboard Semua Campaign')),
      body: Column(
        children: [
          // FILTER BAR
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Row(
              children: [
                Expanded(
                  child: DropdownButton<String>(
                    isExpanded: true,
                    value: _selectedType,
                    items: [
                      DropdownMenuItem(value: "all", child: Text("Semua Jenis")),
                      DropdownMenuItem(value: "donasi", child: Text("Donasi")),
                      DropdownMenuItem(value: "volunteer", child: Text("Volunteer")),
                    ],
                    onChanged: (val) {
                      setState(() => _selectedType = val ?? "all");
                      _fetchCampaigns();
                    },
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: DropdownButton<String>(
                    isExpanded: true,
                    value: _selectedStatus,
                    items: [
                      DropdownMenuItem(value: "all", child: Text("Semua Status")),
                      DropdownMenuItem(value: "approved", child: Text("Disetujui")),
                      DropdownMenuItem(value: "pending", child: Text("Menunggu")),
                      DropdownMenuItem(value: "rejected", child: Text("Ditolak")),
                    ],
                    onChanged: (val) {
                      setState(() => _selectedStatus = val ?? "all");
                      _fetchCampaigns();
                    },
                  ),
                ),
              ],
            ),
          ),
          // LIST
          Expanded(
            child: _isLoading
                ? Center(child: CircularProgressIndicator())
                : _allCampaigns.isEmpty
                    ? Center(child: Text("Tidak ada campaign yang ditemukan."))
                    : ListView.builder(
                        itemCount: _allCampaigns.length,
                        itemBuilder: (context, idx) {
                          final c = _allCampaigns[idx];
                          return Card(
                            margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            child: ListTile(
                              leading: Container(
                                width: 8,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: c.isDonasi ? Colors.blue : Colors.orange,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                              ),
                              title: Text(c.title, style: TextStyle(fontWeight: FontWeight.bold)),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("Jenis: ${c.isDonasi ? "Donasi" : "Volunteer"}"),
                                  Text("Status: ${_statusLabel(c.status)}"),
                                  Text("Pembuat: ${c.creator}"),
                                  Text("Tanggal: ${c.campaignDate}"),
                                ],
                              ),
                              trailing: Icon(Icons.chevron_right),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => AdminCampaignDetailScreen(
                                      campaign: c.isDonasi ? c.donasi : c.volunteer,
                                      isDonasi: c.isDonasi,
                                    ),
                                  ),
                                );
                              },
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime? dt) {
    if (dt == null) return "-";
    return "${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}";
  }

  String _statusLabel(String status) {
    switch (status) {
      case "approved": return "Disetujui";
      case "pending": return "Menunggu";
      case "rejected": return "Ditolak";
      default: return status;
    }
  }
}

/// Helper class: untuk gabung donasi & volunteer jadi satu list
class _UnifiedCampaign {
  final Campaign? donasi;
  final VolunteerCampaign? volunteer;

  _UnifiedCampaign.donasi(this.donasi) : volunteer = null;
  _UnifiedCampaign.volunteer(this.volunteer) : donasi = null;

  bool get isDonasi => donasi != null;
  bool get isVolunteer => volunteer != null;
  String get title => isDonasi ? donasi!.title : volunteer!.title;
  String get status => isDonasi ? donasi!.status : volunteer!.status;
  String get creator => isDonasi ? donasi!.creator : volunteer!.creator;
  // Tanggal: untuk donasi pakai endDate (String), untuk volunteer pakai createdAt (DateTime)
  String get campaignDate => isDonasi
      ? donasi!.endDate
      : _formatDate(volunteer!.createdAt);

  // Untuk sorting: volunteer pakai createdAt, donasi pakai id (descending)
  Comparable get sortKey => isDonasi ? (donasi!.id ?? 0) : volunteer!.createdAt;

  String _formatDate(DateTime? dt) {
    if (dt == null) return "-";
    return "${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}";
  }
}