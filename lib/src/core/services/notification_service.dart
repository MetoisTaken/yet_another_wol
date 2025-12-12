import 'dart:io';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'notification_service.g.dart';

@Riverpod(keepAlive: true)
class NotificationService extends _$NotificationService {
  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  @override
  void build() {
    _init();
  }

  Future<void> _init() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initializationSettingsDarwin =
        DarwinInitializationSettings(
          requestAlertPermission: false,
          requestBadgePermission: false,
          requestSoundPermission: false,
        );

    const InitializationSettings initializationSettings =
        InitializationSettings(
          android: initializationSettingsAndroid,
          iOS: initializationSettingsDarwin,
          macOS: initializationSettingsDarwin,
          linux: LinuxInitializationSettings(
            defaultActionName: 'Open notification',
          ),
        );

    // Initial permission request for macOS
    if (Platform.isMacOS) {
      await _notificationsPlugin
          .resolvePlatformSpecificImplementation<
            MacOSFlutterLocalNotificationsPlugin
          >()
          ?.requestPermissions(alert: true, badge: true, sound: true);
    }

    await _notificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (details) {
        // Handle notification tap if needed
      },
    );
  }

  Future<void> showBackgroundModeNotification() async {
    if (!Platform.isMacOS) return;

    const DarwinNotificationDetails macOSDetails = DarwinNotificationDetails(
      presentSound: false,
    );

    const NotificationDetails notificationDetails = NotificationDetails(
      macOS: macOSDetails,
    );

    await _notificationsPlugin.show(
      888, // Unique ID for background notification
      'App is running in background',
      'Yet Another WoL is now minimized to the tray.',
      notificationDetails,
    );
  }
}
