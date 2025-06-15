import 'dart:io';
import 'package:flutter/material.dart';
import '../models/volunteer_campaign.dart';
import '../db/volunteer_registration_database.dart';
import '../models/volunteer_registration.dart';
import 'volunteer_registration_screen.dart';
import 'package:intl/intl.dart';

class VolunteerCampaignDetailScreen extends StatefulWidget {
  final VolunteerCampaign campaign;
  final String currentUsername; // Wajib: username user login

  const VolunteerCampaignDetailScreen({
    Key? key,
    required this.campaign,
    required this.currentUsername,
  }) : super(key: key);

  @override
  State<VolunteerCampaignDetailScreen> createState() => _VolunteerCampaignDetailScreenState();
}

class _VolunteerCampaignDetailScreenState extends State<VolunteerCampaignDetailScreen> {
  bool _isJoining = false;
  bool _alreadyJoined = false;

  @override
  void initState() {
    super.initState();
    _checkAlreadyJoined();
  }

  Future<void> _checkAlreadyJoined() async {
    final regs = await VolunteerRegistrationDatabase.instance.getRegistrationsByUser(widget.currentUsername);
    setState(() {
      _alreadyJoined = regs.any((reg) => reg.campaignId == widget.campaign.id);
    });
  }

  Future<void> _handleJoin() async {
    setState(() {
      _isJoining = true;
    });
    final res = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (ctx) => VolunteerRegistrationScreen(
          campaignId: widget.campaign.id!,
          username: widget.currentUsername,
        ),
      ),
    );
    if (res == true) {
      setState(() {
        _alreadyJoined = true;
        _isJoining = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Berhasil mendaftar volunteer!')),
      );
    } else {
      setState(() {
        _isJoining = false;
      });
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