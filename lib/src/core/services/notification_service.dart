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

    const LinuxInitializationSettings initializationSettingsLinux =
        LinuxInitializationSettings(
      defaultActionName: 'Open notification',
    );
    
    // Windows settings match Linux closely in some versions but have their own class now
    const WindowsInitializationSettings initializationSettingsWindows = 
        WindowsInitializationSettings(
      appName: 'Yet Another WoL',
      guid: 'd2c18006-238d-42cc-9b6c-2e650c82245f', // Generated UUID
      appUserModelId: 'com.metehan.yet_another_wol',
    );

    final InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsDarwin,
      macOS: initializationSettingsDarwin,
      linux: initializationSettingsLinux,
      windows: initializationSettingsWindows,
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
    if (!Platform.isMacOS && !Platform.isWindows) return;

    const DarwinNotificationDetails macOSDetails = DarwinNotificationDetails(
      presentSound: false,
    );

    const LinuxNotificationDetails linuxDetails = LinuxNotificationDetails(
      defaultActionName: 'Open',
    );

    const NotificationDetails notificationDetails = NotificationDetails(
      macOS: macOSDetails,
      linux: linuxDetails, 
    );

    await _notificationsPlugin.show(
      888, // Unique ID for background notification
      'App is running in background',
      'Yet Another WoL is now minimized to the tray.',
      notificationDetails,
    );
  }
}
