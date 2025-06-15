import 'package:flutter/material.dart';
import '../db/volunteer_registration_database.dart';
import '../models/volunteer_registration.dart';

class VolunteerApplicantListScreen extends StatefulWidget {
  final int campaignId;
  final String campaignTitle;

  const VolunteerApplicantListScreen({
    Key? key,
    required this.campaignId,
    required this.campaignTitle,
  }) : super(key: key);

  @override
  State<VolunteerApplicantListScreen> createState() => _VolunteerApplicantListScreenState();
}

class _VolunteerApplicantListScreenState extends State<VolunteerApplicantListScreen> {
  late Future<List<VolunteerRegistration>> _registrationsFuture;

  @override
  void initState() {
    super.initState();
    _registrationsFuture = VolunteerRegistrationDatabase.instance.getRegistrationsByCampaign(widget.campaignId);
  }

  Future<void> _refresh() async {
    setState(() {
      _registrationsFuture = VolunteerRegistrationDatabase.instance.getRegistrationsByCampaign(widget.campaignId);
    });
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'approved':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      default:
        return Colors.orange;
    }
  }

  String _statusLabel(String status) {
    switch (status) {
      case 'approved':
        return "Disetujui";
      case 'rejected':
        return "Ditolak";
      default:
        return "Menunggu";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Pendaftar Volunteer: ${widget.campaignTitle}"),
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: FutureBuilder<List<VolunteerRegistration>>(
          future: _registrationsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            final regs = snapshot.data ?? [];
            if (regs.isEmpty) {
              return const Center(
                child: Text("Belum ada pendaftar volunteer untuk campaign ini."),
              );
            }
            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: regs.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, i) {
                final a = regs[i];
                return Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                    title: Text(a.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Email: ${a.email}"),
                        Text("No HP: ${a.phone}"),
                        Text("Tanggal Daftar: ${a.registeredAt.day.toString().padLeft(2, '0')}/"
                            "${a.registeredAt.month.toString().padLeft(2, '0')}/${a.registeredAt.year}"),
                        if (a.experience.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 4.0),
                            child: Text("Pengalaman: ${a.experience}", style: const TextStyle(fontStyle: FontStyle.italic)),
                          ),
                        if (a.adminFeedback != null && a.adminFeedback!.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 4.0),
                            child: Text("Feedback Admin: ${a.adminFeedback}", style: const TextStyle(fontStyle: FontStyle.italic)),
                          ),
                      ],
                    ),
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: _statusColor(a.status).withOpacity(0.14),
                        border: Border.all(color: _statusColor(a.status)),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        _statusLabel(a.status),
                        style: TextStyle(
                          color: _statusColor(a.status),
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}