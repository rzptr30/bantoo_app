import 'dart:io';
import 'package:flutter/material.dart';
import '../db/campaign_database.dart';
import '../db/volunteer_campaign_database.dart';
import '../models/campaign.dart';
import '../models/volunteer_campaign.dart';

class AdminCampaignApprovalScreen extends StatefulWidget {
  @override
  State<AdminCampaignApprovalScreen> createState() => _AdminCampaignApprovalScreenState();
}

class _AdminCampaignApprovalScreenState extends State<AdminCampaignApprovalScreen> {
  List<_PendingCampaign> _allPendingCampaigns = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchPendingCampaigns();
  }

  Future<void> _fetchPendingCampaigns() async {
    setState(() => _isLoading = true);

    // Fetch pending donasi campaigns
    final donasiList = await CampaignDatabase.instance.getPendingCampaigns();
    final donasiWrapped = donasiList.map((c) => _PendingCampaign.donasi(c)).toList();

    // Fetch pending volunteer campaigns
    final volunteerList = await VolunteerCampaignDatabase.instance.getPendingCampaigns();
    final volunteerWrapped = volunteerList.map((v) => _PendingCampaign.volunteer(v)).toList();

    // Gabungkan dan urutkan berdasarkan tanggal dibuat
    final all = [...donasiWrapped, ...volunteerWrapped];
    all.sort((a, b) => b.createdAt.compareTo(a.createdAt)); // terbaru di atas

    setState(() {
      _allPendingCampaigns = all;
      _isLoading = false;
    });
  }

  Future<void> _handleApproval(_PendingCampaign campaign, bool isApprove) async {
    if (campaign.isDonasi) {
      await CampaignDatabase.instance.updateStatus(campaign.donasi!.id!, isApprove ? 'approved' : 'rejected');
    } else {
      await VolunteerCampaignDatabase.instance.updateStatus(campaign.volunteer!.id!, isApprove ? 'approved' : 'rejected');
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(isApprove ? "Campaign di-approve!" : "Campaign di-reject!")),
    );
    await _fetchPendingCampaigns();
  }

  void _showDetailDialog(_PendingCampaign campaign) {
    showDialog(
      context: context,
      builder: (context) {
        if (campaign.isDonasi) {
          final Campaign data = campaign.donasi!;
          return Dialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: SingleChildScrollView(
              padding: EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Align(
                    alignment: Alignment.centerRight,
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text('Donasi', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  SizedBox(height: 12),
                  Text(data.title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
                  SizedBox(height: 8),
                  Text("Oleh: ${data.creator}", style: TextStyle(fontSize: 13, color: Colors.grey[700])),
                  SizedBox(height: 16),
                  if (data.imagePath.isNotEmpty)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.file(
                        File(data.imagePath),
                        width: double.infinity,
                        height: 180,
                        fit: BoxFit.cover,
                      ),
                    ),
                  SizedBox(height: 14),
                  Text(data.description),
                  SizedBox(height: 14),
                  Divider(),
                  Text('Target Donasi: Rp ${data.targetFund}'),
                  SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton.icon(
                        icon: Icon(Icons.close, color: Colors.red),
                        label: Text('Reject', style: TextStyle(color: Colors.red)),
                        onPressed: () {
                          Navigator.pop(context);
                          _handleApproval(campaign, false);
                        },
                      ),
                      SizedBox(width: 8),
                      ElevatedButton.icon(
                        icon: Icon(Icons.check, color: Colors.white),
                        label: Text('Approve'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                          _handleApproval(campaign, true);
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        } else {
          final VolunteerCampaign data = campaign.volunteer!;
          return Dialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: SingleChildScrollView(
              padding: EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Align(
                    alignment: Alignment.centerRight,
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.orange,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text('Volunteer', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  SizedBox(height: 12),
                  Text(data.title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
                  SizedBox(height: 8),
                  Text("Oleh: ${data.creator}  |  ${_formatDate(data.createdAt)}", style: TextStyle(fontSize: 13, color: Colors.grey[700])),
                  SizedBox(height: 16),
                  if (data.imagePath.isNotEmpty)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.file(
                        File(data.imagePath),
                        width: double.infinity,
                        height: 180,
                        fit: BoxFit.cover,
                      ),
                    ),
                  SizedBox(height: 14),
                  Text(data.description),
                  SizedBox(height: 14),
                  Divider(),
                  Text('Lokasi: ${data.location}'),
                  Text('Tanggal: ${_formatDate(data.eventDate)}'),
                  Text('Kuota: ${data.quota}'),
                  Text('Biaya: ${data.fee}'),
                  SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton.icon(
                        icon: Icon(Icons.close, color: Colors.red),
                        label: Text('Reject', style: TextStyle(color: Colors.red)),
                        onPressed: () {
                          Navigator.pop(context);
                          _handleApproval(campaign, false);
                        },
                      ),
                      SizedBox(width: 8),
                      ElevatedButton.icon(
                        icon: Icon(Icons.check, color: Colors.white),
                        label: Text('Approve'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                          _handleApproval(campaign, true);
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Approval Campaign'),
      ),
      backgroundColor: Color(0xFFEFF3F6),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _allPendingCampaigns.isEmpty
              ? Center(child: Text('Tidak ada campaign yang perlu di-approve.'))
              : ListView.builder(
                  padding: EdgeInsets.all(16),
                  itemCount: _allPendingCampaigns.length,
                  itemBuilder: (context, idx) {
                    final campaign = _allPendingCampaigns[idx];
                    if (campaign.isDonasi) {
                      final Campaign c = campaign.donasi!;
                      return _buildCard(
                        labelColor: Colors.blue,
                        label: "Donasi",
                        title: c.title,
                        creator: c.creator,
                        date: null,
                        description: c.description,
                        imagePath: c.imagePath,
                        extra: "Target Donasi: Rp ${c.targetFund}",
                        onDetail: () => _showDetailDialog(campaign),
                        onReject: () => _handleApproval(campaign, false),
                        onApprove: () => _handleApproval(campaign, true),
                      );
                    } else {
                      final VolunteerCampaign v = campaign.volunteer!;
                      return _buildCard(
                        labelColor: Colors.orange,
                        label: "Volunteer",
                        title: v.title,
                        creator: v.creator,
                        date: v.createdAt,
                        description: v.description,
                        imagePath: v.imagePath,
                        extra: "Lokasi: ${v.location}, Kuota: ${v.quota}, Biaya: ${v.fee}",
                        onDetail: () => _showDetailDialog(campaign),
                        onReject: () => _handleApproval(campaign, false),
                        onApprove: () => _handleApproval(campaign, true),
                      );
                    }
                  },
                ),
    );
  }

  Widget _buildCard({
    required Color labelColor,
    required String label,
    required String title,
    required String creator,
    DateTime? date,
    required String description,
    required String imagePath,
    required String extra,
    required VoidCallback onDetail,
    required VoidCallback onReject,
    required VoidCallback onApprove,
  }) {
    return Card(
      margin: EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: labelColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(label, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
            SizedBox(height: 6),
            Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            SizedBox(height: 6),
            Text(
              "Oleh: $creator${date != null ? ' | ${_formatDate(date)}' : ''}",
              style: TextStyle(fontSize: 13, color: Colors.grey[700]),
            ),
            SizedBox(height: 8),
            Text(
              description,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            if (imagePath.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.file(
                    File(imagePath),
                    width: double.infinity,
                    height: 80,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            Text(extra),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: onDetail,
                  child: Text("Lihat Detail"),
                ),
                SizedBox(width: 8),
                TextButton.icon(
                  icon: Icon(Icons.close, color: Colors.red),
                  label: Text('Reject', style: TextStyle(color: Colors.red)),
                  onPressed: onReject,
                ),
                SizedBox(width: 8),
                ElevatedButton.icon(
                  icon: Icon(Icons.check, color: Colors.white),
                  label: Text('Approve'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: onApprove,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime? dt) {
    if (dt == null) return "-";
    return "${dt.day}/${dt.month}/${dt.year}";
  }
}

/// Helper class: membungkus campaign donasi/volunteer jadi satu tipe
class _PendingCampaign {
  final Campaign? donasi;
  final VolunteerCampaign? volunteer;

  _PendingCampaign.donasi(this.donasi)
      : volunteer = null;
  _PendingCampaign.volunteer(this.volunteer)
      : donasi = null;

  bool get isDonasi => donasi != null;
  bool get isVolunteer => volunteer != null;

  DateTime get createdAt => isDonasi
      ? DateTime.now()
      : volunteer!.createdAt;
}