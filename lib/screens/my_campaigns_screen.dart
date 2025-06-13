import 'dart:io';
import 'package:flutter/material.dart';
import '../db/campaign_database.dart';
import '../db/volunteer_campaign_database.dart';
import '../models/campaign.dart';
import '../models/volunteer_campaign.dart';
import 'edit_campaign_screen.dart';
import 'edit_volunteer_campaign_screen.dart';
import 'my_campaign_detail_screen.dart';
import 'my_volunteer_campaign_detail_screen.dart';

class MyCampaignsScreen extends StatefulWidget {
  final String creator;
  const MyCampaignsScreen({required this.creator});

  @override
  State<MyCampaignsScreen> createState() => _MyCampaignsScreenState();
}

class _MyCampaignsScreenState extends State<MyCampaignsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Campaign> _donasiCampaigns = [];
  List<VolunteerCampaign> _volunteerCampaigns = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _fetchMyCampaigns();
  }

  Future<void> _fetchMyCampaigns() async {
    setState(() => _isLoading = true);

    final donasiList = await CampaignDatabase.instance.getCampaignsByCreator(widget.creator);
    final volunteerList = await VolunteerCampaignDatabase.instance.getCampaignsByCreator(widget.creator);

    donasiList.sort((a, b) =>
      (DateTime.tryParse(b.endDate)?.compareTo(DateTime.tryParse(a.endDate) ?? DateTime.now()) ?? 0)
    );
    volunteerList.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    setState(() {
      _donasiCampaigns = donasiList;
      _volunteerCampaigns = volunteerList;
      _isLoading = false;
    });
  }

  void _editDonasi(Campaign campaign) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => EditCampaignScreen(campaign: campaign)),
    );
    if (result == true) {
      await _fetchMyCampaigns();
    }
  }

  void _editVolunteer(VolunteerCampaign campaign) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => EditVolunteerCampaignScreen(campaign: campaign)),
    );
    if (result == true) {
      await _fetchMyCampaigns();
    }
  }

  void _deleteDonasi(Campaign campaign) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("Konfirmasi"),
        content: Text("Hapus campaign donasi \"${campaign.title}\"?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text("Batal")),
          TextButton(onPressed: () => Navigator.pop(context, true), child: Text("Hapus")),
        ],
      ),
    );
    if (confirm == true) {
      await CampaignDatabase.instance.deleteCampaign(campaign.id!);
      await _fetchMyCampaigns();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Campaign donasi dihapus")),
      );
    }
  }

  void _deleteVolunteer(VolunteerCampaign campaign) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("Konfirmasi"),
        content: Text("Hapus campaign volunteer \"${campaign.title}\"?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text("Batal")),
          TextButton(onPressed: () => Navigator.pop(context, true), child: Text("Hapus")),
        ],
      ),
    );
    if (confirm == true) {
      await VolunteerCampaignDatabase.instance.deleteCampaign(campaign.id!);
      await _fetchMyCampaigns();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Campaign volunteer dihapus")),
      );
    }
  }

  Widget _buildStatusChip(String status) {
    Color color;
    String text;
    switch (status) {
      case 'approved':
        color = Colors.green;
        text = 'APPROVED';
        break;
      case 'pending':
        color = Colors.orange;
        text = 'PENDING';
        break;
      case 'rejected':
        color = Colors.red;
        text = 'REJECTED';
        break;
      default:
        color = Colors.grey;
        text = status.toUpperCase();
    }
    return Chip(
      label: Text(text, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      backgroundColor: color,
    );
  }

  Widget _buildDonasiList() {
    if (_isLoading) return Center(child: CircularProgressIndicator());
    if (_donasiCampaigns.isEmpty) {
      return Center(child: Text('Belum ada campaign donasi yang kamu buat.'));
    }
    return ListView.builder(
      itemCount: _donasiCampaigns.length,
      padding: EdgeInsets.all(16),
      itemBuilder: (context, idx) {
        final c = _donasiCampaigns[idx];
        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => MyCampaignDetailScreen(campaign: c),
              ),
            );
          },
          child: Card(
            margin: EdgeInsets.only(bottom: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Align(
                    alignment: Alignment.centerRight,
                    child: _buildStatusChip(c.status),
                  ),
                  SizedBox(height: 8),
                  Text(
                    c.title,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
                  ),
                  SizedBox(height: 4),
                  Text(c.description, maxLines: 2, overflow: TextOverflow.ellipsis),
                  SizedBox(height: 10),
                  Text("Target Donasi: Rp ${c.targetFund}"),
                  Text("Terkumpul: Rp ${c.collectedFund}"),
                  Text("Batas: ${c.endDate}"),
                  if (c.imagePath.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.file(
                          File(c.imagePath),
                          width: double.infinity,
                          height: 80,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  // Tampilkan feedback jika status rejected dan ada adminFeedback
                  if (c.status == "rejected" && c.adminFeedback != null && c.adminFeedback!.trim().isNotEmpty)
                    Container(
                      margin: EdgeInsets.only(top: 12, bottom: 4),
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red[50],
                        border: Border.all(color: Colors.red),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.info_outline, color: Colors.red, size: 20),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              "Campaign ini ditolak oleh admin.\nFeedback: ${c.adminFeedback}",
                              style: TextStyle(color: Colors.red[700], fontStyle: FontStyle.italic),
                            ),
                          ),
                        ],
                      ),
                    ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      if (c.status == "rejected")
                        IconButton(
                          icon: Icon(Icons.edit, color: Colors.blue),
                          tooltip: "Edit",
                          onPressed: () => _editDonasi(c),
                        ),
                      if (c.status == "rejected")
                        IconButton(
                          icon: Icon(Icons.delete, color: Colors.red),
                          tooltip: "Hapus",
                          onPressed: () => _deleteDonasi(c),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildVolunteerList() {
    if (_isLoading) return Center(child: CircularProgressIndicator());
    if (_volunteerCampaigns.isEmpty) {
      return Center(child: Text('Belum ada campaign volunteer yang kamu buat.'));
    }
    return ListView.builder(
      itemCount: _volunteerCampaigns.length,
      padding: EdgeInsets.all(16),
      itemBuilder: (context, idx) {
        final v = _volunteerCampaigns[idx];
        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => MyVolunteerCampaignDetailScreen(
                  campaign: v,
                  currentUsername: widget.creator,
                ),
              ),
            );
          },
          child: Card(
            margin: EdgeInsets.only(bottom: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Align(
                    alignment: Alignment.centerRight,
                    child: _buildStatusChip(v.status),
                  ),
                  SizedBox(height: 8),
                  Text(
                    v.title,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
                  ),
                  SizedBox(height: 4),
                  Text(v.description, maxLines: 2, overflow: TextOverflow.ellipsis),
                  SizedBox(height: 10),
                  Text("Lokasi: ${v.location}"),
                  Text("Tanggal Event: ${_formatDate(v.eventDate)}"),
                  Text("Kuota: ${v.quota}"),
                  Text("Biaya: ${v.fee}"),
                  if (v.imagePath.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.file(
                          File(v.imagePath),
                          width: double.infinity,
                          height: 80,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  if (v.status == "rejected" && v.adminFeedback != null && v.adminFeedback!.trim().isNotEmpty)
                    Container(
                      margin: EdgeInsets.only(top: 12, bottom: 4),
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red[50],
                        border: Border.all(color: Colors.red),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.info_outline, color: Colors.red, size: 20),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              "Campaign ini ditolak oleh admin.\nFeedback: ${v.adminFeedback}",
                              style: TextStyle(color: Colors.red[700], fontStyle: FontStyle.italic),
                            ),
                          ),
                        ],
                      ),
                    ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      if (v.status == "rejected")
                        IconButton(
                          icon: Icon(Icons.edit, color: Colors.blue),
                          tooltip: "Edit",
                          onPressed: () => _editVolunteer(v),
                        ),
                      if (v.status == "rejected")
                        IconButton(
                          icon: Icon(Icons.delete, color: Colors.red),
                          tooltip: "Hapus",
                          onPressed: () => _deleteVolunteer(v),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  String _formatDate(DateTime? dt) {
    if (dt == null) return "-";
    return "${dt.day}/${dt.month}/${dt.year}";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Campaign Saya'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: "Donasi"),
            Tab(text: "Volunteer"),
          ],
        ),
      ),
      backgroundColor: Color(0xFFEFF3F6),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildDonasiList(),
          _buildVolunteerList(),
        ],
      ),
    );
  }
}