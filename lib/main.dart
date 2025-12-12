import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:dart_ping_ios/dart_ping_ios.dart';
import 'package:window_manager/window_manager.dart';
import 'package:yet_another_wol/src/app.dart';
import 'package:yet_another_wol/src/features/devices/data/device_repository.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (Platform.isIOS) {
    DartPingIOS.register();
  }

  // Initialize Hive only - fast operation
  await Hive.initFlutter();

  final container = ProviderContainer();
  await DeviceRepository().init();

  if (Platform.isWindows || Platform.isMacOS || Platform.isLinux) {
    await windowManager.ensureInitialized();
    WindowOptions windowOptions = const WindowOptions(
      size: Size(800, 600),
      center: true,
      backgroundColor: Colors.transparent,
      skipTaskbar: false,
      titleBarStyle: TitleBarStyle.normal,
    );

    await windowManager.waitUntilReadyToShow(windowOptions, () async {
      await windowManager.show();
      await windowManager.focus();
    });

    if (Platform.isMacOS) {
      await windowManager.setPreventClose(true);
    }
  }

  // Start app immediately - don't block on network_tools
  runApp(
    UncontrolledProviderScope(container: container, child: const WolApp()),
  );
}
