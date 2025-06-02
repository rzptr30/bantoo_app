import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

import '../db/campaign_database.dart';
import '../models/campaign.dart';

class AddCampaignScreen extends StatefulWidget {
  const AddCampaignScreen({Key? key}) : super(key: key);

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
      // Copy ke folder app (agar tidak hilang jika cache dibersihkan)
      final dir = await getApplicationDocumentsDirectory();
      final name = basename(picked.path);
      final savedImage = await File(picked.path).copy('${dir.path}/$name');
      setState(() {
        _imageFile = savedImage;
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
    );
    await CampaignDatabase.instance.insertCampaign(campaign);
    ScaffoldMessenger.of(this.context).showSnackBar(SnackBar(content: Text('Campaign added!')));
    Navigator.pop(this.context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Ask For New Campaign")),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              GestureDetector(
                onTap: _pickImage,
                child: _imageFile == null
                    ? Container(
                        width: double.infinity,
                        height: 180,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Icon(Icons.add_a_photo, size: 48, color: Colors.grey[800]),
                      )
                    : ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.file(_imageFile!, width: double.infinity, height: 180, fit: BoxFit.cover),
                      ),
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(labelText: "Judul Campaign"),
                validator: (v) => v == null || v.isEmpty ? "Wajib diisi" : null,
              ),
              SizedBox(height: 12),
              TextFormField(
                controller: _descController,
                decoration: InputDecoration(labelText: "Deskripsi"),
                maxLines: 3,
                validator: (v) => v == null || v.isEmpty ? "Wajib diisi" : null,
              ),
              SizedBox(height: 12),
              TextFormField(
                controller: _targetController,
                decoration: InputDecoration(labelText: "Total Dana yang Dibutuhkan"),
                keyboardType: TextInputType.number,
                validator: (v) => v == null || v.isEmpty ? "Wajib diisi" : null,
              ),
              SizedBox(height: 12),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(_endDate == null
                    ? "Sampai Kapan (Pilih Tanggal)"
                    : "Sampai: ${_endDate!.day}/${_endDate!.month}/${_endDate!.year}"),
                trailing: Icon(Icons.calendar_today),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now().add(Duration(days: 1)),
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(Duration(days: 365 * 5)),
                  );
                  if (picked != null) setState(() => _endDate = picked);
                },
              ),
              SizedBox(height: 24),
              ElevatedButton(
                onPressed: _saveCampaign,
                child: Text("Simpan Campaign"),
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(double.infinity, 48),
                  backgroundColor: Color(0xFF222E3A),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}