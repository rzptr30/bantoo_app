import 'package:flutter/material.dart';
import '../db/notification_database.dart';
import '../models/notification_item.dart';

class NotificationScreen extends StatelessWidget {
  final String username;
  const NotificationScreen({Key? key, required this.username}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<NotificationItem>>(
      future: NotificationDatabase.instance.getNotificationsForUser(username),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(child: Text("Belum ada notifikasi."));
        }
        final notifs = snapshot.data!;
        return ListView.builder(
          itemCount: notifs.length,
          itemBuilder: (context, i) {
            final n = notifs[i];
            return ListTile(
              leading: Icon(Icons.notifications),
              title: Text(n.message),
              subtitle: Text('${n.date.day.toString().padLeft(2, '0')}/'
                  '${n.date.month.toString().padLeft(2, '0')}/'
                  '${n.date.year} ${n.date.hour.toString().padLeft(2, '0')}:'
                  '${n.date.minute.toString().padLeft(2, '0')}'),
            );
          },
        );
      },
    );
  }
}