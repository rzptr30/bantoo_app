import 'dart:io';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/campaign.dart';
import '../models/donation.dart';
import '../models/doa.dart';
import '../db/campaign_database.dart';
import '../db/notification_database.dart';
import '../models/notification_item.dart';


class CampaignDetailScreen extends StatefulWidget {
  final Campaign campaign;
  const CampaignDetailScreen({Key? key, required this.campaign}) : super(key: key);

  @override
  State<CampaignDetailScreen> createState() => _CampaignDetailScreenState();
}

class _CampaignDetailScreenState extends State<CampaignDetailScreen> {
  List<Donation> _donations = [];
  List<Doa> _doas = [];
  bool _loading = true;

  // Mapping metode ke icon asset
  final Map<String, String> metodeIcons = {
    "QRIS": "assets/icons/qris.png",
    "ShopeePay": "assets/icons/shopeepay.png",
    "DANA": "assets/icons/dana.png",
    "GoPay": "assets/icons/gopay.png",
    "VA BCA": "assets/icons/bca.png",
    "VA BRI": "assets/icons/bri.png",
    "VA Mandiri": "assets/icons/mandiri.png",
  };

  int get _totalTerkumpul => _donations.fold(0, (sum, d) => sum + d.amount);
  int get _targetFund => widget.campaign.targetFund;
  double get _percent => _targetFund > 0 ? (_totalTerkumpul / _targetFund).clamp(0.0, 1.0) : 0.0;

  @override
  void initState() {
    super.initState();
    _loadDonationsAndDoas();
  }

  Future<void> _loadDonationsAndDoas() async {
    final donations = await CampaignDatabase.instance.getDonationsByCampaign(widget.campaign.id!);
    final doas = await CampaignDatabase.instance.getDoasByCampaign(widget.campaign.id!);
    setState(() {
      _donations = donations;
      _doas = doas;
      _loading = false;
    });
  }

  void _shareDonation(BuildContext context) {
    final String linkDonasi = "https://donasi.com/campaign/${widget.campaign.id}";
    final String text =
        'Yuk bantu donasi untuk "${widget.campaign.title}" di $linkDonasi\n'
        'Target: Rp${widget.campaign.targetFund}\n'
        'Sudah terkumpul: Rp${_totalTerkumpul}';
    Share.share(text);
  }

