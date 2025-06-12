import 'package:flutter/material.dart';
import '../db/volunteer_registration_database.dart';
import '../models/volunteer_registration.dart';
import 'package:excel/excel.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:open_file/open_file.dart';

class VolunteerListScreen extends StatefulWidget {
  final int campaignId;
  final String currentUsername; // username admin atau creator campaign
  final String campaignCreator; // username creator campaign

  const VolunteerListScreen({
    super.key,
    required this.campaignId,
    required this.currentUsername,
    required this.campaignCreator,
  });

  bool get isAuthorized => currentUsername == 'admin' || currentUsername == campaignCreator;

  @override
  State<VolunteerListScreen> createState() => _VolunteerListScreenState();
}

class _VolunteerListScreenState extends State<VolunteerListScreen> {
  late Future<List<VolunteerRegistration>> _registrationsFuture;
  List<VolunteerRegistration> _allRegistrations = [];
  List<VolunteerRegistration> _filteredRegistrations = [];
  String _searchText = '';
  String _selectedStatus = 'all';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _reload();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _reload() {
    setState(() {
      _registrationsFuture = VolunteerRegistrationDatabase.instance.getRegistrationsByCampaign(widget.campaignId);
      _registrationsFuture.then((regs) {
        _allRegistrations = regs;
        _applyFilter();
      });
    });
  }

  void _onSearchChanged() {
    setState(() {
      _searchText = _searchController.text.trim();
      _applyFilter();
    });
  }

  void _applyFilter() {
    List<VolunteerRegistration> filtered = _allRegistrations;
    if (_selectedStatus != 'all') {
      filtered = filtered.where((v) => v.status == _selectedStatus).toList();
    }
    if (_searchText.isNotEmpty) {
      filtered = filtered.where((v) =>
        v.name.toLowerCase().contains(_searchText.toLowerCase()) ||
        v.user.toLowerCase().contains(_searchText.toLowerCase()) ||
        v.phone.toLowerCase().contains(_searchText.toLowerCase())
      ).toList();
    }
    setState(() {
      _filteredRegistrations = filtered;
    });
  }

  Future<void> _exportToExcel() async {
    var excel = Excel.createExcel();
    Sheet sheetObject = excel['Volunteer'];
    sheetObject.appendRow([
      'Nama', 'Username', 'Nomor HP', 'Tanggal Daftar', 'Status'
    ]);
    for (final reg in _filteredRegistrations) {
      sheetObject.appendRow([
        reg.name,
        reg.user,
        reg.phone,
        reg.registeredAt.toLocal().toString(),
        reg.status,
      ]);
    }
    final dir = await getTemporaryDirectory();
    final filePath = '${dir.path}/daftar_volunteer_campaign_${widget.campaignId}.xlsx';
    final excelBytes = excel.encode();
    if (excelBytes != null) {
      final file = File(filePath);
      await file.writeAsBytes(excelBytes);
      // Buka file
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('File Excel berhasil dibuat')));
      }
      await OpenFile.open(filePath);
    }
  }

  Widget _buildStatusChip(String status) {
    switch (status) {
      case "approved":
        return const Chip(label: Text("Disetujui"), backgroundColor: Colors.green);
      case "pending":
        return const Chip(label: Text("Menunggu"), backgroundColor: Colors.orange);
      case "rejected":
        return const Chip(label: Text("Ditolak"), backgroundColor: Colors.red);
      default:
        return Chip(label: Text(status));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isAuthorized) {
      return Scaffold(
        appBar: AppBar(title: const Text('Daftar Volunteer')),
        body: const Center(child: Text('Akses Ditolak')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Volunteer'),
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: _filteredRegistrations.isEmpty ? null : _exportToExcel,
            tooltip: 'Export ke Excel',
          ),
        ],
      ),
      body: FutureBuilder<List<VolunteerRegistration>>(
        future: _registrationsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (_allRegistrations.isEmpty) {
            _allRegistrations = snapshot.data ?? [];
            _applyFilter();
          }
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        decoration: const InputDecoration(
                          labelText: 'Cari nama/username/HP',
                          prefixIcon: Icon(Icons.search),
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    DropdownButton<String>(
                      value: _selectedStatus,
                      items: const [
                        DropdownMenuItem(value: 'all', child: Text('Semua')),
                        DropdownMenuItem(value: 'approved', child: Text('Disetujui')),
                        DropdownMenuItem(value: 'pending', child: Text('Menunggu')),
                        DropdownMenuItem(value: 'rejected', child: Text('Ditolak')),
                      ],
                      onChanged: (val) {
                        setState(() {
                          _selectedStatus = val ?? 'all';
                          _applyFilter();
                        });
                      },
                    ),
                  ],
                ),
              ),
              Expanded(
                child: _filteredRegistrations.isEmpty
                    ? const Center(child: Text('Belum ada pendaftar volunteer.'))
                    : ListView.builder(
                        itemCount: _filteredRegistrations.length,
                        itemBuilder: (context, i) {
                          final reg = _filteredRegistrations[i];
                          return Card(
                            margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
                            child: ListTile(
                              title: Text(reg.name),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Username: ${reg.user}'),
                                  Text('Nomor HP: ${reg.phone}'),
                                  Text('Daftar: ${reg.registeredAt.toLocal()}'),
                                  _buildStatusChip(reg.status),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}