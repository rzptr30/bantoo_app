import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../db/notification_database.dart';
import '../models/notification_item.dart';

class NotificationService {
  static Future<void> init(BuildContext context, String username) async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;

    // Minta izin notifikasi
    await messaging.requestPermission();

    // Dapatkan token FCM
    String? token = await messaging.getToken();
    print('Token FCM user $username: $token');

    // Kirim token ke backend (ganti URL dengan endpoint backend-mu)
    if (token != null) {
      try {
        var response = await http.post(
          Uri.parse("https://your-backend-url.com/api/save-fcm-token"),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({"username": username, "token": token}),
        );
        print('Response backend: ${response.statusCode} - ${response.body}');
      } catch (e) {
        print("Gagal mengirim FCM token ke backend: $e");
      }
    }

    // Listener notifikasi saat app aktif
    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      RemoteNotification? notification = message.notification;
      if (notification != null) {
        // Simpan notifikasi ke database lokal SQLite
        await NotificationDatabase.instance.insertNotification(
          NotificationItem(
            user: username,
            message: notification.body ?? '',
            date: DateTime.now(),
            type: message.data['type'],
            relatedId: message.data['relatedId'],
          ),
        );
        // Tampilkan snackbar sebagai feedback
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(notification.title ?? 'Ada notifikasi baru')),
        );
      }
    });

    // Listener jika app dibuka dari notifikasi
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      // Misal jika ingin navigasi ke halaman tertentu berdasarkan notifikasi
      String? campaignId = message.data['campaign_id'];
      if (campaignId != null) {
        // TODO: Navigasi ke detail campaignId
        // Navigator.pushNamed(context, '/campaign-detail', arguments: campaignId);
      }
    });
  }
}