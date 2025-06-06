import 'package:flutter/material.dart';
import '../widgets/campaign_request_card.dart';
import 'add_campaign_screen.dart';

class RequestCampaignScreen extends StatelessWidget {
  final String creator;
  const RequestCampaignScreen({Key? key, required this.creator}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Ask For New Campaign")),
      body: Center(
        child: CampaignRequestCard(
          onButtonPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => AddCampaignScreen(creator: creator)),
            );
          },
        ),
      ),
    );
  }
}