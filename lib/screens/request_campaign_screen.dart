import 'package:flutter/material.dart';
import 'add_campaign_screen.dart';

class RequestCampaignScreen extends StatelessWidget {
  final String creator;
  const RequestCampaignScreen({Key? key, required this.creator}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Langsung tampilkan form tambah campaign, tanpa card/keterangan apapun
    return AddCampaignScreen(creator: creator);
  }
}