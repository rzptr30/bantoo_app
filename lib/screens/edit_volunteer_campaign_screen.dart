import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

import '../models/volunteer_campaign.dart';
import '../db/volunteer_campaign_database.dart';

class EditVolunteerCampaignScreen extends StatefulWidget {
  final VolunteerCampaign campaign;
  const EditVolunteerCampaignScreen({required this.campaign});

  @override
  State<EditVolunteerCampaignScreen> createState() => _EditVolunteerCampaignScreenState();
}

class _EditVolunteerCampaignScreenState extends State<EditVolunteerCampaignScreen> {
  late TextEditingController _judulController;
  late TextEditingController _descController;
  late TextEditingController _lokasiController;
  late TextEditingController _kuotaController;
  // late TextEditingController _biayaController;
  DateTime? _selectedDate;
  File? _selectedImage;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _judulController = TextEditingController(text: widget.campaign.title);
    _descController = TextEditingController(text: widget.campaign.description);
    _lokasiController = TextEditingController(text: widget.campaign.location);
    _kuotaController = TextEditingController(text: widget.campaign.quota);
    // _biayaController = TextEditingController(text: widget.campaign.fee);
    _selectedDate = widget.campaign.eventDate;
    _selectedImage = File(widget.campaign.imagePath);
  }

  Future<void> _pickAndCropImage() async {
    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(source: ImageSource.gallery);
      if (picked != null) {
        final cropped = await ImageCropper().cropImage(
          sourcePath: picked.path,
          aspectRatio: const CropAspectRatio(ratioX: 16, ratioY: 9),
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
      initialDate: _selectedDate ?? now,
      firstDate: now,
      lastDate: now.add(Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _submit() async {
    if (_judulController.text.isEmpty ||
        _descController.text.isEmpty ||
        _lokasiController.text.isEmpty ||
        _kuotaController.text.isEmpty ||
        // _biayaController.text.isEmpty ||
        _selectedDate == null ||
        _selectedImage == null) {
      ScaffoldMessenger.of(this.context).showSnackBar(
        SnackBar(content: Text('Semua field harus diisi!')),
      );
      return;
    }
    setState(() => _isSubmitting = true);

    final updated = widget.campaign.copyWith(
      title: _judulController.text,
      description: _descController.text,
      location: _lokasiController.text,
      quota: _kuotaController.text,
      // fee: _biayaController.text,
      eventDate: _selectedDate!,
      imagePath: _selectedImage!.path,
      status: "pending",         // <-- Set status ke pending
      adminFeedback: null,       // <-- Hapus feedback admin
    );

    await VolunteerCampaignDatabase.instance.update(updated);

    setState(() => _isSubmitting = false);
    ScaffoldMessenger.of(this.context).showSnackBar(
      SnackBar(content: Text('Campaign volunteer berhasil diupdate!')),
    );
    Navigator.pop(this.context, true);
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
        title: Text('Edit Campaign Volunteer'),
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
            SizedBox(height: 16),
            TextField(
              // controller: _biayaController,
              // decoration: InputDecoration(labelText: "Biaya (cth: Gratis)"),
            ),
            SizedBox(height: 32),
            Center(
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _submit,
                child: _isSubmitting
                    ? SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : Text("Simpan Perubahan"),
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