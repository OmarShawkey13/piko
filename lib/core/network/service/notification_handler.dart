import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:piko/main.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationHandler {
  static final FlutterLocalNotificationsPlugin _local =
      FlutterLocalNotificationsPlugin();

  // كاش لكل رسائل كل شخص
  static final Map<String, List<Message>> _messageCache = {};

  // ============================
  //   INITIALIZATION
  // ============================
  static Future<void> initialize() async {
    await _initLocalNotifications();

    // FOREGROUND
    OneSignal.Notifications.addForegroundWillDisplayListener((event) {
      event.preventDefault();
      _handleNotification(event.notification);
    });

    // CLICK EVENT
    OneSignal.Notifications.addClickListener((event) {
      _handleNotification(event.notification);
    });
  }

  // ============================
  //   LOCAL NOTIFICATION INIT
  // ============================
  static Future<void> _initLocalNotifications() async {
    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );

    const initSettings = InitializationSettings(android: androidSettings);

    await _local.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (response) {
        final payload = response.payload;
        if (payload != null) {
          navigatorKey.currentState?.pushNamed(
            "/chat",
            arguments: payload,
          );
        }
      },
    );
  }

  // ============================
  //   UNIVERSAL NOTIFICATION HANDLER
  // ============================
  static void _handleNotification(OSNotification notification) {
    final data = notification.additionalData ?? {};

    final senderId = data["senderId"] ?? "unknown";
    final title = data["title"] ?? notification.title ?? "Piko";
    final body = data["body"] ?? notification.body ?? "";

    showNotification(
      title: title,
      body: body,
      senderId: senderId,
    );
  }

  // ============================
  //   SHOW CUSTOM NOTIFICATION
  // ============================
  static Future<void> showNotification({
    required String title,
    required String body,
    required String senderId,
  }) async {
    // رسالة جديدة في المحادثة
    final newMessage = Message(
      body,
      DateTime.now(),
      Person(name: title),
    );

    // حفظ الرسالة في كاش الشخص
    _messageCache.putIfAbsent(senderId, () => []);
    _messageCache[senderId]!.add(newMessage);

    // Messaging Style — شكل المحادثة
    final style = MessagingStyleInformation(
      Person(name: title),
      groupConversation: false,
      messages: _messageCache[senderId]!,
    );

    final androidDetails = AndroidNotificationDetails(
      "chat_channel",
      "Piko Chat Notifications",
      importance: Importance.high,
      priority: Priority.high,
      groupKey: "chat_$senderId",
      styleInformation: style,
    );

    final details = NotificationDetails(android: androidDetails);

    // نفس الـ ID للشخص = إشعار واحد فقط يتحدث
    await _local.show(
      senderId.hashCode,
      title,
      body,
      details,
      payload: senderId,
    );
  }
}
