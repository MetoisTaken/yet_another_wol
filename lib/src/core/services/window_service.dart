import 'dart:io';

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
    if (Platform.isMacOS || Platform.isWindows) {
      bool isPreventClose = await windowManager.isPreventClose();
      if (isPreventClose) {
        await windowManager.hide();
        await ref
            .read(notificationServiceProvider.notifier)
            .showBackgroundModeNotification();
      } else {
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
