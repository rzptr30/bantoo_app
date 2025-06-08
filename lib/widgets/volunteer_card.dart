import 'package:flutter/material.dart';
import '../models/volunteer.dart';

class VolunteerCard extends StatelessWidget {
  final Volunteer volunteer;
  final VoidCallback? onJoin;

  const VolunteerCard({
    Key? key,
    required this.volunteer,
    this.onJoin,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset(
                volunteer.image,
                width: 70,
                height: 70,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text("Agency: ", style: TextStyle(fontWeight: FontWeight.w600)),
                      Expanded(child: Text(volunteer.agency, style: const TextStyle(fontWeight: FontWeight.w400))),
                    ],
                  ),
                  Row(
                    children: [
                      const Text("Location: ", style: TextStyle(fontWeight: FontWeight.w600)),
                      Expanded(child: Text(volunteer.location, style: const TextStyle(fontWeight: FontWeight.w400))),
                    ],
                  ),
                  const SizedBox(height: 4),
                  const Text("Description", style: TextStyle(fontWeight: FontWeight.w600)),
                  Text(volunteer.description, maxLines: 3, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Text("Expired date: ", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                      Text(volunteer.expired, style: const TextStyle(fontSize: 13)),
                    ],
                  ),
                  Row(
                    children: [
                      const Text("Registration Fee: ", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                      Text(
                        volunteer.fee,
                        style: TextStyle(
                          fontSize: 13,
                          color: volunteer.fee == 'Free' ? Colors.green : Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 10),
                      const Text("Applicant quota: ", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                      Text(volunteer.quota.toString(), style: const TextStyle(fontSize: 13)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: 110,
                    child: ElevatedButton(
                      onPressed: onJoin,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF222E3A),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        padding: const EdgeInsets.symmetric(vertical: 8),
                      ),
                      child: const Text("Join now", style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}