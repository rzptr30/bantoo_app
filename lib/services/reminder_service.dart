import '../db/volunteer_campaign_database.dart';
import '../db/volunteer_registration_database.dart';
import '../db/notification_database.dart';
import '../models/notification_item.dart';

class ReminderService {
  static Future<void> sendVolunteerReminders(String username) async {
    final now = DateTime.now();
    final besok = DateTime(now.year, now.month, now.day + 1);

    // Ambil daftar campaign volunteer yang eventDate == besok
    final campaigns = await VolunteerCampaignDatabase.instance.getCampaignsByEventDate(besok);

    for (final campaign in campaigns) {
      // Cek apakah user ini terdaftar sebagai volunteer di campaign ini
      final regs = await VolunteerRegistrationDatabase.instance.getRegistrationsByUser(username);
      final isRegistered = regs.any((r) => r.campaignId == campaign.id);

      if (isRegistered) {
        // Cek apakah sudah pernah dikirimi reminder, misal dengan type dan relatedId yang sama
        final existing = await NotificationDatabase.instance.getNotificationByTypeAndRelatedId(
          user: username,
          type: 'volunteer_reminder',
          relatedId: campaign.id.toString(),
        );
        if (existing == null) {
          await NotificationDatabase.instance.insertNotification(NotificationItem(
            user: username,
            message: 'Reminder: Event volunteer "${campaign.title}" akan berlangsung besok!',
            date: DateTime.now(),
            type: 'volunteer_reminder',
            relatedId: campaign.id.toString(),
          ));
        }
      }
    }
  }
}