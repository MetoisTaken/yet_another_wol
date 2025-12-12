import 'dart:io';
import 'package:quick_actions/quick_actions.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:yet_another_wol/src/features/devices/presentation/device_controller.dart';

part 'quick_actions_service.g.dart';

@Riverpod(keepAlive: true)
class QuickActionsService extends _$QuickActionsService {
  @override
  void build() {
    final quickActions = const QuickActions();
    
    if (Platform.isAndroid || Platform.isIOS) {
      quickActions.initialize((shortcutType) {
      if (shortcutType == 'wake_all') {
        ref.read(deviceControllerProvider.notifier).wakeAllDevices();
      } else if (shortcutType.startsWith('device_')) {
        final deviceId = shortcutType.substring(7);
        final devices = ref.read(deviceControllerProvider);
        try {
          final device = devices.firstWhere((d) => d.id == deviceId);
          ref.read(deviceControllerProvider.notifier).wakeDevice(device);
        } catch (_) {
          // Device might have been deleted
        }
      }
    });
    }

    ref.listen(deviceControllerProvider, (previous, next) {
      updateShortcuts();
    });
  }

  Future<void> updateShortcuts() async {
    final devices = ref.read(deviceControllerProvider);
    final quickActions = const QuickActions();

    List<ShortcutItem> items = [
      const ShortcutItem(
        type: 'wake_all',
        localizedTitle: 'Wake All',
        icon: 'action_wake_all', // Needs asset
      ),
    ];

    // Add first 3 devices as shortcuts
    for (var i = 0; i < devices.length && i < 3; i++) {
      final device = devices[i];
      items.add(ShortcutItem(
        type: 'device_${device.id}',
        localizedTitle: device.alias,
        icon: 'action_device', // Needs asset
      ));
    }

    if (Platform.isAndroid || Platform.isIOS) {
      await quickActions.setShortcutItems(items);
    }
  }
}