  void _showDonorFormDialog(BuildContext context, int nominal) {
    final _nameController = TextEditingController();
    final _doaController = TextEditingController();
    bool isAnonim = false;
    final _formKey = GlobalKey<FormState>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 16,
            right: 16,
            top: 24,
          ),
          child: StatefulBuilder(
            builder: (ctx, setState) => Form(
              key: _formKey,
              child: ListView(
                shrinkWrap: true,
                children: [
                  Text(
                    "Data Diri & Doa",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 16),
                  Row(
                    children: [
                      Checkbox(
                        value: isAnonim,
                        onChanged: (val) {
                          setState(() {
                            isAnonim = val ?? false;
                            if (isAnonim) _nameController.text = "Orang Baik";
                            else _nameController.clear();
                          });
                        },
                      ),
                      Text("Donasi sebagai anonim (Orang Baik)"),
                    ],
                  ),
                  TextFormField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: "Nama (wajib)",
                      border: OutlineInputBorder(),
                    ),
                    validator: (v) {
                      if (v == null || v.isEmpty) return "Nama wajib diisi";
                      return null;
                    },
                  ),
                  SizedBox(height: 16),
                  TextFormField(
                    controller: _doaController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      labelText: "Doa / Dukungan (opsional)",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          Navigator.pop(context); // Tutup form data diri
                          _showPaymentMethodDialog(
                            context,
                            nominal,
                            _nameController.text.trim(),
                            _doaController.text.trim(),
                            isAnonim,
                          );
                        }
                      },
                      child: Text("Lanjut Pilih Metode Pembayaran"),
                    ),
                  ),
                  SizedBox(height: 16),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showPaymentMethodDialog(BuildContext context, int nominal, String donorName, String doaMsg, bool isAnonim) {
    List<String> metode = [
      "QRIS", "ShopeePay", "DANA", "GoPay", "VA BCA", "VA BRI", "VA Mandiri"
    ];
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("Pilih Metode Pembayaran", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              SizedBox(height: 14),
              ...metode.map((m) => ListTile(
                leading: Image.asset(
                  metodeIcons[m] ?? 'assets/icons/qris.png',
                  width: 32,
                  height: 32,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) => Icon(Icons.payment),
                ),
                title: Text(m),
                onTap: () async {
                  // Ambil username login
                  final prefs = await SharedPreferences.getInstance();
                  final username = prefs.getString('username') ?? donorName;
                  final donation = Donation(
                    campaignId: widget.campaign.id!,
                    name: username, // Selalu username login
                    amount: nominal,
                    time: DateTime.now().toString(),
                    paymentMethod: m,
                    isAnonim: isAnonim, // Simpan status anonim
                  );
                  await CampaignDatabase.instance.insertDonation(donation);
                  if (doaMsg.isNotEmpty) {
                    final doa = Doa(
                      campaignId: widget.campaign.id!,
                      name: isAnonim ? "Orang Baik" : username,
                      message: doaMsg,
                      time: DateTime.now().toString(),
                    );
                    await CampaignDatabase.instance.insertDoa(doa);
                  }
                  // Notifikasi untuk donor (user yang login)
await NotificationDatabase.instance.insertNotification(NotificationItem(
  user: username, // username login, sudah diambil dari SharedPreferences
  message: 'Donasi Anda pada campaign "${widget.campaign.title}" berhasil.',
  date: DateTime.now(),
  type: 'donation_new',
  relatedId: widget.campaign.id!.toString(),
));

                  // === UPDATE: Notifikasi ke creator campaign ===
                  final campaignData = await CampaignDatabase.instance.getCampaignById(widget.campaign.id!);
                  // Jangan kirim notifikasi ke diri sendiri
                  if (campaignData != null && campaignData.creator != username) {
                    await NotificationDatabase.instance.insertNotification(NotificationItem(
                      user: campaignData.creator,
                      message: 'Ada donasi baru untuk campaign "${campaignData.title}" dari ${isAnonim ? "Orang Baik" : username} sebesar Rp${nominal}.',
                      date: DateTime.now(),
                      type: 'donation_new',
                      relatedId: widget.campaign.id!.toString(),
                    ));
                  }
                  // === END UPDATE ===

                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Donasi berhasil! Terima kasih sudah berdonasi lewat $m.")),
                  );
                  await _loadDonationsAndDoas();
                },
              )),
            ],
          ),
        );
      }
    );
  }

  void _showDonationAmountDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      isScrollControlled: true,
      builder: (context) {
        TextEditingController _controller = TextEditingController();
        List<int> presetNominals = [30000, 50000, 95000, 100000];
        int? selectedNominal;

        return StatefulBuilder(
          builder: (context, setState) => Padding(
            padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                left: 16,
                right: 16,
                top: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Masukkan Nominal Donasi",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 16),
                ...presetNominals.map((nominal) => ListTile(
                  leading: Icon(selectedNominal == nominal ? Icons.check_circle : Icons.circle_outlined, color: Colors.blue),
                  title: Text("Rp${nominal.toString()}"),
                  onTap: () {
                    setState(() {
                      selectedNominal = nominal;
                      _controller.text = nominal.toString();
                    });
                  },
                )),
                SizedBox(height: 8),
                TextField(
                  controller: _controller,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: "Masukkan Donasi Lainnya",
                    prefixText: "Rp",
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) {
                    setState(() {
                      selectedNominal = int.tryParse(value);
                    });
                  },
                ),
                SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      int? nominal = int.tryParse(_controller.text);
                      if (nominal == null || nominal < 10000) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("Minimal donasi Rp10.000")),
                        );
                        return;
                      }
                      Navigator.pop(context);
                      _showDonorFormDialog(context, nominal);
                    },
                    child: Text("Lanjut pembayaran"),
                  ),
                ),
                SizedBox(height: 16),
              ],
            ),
          ),
        );
      }
    );
  }

  String _formatRupiah(int value) {
    return value.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]}.',
    );
  }

  @override
  Widget build(BuildContext context) {
    final expired = DateTime.tryParse(widget.campaign.endDate);
    return Scaffold(
      appBar: AppBar(title: Text("Detail Campaign")),
      body: _loading
          ? Center(child: CircularProgressIndicator())
          : ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // ===== RINGKASAN, PROGRESS BAR =====
          Card(
            margin: EdgeInsets.only(bottom: 16),
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Profil dan Judul
                  Row(
                    children: [
                      CircleAvatar(radius: 24, child: Icon(Icons.account_circle, size: 32)),
                      SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                widget.campaign.creator,
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ],
                      )
                    ],
                  ),
                  SizedBox(height: 12),
                  Text(
                    widget.campaign.title,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  SizedBox(height: 12),
                  // PROGRESS BAR DAN INFO DANA
                  Text("Donasi terkumpul", style: TextStyle(fontSize: 13, color: Colors.grey[700])),
                  Row(
                    children: [
                      Text(
                        "Rp${_formatRupiah(_totalTerkumpul)}",
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.blue[800]),
                      ),
                      SizedBox(width: 8),
                      Text("dari target Rp${_formatRupiah(_targetFund)}", style: TextStyle(fontSize: 13, color: Colors.grey[700])),
                    ],
                  ),
                  SizedBox(height: 12),
                  LinearProgressIndicator(
                    value: _percent,
                    backgroundColor: Colors.grey[300],
                    color: Colors.blue,
                    minHeight: 10,
                  ),
                  SizedBox(height: 6),
                  Text("${(_percent * 100).toStringAsFixed(1)}%", style: TextStyle(fontSize: 13, color: Colors.grey[700])),
                  SizedBox(height: 12),
                  Container(
                    margin: EdgeInsets.only(top: 12),
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Color(0xFFEAF4FB),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.campaign, color: Colors.blue, size: 18),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            "Semakin banyak donasi yang tersedia, semakin besar bantuan yang bisa disalurkan oleh gerakan ini.",
                            style: TextStyle(fontSize: 13, color: Colors.black87),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          // ===== END RINGKASAN & PROGRESS =====

          if (widget.campaign.imagePath.isNotEmpty && File(widget.campaign.imagePath).existsSync())
            Container(
              height: 180,
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 16),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.file(File(widget.campaign.imagePath), fit: BoxFit.cover),
              ),
            )
          else
            Container(
              height: 180,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(Icons.image, size: 80, color: Colors.grey[600]),
            ),
          Text(
            widget.campaign.title,
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF183B56)),
          ),
          SizedBox(height: 8),
          Text(
            "Oleh: ${widget.campaign.creator}",
            style: TextStyle(fontSize: 16, color: Colors.grey[800]),
          ),
          SizedBox(height: 8),
          SizedBox(height: 16),
          Text(
            "Deskripsi",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 4),
          Text(
            widget.campaign.description,
            style: TextStyle(fontSize: 15),
          ),
          SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Target Dana", style: TextStyle(fontSize: 15, color: Colors.grey[700])),
                    Text(
                      "Rp${_formatRupiah(widget.campaign.targetFund)}",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Terkumpul", style: TextStyle(fontSize: 15, color: Colors.grey[700])),
                    Text(
                      "Rp${_formatRupiah(_totalTerkumpul)}",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (expired != null) ...[
            SizedBox(height: 16),
            Text(
              "Sampai: ${expired.day.toString().padLeft(2, '0')}/${expired.month.toString().padLeft(2, '0')}/${expired.year}",
              style: TextStyle(fontSize: 15, color: Colors.grey[700]),
            ),
          ],
          SizedBox(height: 32),
          // ===== DONASI SECTION =====
          Row(
            children: [
              Text(
                "Donasi",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              SizedBox(width: 8),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Color(0xFFEAF1FB),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  "${_donations.length}",
                  style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          if (_donations.isEmpty)
            Container(
              margin: EdgeInsets.symmetric(vertical: 12),
              padding: EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(14),
              ),
              child: Text(
                "Belum ada yang donasi.",
                style: TextStyle(color: Colors.grey[600], fontStyle: FontStyle.italic),
                textAlign: TextAlign.center,
              ),
            )
          else
            ..._donations.map((donation) => Card(
              margin: EdgeInsets.symmetric(vertical: 4),
              child: ListTile(
                leading: Icon(Icons.account_circle, size: 40),
                title: Text(donation.isAnonim ? "Orang Baik" : donation.name),
                subtitle: Text(
                  "Donasi sebesar Rp${_formatRupiah(donation.amount)}\n"
                  "Via: ${donation.paymentMethod}\n"
                  "${donation.time}",
                ),
                isThreeLine: true,
              ),
            )),
          SizedBox(height: 20),
          // ===== DOA SECTION =====
          Row(
            children: [
              Text(
                "Doa-doa Orang Baik",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              SizedBox(width: 8),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Color(0xFFEAF1FB),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  "${_doas.length}",
                  style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          if (_doas.isEmpty)
            Container(
              margin: EdgeInsets.symmetric(vertical: 12),
              padding: EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(14),
              ),
              child: Text(
                "Belum ada doa/dukungan.",
                style: TextStyle(color: Colors.grey[600], fontStyle: FontStyle.italic),
                textAlign: TextAlign.center,
              ),
            )
          else
            ..._doas.map((doa) => Card(
              margin: EdgeInsets.symmetric(vertical: 4),
              child: ListTile(
                leading: Icon(Icons.account_circle, size: 40),
                title: Text(doa.name),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(doa.message),
                    SizedBox(height: 6),
                    Text(doa.time, style: TextStyle(fontSize: 12, color: Colors.grey[700])),
                  ],
                ),
                isThreeLine: true,
              ),
            )),
          SizedBox(height: 80),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => _shareDonation(context),
                child: Text("Bagikan"),
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  _showDonationAmountDialog(context);
                },
                child: Text("Donasi Sekarang"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}