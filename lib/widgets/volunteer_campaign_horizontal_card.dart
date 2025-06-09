import 'dart:io';
import 'package:flutter/material.dart';
import '../models/volunteer_campaign.dart';

class VolunteerCampaignHorizontalCard extends StatelessWidget {
  final VolunteerCampaign campaign;
  final VoidCallback? onTap;

  const VolunteerCampaignHorizontalCard({
    Key? key,
    required this.campaign,
    this.onTap,
  }) : super(key: key);

  String _formatDate(DateTime date) {
    return "${date.day}/${date.month}/${date.year}";
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 220,
        child: Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          elevation: 2,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (campaign.imagePath.isNotEmpty && File(campaign.imagePath).existsSync())
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(14),
                    topRight: Radius.circular(14),
                  ),
                  child: Image.file(
                    File(campaign.imagePath),
                    width: 220,
                    height: 110,
                    fit: BoxFit.cover,
                  ),
                )
              else
                Container(
                  width: 220,
                  height: 110,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(14),
                      topRight: Radius.circular(14),
                    ),
                  ),
                  alignment: Alignment.center,
                  child: Icon(Icons.image, size: 48, color: Colors.grey[500]),
                ),
              Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      campaign.title,
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 3),
                    Text(
                      campaign.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 12),
                    ),
                    SizedBox(height: 3),
                    Text("Lokasi: ${campaign.location}", style: TextStyle(fontSize: 12)),
                    Text("Kuota: ${campaign.quota}", style: TextStyle(fontSize: 12)),
                    Text("Event: ${_formatDate(campaign.eventDate)}", style: TextStyle(fontSize: 12)),
                    Text(
                      "Oprec: ${_formatDate(campaign.registrationStart)} - ${_formatDate(campaign.registrationEnd)}",
                      style: TextStyle(fontSize: 12, color: Colors.blue[700]),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: OutlinedButton(
                        onPressed: onTap,
                        child: Text("Join Now"),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}