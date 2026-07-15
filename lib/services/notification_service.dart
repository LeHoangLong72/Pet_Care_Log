import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

// Hàm xử lý thông báo khi app đang chạy ngầm (Background) hoặc đã đóng hoàn toàn
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Không cần gọi init ở đây vì hệ thống sẽ tự xử lý
  debugPrint("FCM: Nhận thông báo ở chế độ chạy ngầm: ${message.notification?.title}");
}

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notificationsPlugin = FlutterLocalNotificationsPlugin();
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;

  Future<void> init() async {
    // 1. Khởi tạo Múi giờ
    tz.initializeTimeZones();
    try {
      final dynamic timeZoneName = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(timeZoneName.toString()));
    } catch (e) {
      tz.setLocalLocation(tz.getLocation('Asia/Ho_Chi_Minh'));
    }
    
    // 2. Cấu hình Local Notifications
    const AndroidInitializationSettings androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const DarwinInitializationSettings iosSettings = DarwinInitializationSettings();
    const InitializationSettings settings = InitializationSettings(android: androidSettings, iOS: iosSettings);

    await _notificationsPlugin.initialize(
      settings,
      onDidReceiveNotificationResponse: (details) {},
    );

    // 3. Thiết lập Firebase Cloud Messaging (FCM)
    await _setupFCM();
  }

  Future<void> _setupFCM() async {
    // Xin quyền thông báo (iOS và Android 13+)
    NotificationSettings settings = await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      debugPrint('FCM: Người dùng đã cấp quyền thông báo.');
    }

    // Lấy FCM Token để gửi thông báo test từ Firebase Console
    String? token = await _fcm.getToken();
    debugPrint("FCM: Token của thiết bị này là: $token");
    // Bạn hãy copy mã token này dán vào Firebase Console để test gửi thông báo nhé!

    // Lắng nghe thông báo khi App đang mở (Foreground)
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint("FCM: Nhận thông báo khi đang mở app: ${message.notification?.title}");
      
      // Hiển thị thông báo ngay lập tức bằng Local Notification
      if (message.notification != null) {
        _showImmediateNotification(
          title: message.notification!.title ?? "Thông báo mới",
          body: message.notification!.body ?? "",
        );
      }
    });

    // Đăng ký hàm xử lý chạy ngầm
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  }

  // Hiển thị thông báo ngay lập tức
  Future<void> _showImmediateNotification({required String title, required String body}) async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'fcm_immediate',
      'Push Notifications',
      channelDescription: 'Thông báo đẩy từ máy chủ',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: true,
    );
    
    const NotificationDetails details = NotificationDetails(android: androidDetails, iOS: DarwinNotificationDetails());
    await _notificationsPlugin.show(0, title, body, details);
  }

  // Đặt lịch thông báo (nhắc lịch y tế)
  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
  }) async {
    if (scheduledDate.isBefore(DateTime.now())) return;

    await _notificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(scheduledDate, tz.local),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'pet_care_reminders',
          'Pet Care Reminders',
          channelDescription: 'Thông báo nhắc nhở chăm sóc thú cưng',
          importance: Importance.max,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  Future<void> cancelNotification(int id) async {
    await _notificationsPlugin.cancel(id);
  }
}
