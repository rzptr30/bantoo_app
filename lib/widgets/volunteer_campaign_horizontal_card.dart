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
        height: 205, // tambah sedikit jika perlu
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
                    height: 60, // lebih kecil
                    fit: BoxFit.cover,
                  ),
                )
              else
                Container(
                  width: 220,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(14),
                      topRight: Radius.circular(14),
                    ),
                  ),
                  alignment: Alignment.center,
                  child: Icon(Icons.image, size: 40, color: Colors.grey[500]),
                ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        campaign.title,
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        campaign.description,
                        style: TextStyle(fontSize: 12),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        "Lokasi: ${campaign.location}",
                        style: TextStyle(fontSize: 12),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        "Event: ${_formatDate(campaign.eventDate)}",
                        style: TextStyle(fontSize: 12),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        "Oprec: ${_formatDate(campaign.registrationStart)} - ${_formatDate(campaign.registrationEnd)}",
                        style: TextStyle(fontSize: 12, color: Colors.blue[700]),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const Spacer(),
                      Align(
                        alignment: Alignment.centerRight,
                        child: SizedBox(
                          height: 26,
                          child: OutlinedButton(
                            onPressed: onTap,
                            style: OutlinedButton.styleFrom(
                              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                              minimumSize: Size(0, 0),
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            child: Text(
                              "Join Now",
                              style: TextStyle(fontSize: 11),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}