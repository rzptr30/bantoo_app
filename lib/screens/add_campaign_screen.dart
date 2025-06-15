import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

import '../db/campaign_database.dart';
import '../models/campaign.dart';
import '../db/notification_database.dart';
import '../models/notification_item.dart';

class AddCampaignScreen extends StatefulWidget {
  final String creator;
  const AddCampaignScreen({Key? key, required this.creator}) : super(key: key);

  @override
  State<AddCampaignScreen> createState() => _AddCampaignScreenState();
}

class _AddCampaignScreenState extends State<AddCampaignScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _targetController = TextEditingController();
  DateTime? _endDate;
  File? _imageFile;

  String? _errorFeedback; // <-- untuk feedback error custom

  Future<void> _pickAndCropImage() async {
    try {
      final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
      if (picked != null) {
        final cropped = await ImageCropper().cropImage(
          sourcePath: picked.path,
          aspectRatio: const CropAspectRatio(ratioX: 16, ratioY: 9),
          uiSettings: [
            AndroidUiSettings(
              toolbarTitle: 'Crop Gambar',
              hideBottomControls: true,
              lockAspectRatio: true, // lock agar pasti 16:9
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
            _imageFile = savedImage;
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

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(Duration(days: 7)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        _endDate = picked;
      });
    }
  }

  Future<void> _saveCampaign() async {
    setState(() {
      _errorFeedback = null;
    });

    if (!_formKey.currentState!.validate()) return;

    if (_imageFile == null) {
      setState(() {
        _errorFeedback = "Silakan pilih gambar terlebih dahulu!";
      });
      ScaffoldMessenger.of(this.context).showSnackBar(
        SnackBar(content: Text('Silakan pilih gambar terlebih dahulu!')),
      );
      return;
    }
    if (_endDate == null) {
      setState(() {
        _errorFeedback = "Silakan pilih tanggal selesai terlebih dahulu!";
      });
      ScaffoldMessenger.of(this.context).showSnackBar(
        SnackBar(content: Text('Silakan pilih tanggal selesai terlebih dahulu!')),
      );
      return;
    }

    final campaign = Campaign(
      title: _titleController.text,
      description: _descController.text,
      targetFund: int.parse(_targetController.text),
      collectedFund: 0,
      endDate: _endDate!.toIso8601String(),
      imagePath: _imageFile!.path,
      status: "pending",
      creator: widget.creator,
    );
    // Simpan dan dapatkan id campaign baru
    final int campaignId = await CampaignDatabase.instance.insertCampaign(campaign);

    // === Tambahkan notifikasi ke admin ===
    await NotificationDatabase.instance.insertNotification(
      NotificationItem(
        user: 'admin',
        message: 'Campaign donasi baru diajukan: "${campaign.title}" oleh ${widget.creator}',
        date: DateTime.now(),
        type: 'campaign_pending',
        relatedId: campaignId.toString(),
      ),
    );

    ScaffoldMessenger.of(this.context).showSnackBar(
      SnackBar(content: Text('Campaign berhasil diajukan! Menunggu ACC Admin.'))
    );
    Navigator.pop(this.context, true);
  }

  Widget _buildImagePreview() {
    if (_imageFile != null) {
      // Pastikan file memang ada
      if (_imageFile!.existsSync()) {
        return AspectRatio(
          aspectRatio: 16 / 9,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.file(_imageFile!, fit: BoxFit.cover),
          ),
        );
      } else {
        return Text("File gambar tidak ditemukan", style: TextStyle(color: Colors.red));
      }
    } else {
      return Text("Belum ada gambar");
    }
  }

  Widget _buildErrorFeedback() {
    if (_errorFeedback != null) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 10.0),
        child: Text(
          _errorFeedback!,
          style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
        ),
      );
    }
    return SizedBox.shrink();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Ajukan Campaign Baru")),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(labelText: "Judul Campaign"),
                validator: (v) => v == null || v.isEmpty ? "Judul tidak boleh kosong" : null,
              ),
              SizedBox(height: 12),
              TextFormField(
                controller: _descController,
                decoration: InputDecoration(labelText: "Deskripsi"),
                maxLines: 3,
                validator: (v) => v == null || v.isEmpty ? "Deskripsi tidak boleh kosong" : null,
              ),
              SizedBox(height: 12),
              TextFormField(
                controller: _targetController,
                decoration: InputDecoration(labelText: "Target Donasi (Rp)"),
                keyboardType: TextInputType.number,
                validator: (v) => v == null || v.isEmpty ? "Target tidak boleh kosong" : null,
              ),
              SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: Text(_endDate != null
                        ? "Tanggal selesai: ${_endDate!.day.toString().padLeft(2, '0')}/${_endDate!.month.toString().padLeft(2, '0')}/${_endDate!.year}"
                        : "Pilih tanggal selesai"),
                  ),
                  TextButton(
                    onPressed: () => _selectDate(context),
                    child: Text("Pilih Tanggal"),
                  ),
                ],
              ),
              SizedBox(height: 12),
              _buildImagePreview(),
              SizedBox(height: 8),
              ElevatedButton.icon(
                onPressed: _pickAndCropImage,
                icon: Icon(Icons.photo),
                label: Text("Pilih & Crop Gambar (16:9)"),
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
                ),
              ),
              SizedBox(height: 20),
              _buildErrorFeedback(),
              ElevatedButton(
                onPressed: _saveCampaign,
                child: Text("Ajukan Campaign"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}