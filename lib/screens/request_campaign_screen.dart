import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

import '../db/volunteer_campaign_database.dart';
import '../models/volunteer_campaign.dart';

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
  final _biayaController = TextEditingController();
  DateTime? _selectedDate;
  File? _selectedImage;
  bool _isSubmitting = false;

  final String _terms = '''
- Mendaftar langsung melalui aplikasi ini
- Kuota terbatas, pendaftaran ditutup setelah kuota terpenuhi
- Peserta wajib hadir tepat waktu dan mengikuti seluruh rangkaian kegiatan
- Wajib menjaga etika dan tidak menyalahgunakan informasi pribadi peserta lain
- Mengisi seluruh persyaratan dari panitia selama acara berlangsung
''';

  final String _disclaimer = '''
- Selama kegiatan akan dilakukan dokumentasi (foto & video)
- Dokumentasi menjadi milik panitia dan digunakan untuk publikasi
- Dengan mendaftar melalui aplikasi, peserta menyetujui seluruh syarat & ketentuan
- Panitia tidak bertanggung jawab atas kehilangan/penyebaran data pribadi antar peserta
- Pastikan data yang kamu input di aplikasi benar dan valid
''';

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
      initialDate: now,
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
        _biayaController.text.isEmpty ||
        _selectedDate == null ||
        _selectedImage == null) {
      ScaffoldMessenger.of(this.context).showSnackBar(
        SnackBar(content: Text('Semua field harus diisi!')),
      );
      return;
    }
    setState(() => _isSubmitting = true);

    final campaign = VolunteerCampaign(
      title: _judulController.text,
      description: _descController.text,
      location: _lokasiController.text,
      quota: _kuotaController.text,
      fee: _biayaController.text,
      eventDate: _selectedDate!,
      imagePath: _selectedImage!.path,
      creator: widget.creator,
      status: 'pending',
      createdAt: DateTime.now(),
    );

    await VolunteerCampaignDatabase.instance.insert(campaign);

    setState(() => _isSubmitting = false);
    ScaffoldMessenger.of(this.context).showSnackBar(
      SnackBar(content: Text('Campaign volunteer berhasil diajukan!')),
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
        title: Text('Ajukan Campaign Volunteer'),
      ),
      backgroundColor: Color(0xFFEFF3F6),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Gambar Campaign
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
            // Judul Campaign
            TextField(
              controller: _judulController,
              decoration: InputDecoration(labelText: "Judul Campaign"),
            ),
            SizedBox(height: 16),
            // Deskripsi
            TextField(
              controller: _descController,
              decoration: InputDecoration(labelText: "Deskripsi"),
              maxLines: 5,
            ),
            SizedBox(height: 16),
            // Tanggal Event
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
            // Lokasi
            TextField(
              controller: _lokasiController,
              decoration: InputDecoration(labelText: "Lokasi"),
            ),
            SizedBox(height: 16),
            // Kuota
            TextField(
              controller: _kuotaController,
              decoration: InputDecoration(labelText: "Kuota Peserta"),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 16),
            // Biaya
            TextField(
              controller: _biayaController,
              decoration: InputDecoration(labelText: "Biaya (cth: Gratis)"),
            ),
            SizedBox(height: 24),
            // Terms & Disclaimer
            Text("Terms & Conditions", style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 6),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Text(_terms, style: TextStyle(fontSize: 13, color: Colors.black87)),
            ),
            SizedBox(height: 10),
            Text("Disclaimer", style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 6),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Text(_disclaimer, style: TextStyle(fontSize: 13, color: Colors.black87)),
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