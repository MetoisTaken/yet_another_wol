import 'package:home_widget/home_widget.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:yet_another_wol/src/features/devices/presentation/device_controller.dart';
import 'dart:convert';
import 'dart:io';
import 'package:yet_another_wol/src/features/devices/domain/device.dart';

part 'widget_service.g.dart';

const String kAppGroupId = 'group.com.metehan.yet_another_wol';

@Riverpod(keepAlive: true)
class WidgetService extends _$WidgetService {
  @override
  void build() {
    ref.listen(deviceControllerProvider, (previous, next) {
      updateWidgetData();
    });
  }

  Future<void> updateWidgetData() async {
    final devices = ref.read(deviceControllerProvider);

    // Serialize devices to JSON to pass to widget
    // Note: HomeWidget usually passes simpler key-value pairs.
    // For complex lists, we might need store data as a JSON string
    // and parse it on the native side (Kotlin/Swift).

    // Filter Favorites
    final favoriteDevices = devices.where((d) => d.isFavorite).toList();

    // Prepare list for widget
    List<Device> devicesToSync = favoriteDevices;

    if (Platform.isIOS) {
      // iOS Limit: Max 2
      devicesToSync = favoriteDevices.take(2).toList();
    }

    final devicesJson = jsonEncode(
      devicesToSync
          .map(
            (d) => {
              'id': d.id,
              'alias': d.alias,
              'mac': d.macAddress,
              'port': d.port,
            },
          )
          .toList(),
    );

    try {
      if (Platform.isAndroid) {
        await HomeWidget.saveWidgetData<String>('devices_data', devicesJson);
        await HomeWidget.updateWidget(
          name: 'DeviceListWidget', // Must match native widget name
        );
      } else if (Platform.isIOS && kAppGroupId != null) {
        // Only update on iOS if App Group ID is configured
        await HomeWidget.saveWidgetData<String>('devices_data', devicesJson);
        await HomeWidget.updateWidget(
          name: 'DeviceListWidget',
          iOSName: 'DeviceListWidget',
        );
      }
    } catch (e) {
      // Ignore if widget is not implemented
    }
  }
}
