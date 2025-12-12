import 'dart:io';
import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:window_manager/window_manager.dart';
import 'package:yet_another_wol/src/core/services/notification_service.dart';

part 'window_service.g.dart';

@Riverpod(keepAlive: true)
class WindowService extends _$WindowService with WindowListener {
  @override
  void build() {
    if (Platform.isWindows || Platform.isMacOS || Platform.isLinux) {
      windowManager.addListener(this);
    }
  }

  @override
  void onWindowClose() async {
    print('WindowService: onWindowClose called');
    if (Platform.isMacOS) {
      bool isPreventClose = await windowManager.isPreventClose();
      print('WindowService: isPreventClose: $isPreventClose');
      if (isPreventClose) {
        print('WindowService: Hiding window');
        await windowManager.hide();
        await ref
            .read(notificationServiceProvider.notifier)
            .showBackgroundModeNotification();
      } else {
        print('WindowService: Not preventing close, closing window');
        await windowManager.close();
      }
    } else {
      await windowManager.close();
    }
  }

  // Clean up listener when provider is disposed (though keepAlive is true)
  void dispose() {
    windowManager.removeListener(this);
  }
}
