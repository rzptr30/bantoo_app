import 'package:flutter/material.dart';
import '../db/volunteer_registration_database.dart';
import '../db/volunteer_campaign_database.dart';
import '../models/volunteer_registration.dart';
import '../models/volunteer_campaign.dart';
// Import screen detail volunteer campaign di sini!
import 'volunteer_campaign_detail_screen.dart';

class MyVolunteerHistoryScreen extends StatefulWidget {
  final String username;
  const MyVolunteerHistoryScreen({required this.username});

  @override
  State<MyVolunteerHistoryScreen> createState() => _MyVolunteerHistoryScreenState();
}

class _MyVolunteerHistoryScreenState extends State<MyVolunteerHistoryScreen> {
  late Future<List<_RegistrationWithCampaign>> _future;

  @override
  void initState() {
    super.initState();
    _future = _getRegistrationsWithCampaign();
  }

  Future<List<_RegistrationWithCampaign>> _getRegistrationsWithCampaign() async {
    final regs = await VolunteerRegistrationDatabase.instance.getRegistrationsByUser(widget.username);
    List<_RegistrationWithCampaign> result = [];
    for (final reg in regs) {
      final campaign = await VolunteerCampaignDatabase.instance.getCampaignById(reg.campaignId);
      result.add(_RegistrationWithCampaign(reg, campaign));
    }
    // Urutkan dari terbaru
    result.sort((a, b) => b.reg.registeredAt.compareTo(a.reg.registeredAt));
    return result;
  }

  Widget _buildStatusChip(String status) {
    switch (status) {
      case "approved":
        return Chip(
          label: Text("Disetujui"),
          backgroundColor: Colors.green[100],
          labelStyle: TextStyle(color: Colors.green[900]),
        );
      case "pending":
        return Chip(
          label: Text("Menunggu"),
          backgroundColor: Colors.orange[100],
          labelStyle: TextStyle(color: Colors.orange[900]),
        );
      case "rejected":
        return Chip(
          label: Text("Ditolak"),
          backgroundColor: Colors.red[100],
          labelStyle: TextStyle(color: Colors.red[900]),
        );
      default:
        return Chip(label: Text(status));
    }
  }

  String _formatDate(DateTime date) {
    return "${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Riwayat Volunteer Saya')),
      body: FutureBuilder<List<_RegistrationWithCampaign>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final data = snapshot.data ?? [];
          if (data.isEmpty) {
            return const Center(child: Text('Belum ada riwayat volunteer.'));
          }
          return ListView.builder(
            itemCount: data.length,
            itemBuilder: (context, i) {
              final reg = data[i].reg;
              final campaign = data[i].campaign;
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
                child: ListTile(
                  title: Text(campaign?.title ?? "(Judul event tidak tersedia)"),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Tanggal Daftar: ${_formatDate(reg.registeredAt)}'),
                      if (campaign?.eventDate != null)
                        Text('Tanggal Event: ${_formatDate(campaign!.eventDate)}'),
                      _buildStatusChip(reg.status),
                      if (reg.status == "rejected" && reg.adminFeedback != null && reg.adminFeedback!.trim().isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 4.0),
                          child: Text(
                            "Feedback admin: ${reg.adminFeedback}",
                            style: TextStyle(color: Colors.red[700], fontStyle: FontStyle.italic, fontSize: 13),
                          ),
                        ),
                      const SizedBox(height: 6),
                      Text('No HP: ${reg.phone}'),
                      Text('Email: ${reg.email}'),
                      Text('Gender: ${reg.gender}'),
                      Text('Umur: ${reg.umur}'),
                      if (reg.experience.isNotEmpty)
                        Text('Pengalaman: ${reg.experience}'),
                    ],
                  ),
                  // Tambahan: klik menuju detail volunteer campaign
                  onTap: campaign != null
                      ? () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => VolunteerCampaignDetailScreen(
                                campaign: campaign,
                                currentUsername: widget.username,
                                // Tambahkan parameter lain jika diperlukan
                              ),
                            ),
                          );
                        }
                      : null,
                ),
              );
            },
          );
        },
      ),
    );
  }
}

// Helper class untuk menggabungkan pendaftaran dengan campaign-nya
class _RegistrationWithCampaign {
  final VolunteerRegistration reg;
  final VolunteerCampaign? campaign;
  _RegistrationWithCampaign(this.reg, this.campaign);
}