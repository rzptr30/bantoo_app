import 'package:flutter/material.dart';
import '../db/volunteer_registration_database.dart';
import '../models/volunteer_registration.dart';
import '../db/notification_database.dart';
import '../models/notification_item.dart';
// Hapus: import '../db/campaign_database.dart';
import '../db/volunteer_campaign_database.dart';
import '../models/volunteer_campaign.dart';

class VolunteerRegistrationScreen extends StatefulWidget {
  final int campaignId;
  final String username; // username user yang login

  const VolunteerRegistrationScreen({
    super.key,
    required this.campaignId,
    required this.username,
  });

  @override
  State<VolunteerRegistrationScreen> createState() => _VolunteerRegistrationScreenState();
}

class _VolunteerRegistrationScreenState extends State<VolunteerRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();

  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<bool> _alreadyRegistered() async {
    final regs = await VolunteerRegistrationDatabase.instance.getRegistrationsByUser(widget.username);
    return regs.any((reg) => reg.campaignId == widget.campaignId);
  }

  Future<void> _submit() async {
    setState(() {
      _errorMessage = null;
      _isLoading = true;
    });

    if (!(_formKey.currentState?.validate() ?? false)) {
      setState(() => _isLoading = false);
      return;
    }

    if (await _alreadyRegistered()) {
      setState(() {
        _errorMessage = 'Kamu sudah pernah mendaftar sebagai volunteer di campaign ini.';
        _isLoading = false;
      });
      return;
    }

    final reg = VolunteerRegistration(
      campaignId: widget.campaignId,
      user: widget.username,
      name: _nameController.text.trim(),
      phone: _phoneController.text.trim(),
      status: 'approved', // langsung approve
      adminFeedback: null,
      registeredAt: DateTime.now(),
    );

    await VolunteerRegistrationDatabase.instance.insertRegistration(reg);

    // Kirim notifikasi ke user sendiri
    await NotificationDatabase.instance.insertNotification(NotificationItem(
      user: widget.username,
      message: 'Pendaftaran volunteer untuk campaign ${widget.campaignId} telah disetujui secara otomatis.',
      date: DateTime.now(),
      type: 'volunteer_approved',
      relatedId: widget.campaignId.toString(),
    ));

    // Kirim notifikasi ke creator campaign volunteer
    final vCampaign = await VolunteerCampaignDatabase.instance.getCampaignById(widget.campaignId);
    if (vCampaign != null && vCampaign.creator != widget.username) {
      await NotificationDatabase.instance.insertNotification(NotificationItem(
        user: vCampaign.creator,
        message: 'Ada pendaftar volunteer baru untuk campaign "${vCampaign.title}": ${reg.name}.',
        date: DateTime.now(),
        type: 'volunteer_new',
        relatedId: widget.campaignId.toString(),
      ));
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pendaftaran volunteer berhasil dan langsung disetujui!')),
      );
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Volunteer'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(labelText: 'Nama Lengkap'),
                      validator: (val) => val == null || val.trim().isEmpty ? 'Nama wajib diisi' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _phoneController,
                      decoration: const InputDecoration(labelText: 'Nomor HP'),
                      keyboardType: TextInputType.phone,
                      validator: (val) => val == null || val.trim().isEmpty ? 'Nomor HP wajib diisi' : null,
                    ),
                    const SizedBox(height: 24),
                    if (_errorMessage != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12.0),
                        child: Text(
                          _errorMessage!,
                          style: const TextStyle(color: Colors.red),
                        ),
                      ),
                    ElevatedButton(
                      onPressed: _submit,
                      child: const Text('Daftar Volunteer'),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}