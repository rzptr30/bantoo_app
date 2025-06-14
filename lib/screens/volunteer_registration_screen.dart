import 'package:flutter/material.dart';
import '../db/volunteer_registration_database.dart';
import '../models/volunteer_registration.dart';
import '../db/notification_database.dart';
import '../models/notification_item.dart';
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
  final _emailController = TextEditingController();
  String? _selectedGender;
  final _umurController = TextEditingController();
  final _experienceController = TextEditingController();

  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _umurController.dispose();
    _experienceController.dispose();
    super.dispose();
  }

  Future<bool> _alreadyRegistered() async {
    final regs = await VolunteerRegistrationDatabase.instance.getRegistrationsByUser(widget.username);
    return regs.any((reg) => reg.campaignId == widget.campaignId);
  }

  Future<void> _submitFinal({
    required String name,
    required String phone,
    required String email,
    required String gender,
    required int umur,
    required String experience,
  }) async {
    setState(() {
      _errorMessage = null;
      _isLoading = true;
    });

    final reg = VolunteerRegistration(
      campaignId: widget.campaignId,
      user: widget.username,
      name: name.trim(),
      phone: phone.trim(),
      email: email.trim(),
      gender: gender,
      umur: umur,
      experience: experience.trim(),
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
        message: 'Ada pendaftar volunteer baru untuk campaign "${vCampaign.title}": $name.',
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

  Future<void> _showPreviewAndConfirm() async {
    final name = _nameController.text.trim();
    final phone = _phoneController.text.trim();
    final email = _emailController.text.trim();
    final gender = _selectedGender ?? '';
    final umur = int.tryParse(_umurController.text.trim()) ?? 0;
    final experience = _experienceController.text.trim();

    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Konfirmasi Data Pendaftaran'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Pastikan data berikut sudah benar sebelum submit:'),
              const SizedBox(height: 16),
              Text('Nama Lengkap:', style: TextStyle(fontWeight: FontWeight.bold)),
              Text(name),
              const SizedBox(height: 8),
              Text('Nomor HP:', style: TextStyle(fontWeight: FontWeight.bold)),
              Text(phone),
              const SizedBox(height: 8),
              Text('Email:', style: TextStyle(fontWeight: FontWeight.bold)),
              Text(email),
              const SizedBox(height: 8),
              Text('Jenis Kelamin:', style: TextStyle(fontWeight: FontWeight.bold)),
              Text(gender),
              const SizedBox(height: 8),
              Text('Umur:', style: TextStyle(fontWeight: FontWeight.bold)),
              Text(umur > 0 ? umur.toString() : "-"),
              const SizedBox(height: 8),
              Text('Pengalaman:', style: TextStyle(fontWeight: FontWeight.bold)),
              Text(experience.isEmpty ? '-' : experience),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Edit'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Sudah Benar'),
          ),
        ],
      ),
    );
    if (confirm == true) {
      await _submitFinal(
        name: name,
        phone: phone,
        email: email,
        gender: gender,
        umur: umur,
        experience: experience,
      );
    }
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

    setState(() => _isLoading = false);
    await _showPreviewAndConfirm();
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
                child: ListView(
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
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _emailController,
                      decoration: const InputDecoration(labelText: 'Email'),
                      keyboardType: TextInputType.emailAddress,
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) return 'Email wajib diisi';
                        if (!val.contains('@')) return 'Format email tidak valid';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: _selectedGender,
                      items: ['Laki-laki', 'Perempuan', 'Lainnya']
                          .map((gender) => DropdownMenuItem(
                                value: gender,
                                child: Text(gender),
                              ))
                          .toList(),
                      onChanged: (val) => setState(() => _selectedGender = val),
                      decoration: const InputDecoration(labelText: 'Jenis Kelamin'),
                      validator: (val) => val == null || val.isEmpty ? 'Jenis kelamin wajib dipilih' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _umurController,
                      decoration: const InputDecoration(labelText: 'Umur'),
                      keyboardType: TextInputType.number,
                      validator: (val) {
                        if (val == null || val.isEmpty) return 'Umur wajib diisi';
                        final umur = int.tryParse(val);
                        if (umur == null || umur < 1) return 'Umur harus angka >= 1';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _experienceController,
                      decoration: const InputDecoration(labelText: 'Pengalaman Volunteer (opsional)'),
                      maxLines: 2,
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