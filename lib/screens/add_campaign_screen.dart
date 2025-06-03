import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

import '../db/campaign_database.dart';
import '../models/campaign.dart';

class AddCampaignScreen extends StatefulWidget {
  final String creator; // Tambah creator dari DashboardScreen
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

  Future<void> _pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) {
      final dir = await getApplicationDocumentsDirectory();
      final name = basename(picked.path);
      final savedImage = await File(picked.path).copy('${dir.path}/$name');
      setState(() {
        _imageFile = savedImage;
      });
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
    if (!_formKey.currentState!.validate() || _imageFile == null || _endDate == null) return;

    final campaign = Campaign(
      title: _titleController.text,
      description: _descController.text,
      targetFund: int.parse(_targetController.text),
      collectedFund: 0,
      endDate: _endDate!.toIso8601String(),
      imagePath: _imageFile!.path,
      status: "pending", // selalu pending saat dibuat user
      creator: widget.creator,
    );
    await CampaignDatabase.instance.insertCampaign(campaign);
    ScaffoldMessenger.of(this.context).showSnackBar(SnackBar(content: Text('Campaign berhasil diajukan! Menunggu ACC Admin.')));
    Navigator.pop(this.context, true);
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
              _imageFile != null
                  ? Image.file(_imageFile!, height: 100)
                  : Text("Belum ada gambar"),
              TextButton(
                onPressed: _pickImage,
                child: Text("Pilih Gambar"),
              ),
              SizedBox(height: 20),
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