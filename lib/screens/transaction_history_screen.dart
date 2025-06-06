import 'package:flutter/material.dart';
import '../db/campaign_database.dart';
import '../models/donation.dart';
import '../models/campaign.dart';

String formatRupiah(int value) {
  return value.toString().replaceAllMapped(
    RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
    (m) => '${m[1]}.',
  );
}

class TransactionHistoryScreen extends StatefulWidget {
  final String username;
  const TransactionHistoryScreen({Key? key, required this.username}) : super(key: key);

  @override
  State<TransactionHistoryScreen> createState() => _TransactionHistoryScreenState();
}

class _TransactionHistoryScreenState extends State<TransactionHistoryScreen> {
  late Future<List<Donation>> _donationsFuture;

  @override
  void initState() {
    super.initState();
    _donationsFuture = CampaignDatabase.instance.getDonationsByUser(widget.username);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Riwayat Donasi'),
      ),
      body: FutureBuilder<List<Donation>>(
        future: _donationsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Belum ada transaksi'));
          }
          final donations = snapshot.data!;
          return ListView.builder(
            itemCount: donations.length,
            itemBuilder: (context, i) {
              final d = donations[i];
              return FutureBuilder<Campaign?>(
                future: CampaignDatabase.instance.getCampaignById(d.campaignId),
                builder: (context, campSnap) {
                  if (campSnap.connectionState == ConnectionState.waiting) {
                    return const ListTile(title: Text("Memuat campaign..."));
                  }
                  if (!campSnap.hasData || campSnap.data == null) {
                    return ListTile(
                      title: Text("Campaign tidak ditemukan (ID: ${d.campaignId})"),
                      subtitle: Text('Nominal: Rp${formatRupiah(d.amount)}'),
                    );
                  }
                  final c = campSnap.data!;
                  return FutureBuilder<List<Donation>>(
                    future: CampaignDatabase.instance.getDonationsByCampaign(c.id!),
                    builder: (context, donSnap) {
                      int totalTerkumpul = 0;
                      if (donSnap.hasData) {
                        totalTerkumpul = donSnap.data!.fold<int>(0, (sum, d) => sum + d.amount);
                      }
                      final percent = (c.targetFund == 0)
                          ? 0.0
                          : (totalTerkumpul / c.targetFund).clamp(0.0, 1.0);
                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        child: ListTile(
                          // Tampilkan "Orang Baik" jika anonim
                          title: Text(
                            d.isAnonim ? "Orang Baik" : d.name,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(c.title, style: TextStyle(fontWeight: FontWeight.w500)),
                              const SizedBox(height: 4),
                              Text('Nominal: Rp${formatRupiah(d.amount)}'),
                              Text('Tanggal: ${d.time}'),
                              Text('Metode: ${d.paymentMethod}'),
                              const SizedBox(height: 8),
                              LinearProgressIndicator(
                                value: percent,
                                backgroundColor: Colors.grey[300],
                                color: Colors.blue,
                                minHeight: 7,
                              ),
                              const SizedBox(height: 4),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "Progress: ${(percent * 100).toStringAsFixed(1)}%",
                                    style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                                  ),
                                  Text(
                                    "Terkumpul: Rp${formatRupiah(totalTerkumpul)}",
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                  Text(
                                    "Target: Rp${formatRupiah(c.targetFund)}",
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}