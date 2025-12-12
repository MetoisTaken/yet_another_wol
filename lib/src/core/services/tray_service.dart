import 'dart:io';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:tray_manager/tray_manager.dart';
import 'package:window_manager/window_manager.dart';
import 'package:yet_another_wol/src/features/devices/presentation/device_controller.dart';

part 'tray_service.g.dart';

@Riverpod(keepAlive: true)
class TrayService extends _$TrayService with TrayListener {
  @override
  void build() {
    // Listen to changes in device list to update context menu
    ref.listen(deviceControllerProvider, (previous, next) {
      updateContextMenu();
    });
    
    // Initial setup if desktop
    if (Platform.isWindows || Platform.isMacOS || Platform.isLinux) {
      _init();
    }
  }

  Future<void> _init() async {
    if (!Platform.isWindows && !Platform.isMacOS && !Platform.isLinux) return;

     await trayManager.setIcon(
      Platform.isWindows ? 'images/tray_icon.ico' : 'images/tray_icon.png',
    );
    trayManager.addListener(this);
    await updateContextMenu();
  }

  Future<void> updateContextMenu() async {
    if (!Platform.isWindows && !Platform.isMacOS && !Platform.isLinux) return;
    
    final devices = ref.read(deviceControllerProvider);
    
    List<MenuItem> items = [
      MenuItem(
        key: 'wake_all',
        label: 'Wake All Devices',
      ),
      MenuItem.separator(),
    ];

    for (var device in devices) {
      items.add(MenuItem(
        key: 'device_${device.id}',
        label: 'Wake ${device.alias}',
      ));
    }

    items.addAll([
      MenuItem.separator(),
      MenuItem(
        key: 'show',
        label: 'Show App',
      ),
      MenuItem(
        key: 'exit',
        label: 'Exit',
      ),
    ]);

    await trayManager.setContextMenu(Menu(items: items));
  }

  @override
  void onTrayIconMouseDown() {
    trayManager.popUpContextMenu();
  }

  @override
  void onTrayIconRightMouseDown() {
    trayManager.popUpContextMenu();
  }

  @override
  void onTrayMenuItemClick(MenuItem menuItem) {
    if (menuItem.key == 'wake_all') {
      ref.read(deviceControllerProvider.notifier).wakeAllDevices();
    } else if (menuItem.key == 'show') {
      windowManager.show();
    } else if (menuItem.key == 'exit') {
      exit(0);
    } else if (menuItem.key != null && menuItem.key!.startsWith('device_')) {
      final deviceId = menuItem.key!.substring(7);
      final devices = ref.read(deviceControllerProvider);
      final device = devices.firstWhere((d) => d.id == deviceId);
      ref.read(deviceControllerProvider.notifier).wakeDevice(device);
    }
  }
}
