import 'dart:convert';
import 'package:http/http.dart' as http;

class NotificationService {
  // 🔐 REST API KEY من OneSignal (انت حاطط المفتاح الصحيح)
  static const String oneSignalRestApiKey =
      "os_v2_app_6jsa5fzojjhu7nzh2x7obkjaix2u3tcql5tu4rnt2r4kvqqep3j6rj5qauj73g3s2owokx6hbixaohofmwauxx6xtcid32ijcjdozfy";

  // 📌 OneSignal App ID الحقيقي:
  static const String oneSignalAppId = "f2640e97-2e4a-4f4f-b727-d5fee0a92045";

  static Future<void> sendOneSignalMessage({
    required String externalId,
    required String title,
    required String body,
  }) async {
    try {
      final url = Uri.parse("https://api.onesignal.com/notifications");
      final payload = {
        "app_id": oneSignalAppId,
        "include_external_user_ids": [externalId],
        "headings": {"en": title},
        "contents": {"en": body},
        "priority": 10,
        "android_channel_id": null,
      };
      http.post(
        url,
        headers: {
          "Content-Type": "application/json; charset=utf-8",
          "Authorization": "Basic $oneSignalRestApiKey",
        },
        body: jsonEncode(payload),
      );
    } catch (e) {
      throw Exception("Error sending OneSignal message: $e");
    }
  }
}
