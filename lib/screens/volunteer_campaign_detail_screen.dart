import 'dart:io';
import 'package:flutter/material.dart';
import '../models/volunteer_campaign.dart';
import '../models/volunteer_applicant.dart';
import '../db/volunteer_applicant_database.dart';
import 'package:intl/intl.dart';

class VolunteerCampaignDetailScreen extends StatefulWidget {
  final VolunteerCampaign campaign;
  const VolunteerCampaignDetailScreen({Key? key, required this.campaign}) : super(key: key);

  @override
  State<VolunteerCampaignDetailScreen> createState() => _VolunteerCampaignDetailScreenState();
}

class _VolunteerCampaignDetailScreenState extends State<VolunteerCampaignDetailScreen> {
  bool _isJoining = false;
  bool _alreadyJoined = false;

  // Ganti ini dengan user login sebenarnya
  String currentUserId = "USER_ID_123"; // TODO: replace with actual user ID/username
  String currentUserName = "Nama User"; // TODO: replace with actual user name
  String currentUserEmail = "user@mail.com"; // TODO: replace with actual email
  String currentUserPhone = "0812xxxxxxx"; // TODO: replace with actual phone

  @override
  void initState() {
    super.initState();
    _checkAlreadyJoined();
  }

  Future<void> _checkAlreadyJoined() async {
    final applicant = await VolunteerApplicantDatabase.instance.getApplicant(widget.campaign.id!, currentUserId);
    setState(() {
      _alreadyJoined = applicant != null;
    });
  }

  Future<void> _handleJoin() async {
    setState(() => _isJoining = true);
    try {
      final now = DateTime.now();
      final applicant = VolunteerApplicant(
        campaignId: widget.campaign.id!,
        userId: currentUserId,
        name: currentUserName,
        email: currentUserEmail,
        phone: currentUserPhone,
        appliedAt: now,
        status: 'pending',
      );
      await VolunteerApplicantDatabase.instance.insertApplicant(applicant);

      if (mounted) {
        setState(() {
          _alreadyJoined = true;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Berhasil mendaftar volunteer!")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Gagal mendaftar volunteer: $e")),
      );
    } finally {
      if (mounted) setState(() => _isJoining = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final campaign = widget.campaign;
    final eventDateStr = DateFormat('dd/MM/yyyy').format(campaign.eventDate);
    final regStartStr = DateFormat('dd/MM/yyyy').format(campaign.registrationStart);
    final regEndStr = DateFormat('dd/MM/yyyy').format(campaign.registrationEnd);

    return Scaffold(
      appBar: AppBar(
        title: Text(campaign.title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            if (campaign.imagePath.isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: Image.file(
                  File(campaign.imagePath),
                  height: 180,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
            SizedBox(height: 18),
            Text(campaign.title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
            SizedBox(height: 6),
            Text("Lokasi: ${campaign.location}"),
            Text("Kuota: ${campaign.quota}"),
            Text("Tanggal Event: $eventDateStr"),
            Text("Oprec: $regStartStr - $regEndStr"),
            SizedBox(height: 16),
            Text(campaign.description),
            if (campaign.terms.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 14.0),
                child: Text("Terms & Conditions:\n${campaign.terms}",
                  style: TextStyle(fontWeight: FontWeight.w500, color: Colors.blueGrey[700]),
                ),
              ),
            if (campaign.disclaimer.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 6.0),
                child: Text("Disclaimer:\n${campaign.disclaimer}",
                  style: TextStyle(fontWeight: FontWeight.w500, color: Colors.blueGrey[700]),
                ),
              ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _alreadyJoined || _isJoining ? null : _handleJoin,
              child: _isJoining
                  ? CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    )
                  : Text(_alreadyJoined ? "Sudah Mendaftar" : "Join Now"),
            ),
          ],
        ),
      ),
    );
  }
}