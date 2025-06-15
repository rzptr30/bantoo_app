import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

import '../db/volunteer_campaign_database.dart';
import '../models/volunteer_campaign.dart';
import '../db/notification_database.dart';
import '../models/notification_item.dart';
import '../services/notification_service.dart'; // Tambahan

class RequestCampaignScreen extends StatefulWidget {
  final String creator;
  RequestCampaignScreen({required this.creator});

  @override
  State<RequestCampaignScreen> createState() => _RequestCampaignScreenState();
}

class _RequestCampaignScreenState extends State<RequestCampaignScreen> {
  final _judulController = TextEditingController();
  final _descController = TextEditingController();
  final _lokasiController = TextEditingController();
  final _kuotaController = TextEditingController();
  final _termsController = TextEditingController();
  final _disclaimerController = TextEditingController();
  DateTime? _selectedDate;
  File? _selectedImage;
  DateTime? _registrationStart;
  DateTime? _registrationEnd;
  bool _isSubmitting = false;

  String? _dateValidationError;

  Future<void> _pickAndCropImage() async {
    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(source: ImageSource.gallery);
      if (picked != null) {
        final cropped = await ImageCropper().cropImage(
          sourcePath: picked.path,
          aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
          compressQuality: 90,
          uiSettings: [
            AndroidUiSettings(
              toolbarTitle: 'Crop Gambar',
              hideBottomControls: true,
              lockAspectRatio: true,
            ),
            IOSUiSettings(
              title: 'Crop Gambar',
              aspectRatioLockEnabled: true,
            ),
          ],
        );
        if (cropped != null) {
          final dir = await getApplicationDocumentsDirectory();
          final name = basename(cropped.path);
          final savedImage = await File(cropped.path).copy('${dir.path}/$name');
          setState(() {
            _selectedImage = savedImage;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(this.context).showSnackBar(
          SnackBar(content: Text('Gagal memilih/crop gambar: $e')),
        );
      }
    }
  }

  Future<void> _selectDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: this.context,
      initialDate: now,
      firstDate: now,
      lastDate: now.add(Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        if (_registrationStart != null && _registrationStart!.isAfter(_selectedDate!)) {
          _registrationStart = null;
        }
        if (_registrationEnd != null && _registrationEnd!.isAfter(_selectedDate!)) {
          _registrationEnd = null;
        }
      });
    }
  }

  Future<void> _selectRegistrationStart() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: this.context,
      initialDate: now,
      firstDate: now,
      lastDate: _selectedDate ?? now.add(Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        _registrationStart = picked;
        if (_registrationEnd != null && _registrationEnd!.isBefore(_registrationStart!)) {
          _registrationEnd = null;
        }
      });
    }
  }

  Future<void> _selectRegistrationEnd() async {
    final now = _registrationStart ?? DateTime.now();
    final picked = await showDatePicker(
      context: this.context,
      initialDate: now,
      firstDate: now,
      lastDate: _selectedDate ?? now.add(Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        _registrationEnd = picked;
      });
    }
  }

  bool _validateDates() {
    if (_selectedDate == null || _registrationStart == null || _registrationEnd == null) {
      _dateValidationError = 'Tanggal event, oprec mulai, dan oprec selesai wajib diisi!';
      return false;
    }
    if (_registrationStart!.isAfter(_selectedDate!)) {
      _dateValidationError = 'Tanggal oprec mulai tidak boleh setelah tanggal event!';
      return false;
    }
    if (_registrationEnd!.isAfter(_selectedDate!)) {
      _dateValidationError = 'Tanggal oprec selesai tidak boleh setelah tanggal event!';
      return false;
    }
    if (_registrationStart!.isAfter(_registrationEnd!)) {
      _dateValidationError = 'Tanggal oprec selesai harus setelah tanggal mulai!';
      return false;
    }
    _dateValidationError = null;
    return true;
  }

  void _submit() async {
    if (_judulController.text.isEmpty ||
        _descController.text.isEmpty ||
        _lokasiController.text.isEmpty ||
        _kuotaController.text.isEmpty ||
        _selectedDate == null ||
        _selectedImage == null ||
        _registrationStart == null ||
        _registrationEnd == null ||
        _termsController.text.isEmpty ||
        _disclaimerController.text.isEmpty) {
      ScaffoldMessenger.of(this.context).showSnackBar(
        SnackBar(content: Text('Semua field harus diisi!')),
      );
      return;
    }
    if (!_validateDates()) {
      setState(() {});
      ScaffoldMessenger.of(this.context).showSnackBar(
        SnackBar(content: Text(_dateValidationError!)),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final campaign = VolunteerCampaign(
        title: _judulController.text,
        description: _descController.text,
        location: _lokasiController.text,
        quota: _kuotaController.text,
        fee: "Gratis",
        eventDate: _selectedDate!,
        imagePath: _selectedImage!.path,
        creator: widget.creator,
        status: 'pending',
        createdAt: DateTime.now(),
        registrationStart: _registrationStart!,
        registrationEnd: _registrationEnd!,
        terms: _termsController.text,
        disclaimer: _disclaimerController.text,
      );

      final int campaignId = await VolunteerCampaignDatabase.instance.insert(campaign);

      // Notifikasi ke admin
      await NotificationDatabase.instance.insertNotification(
        NotificationItem(
          user: 'admin',
          message: 'Campaign volunteer baru diajukan: "${campaign.title}" oleh ${widget.creator}',
          date: DateTime.now(),
          type: 'campaign_pending',
          relatedId: campaignId.toString(),
        ),
      );

      // Notifikasi ke creator sendiri
      await NotificationDatabase.instance.insertNotification(
        NotificationItem(
          user: widget.creator,
          message: 'Campaign volunteer "${campaign.title}" telah diajukan dan menunggu review admin.',
          date: DateTime.now(),
          type: 'campaign_pending',
          relatedId: campaignId.toString(),
        ),
      );

      // (Opsional) Push notification ke admin (jika device admin)
      await NotificationService.showNotification(
        id: campaignId,
        title: 'Pengajuan Campaign Baru',
        body: 'Campaign volunteer "${campaign.title}" diajukan oleh ${widget.creator}',
        payload: campaignId.toString(),
      );

      setState(() => _isSubmitting = false);
      ScaffoldMessenger.of(this.context).showSnackBar(
        SnackBar(content: Text('Campaign volunteer berhasil diajukan!')),
      );
      Navigator.pop(this.context, true);
    } catch (e) {
      setState(() => _isSubmitting = false);
      ScaffoldMessenger.of(this.context).showSnackBar(
        SnackBar(content: Text('Terjadi error saat submit: $e')),
      );
    }
  }

  Widget _buildImagePreview() {
    if (_selectedImage != null) {
      if (_selectedImage!.existsSync()) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Image.file(
            _selectedImage!,
            width: 180,
            height: 180,
            fit: BoxFit.cover,
          ),
        );
      } else {
        return Text("File gambar tidak ditemukan", style: TextStyle(color: Colors.red));
      }
    } else {
      return Text("Belum ada gambar", style: TextStyle(color: Colors.grey));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Ajukan Campaign Volunteer'),
      ),
      backgroundColor: Color(0xFFEFF3F6),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Gambar Campaign", style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 12),
            Center(child: _buildImagePreview()),
            SizedBox(height: 12),
            Center(
              child: ElevatedButton.icon(
                onPressed: _pickAndCropImage,
                icon: Icon(Icons.photo),
                label: Text("Pilih Gambar Campaign"),
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
                ),
              ),
            ),
            SizedBox(height: 24),
            TextField(
              controller: _judulController,
              decoration: InputDecoration(labelText: "Judul Campaign"),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _descController,
              decoration: InputDecoration(labelText: "Deskripsi"),
              maxLines: 5,
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Text("Tanggal Event", style: TextStyle(fontSize: 16)),
                Spacer(),
                TextButton(
                  onPressed: _selectDate,
                  child: Text(
                    _selectedDate == null
                        ? "Pilih Tanggal"
                        : "${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Text("Oprec Mulai", style: TextStyle(fontSize: 16)),
                Spacer(),
                TextButton(
                  onPressed: _selectedDate == null ? null : _selectRegistrationStart,
                  child: Text(
                    _registrationStart == null
                        ? "Pilih Tanggal"
                        : "${_registrationStart!.day}/${_registrationStart!.month}/${_registrationStart!.year}",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            Row(
              children: [
                Text("Oprec Selesai", style: TextStyle(fontSize: 16)),
                Spacer(),
                TextButton(
                  onPressed: (_selectedDate == null || _registrationStart == null) ? null : _selectRegistrationEnd,
                  child: Text(
                    _registrationEnd == null
                        ? "Pilih Tanggal"
                        : "${_registrationEnd!.day}/${_registrationEnd!.month}/${_registrationEnd!.year}",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            if (_dateValidationError != null)
              Padding(
                padding: const EdgeInsets.only(top: 8, bottom: 8),
                child: Text(
                  _dateValidationError!,
                  style: TextStyle(color: Colors.red),
                ),
              ),
            SizedBox(height: 16),
            TextField(
              controller: _lokasiController,
              decoration: InputDecoration(labelText: "Lokasi"),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _kuotaController,
              decoration: InputDecoration(labelText: "Kuota Peserta"),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 24),
            Text("Terms & Conditions", style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 6),
            TextField(
              controller: _termsController,
              maxLines: 5,
              decoration: InputDecoration(
                hintText: "Isi Terms & Conditions di sini...",
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 10),
            Text("Disclaimer", style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 6),
            TextField(
              controller: _disclaimerController,
              maxLines: 5,
              decoration: InputDecoration(
                hintText: "Isi Disclaimer di sini...",
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 32),
            Center(
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _submit,
                child: _isSubmitting
                    ? SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : Text("Ajukan Campaign Volunteer"),
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(200, 48),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}