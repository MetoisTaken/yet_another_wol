import 'dart:async';
import 'package:dart_ping/dart_ping.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:yet_another_wol/src/features/devices/presentation/device_controller.dart';

part 'pinger_controller.g.dart';

@riverpod
class PingerController extends _$PingerController {
  Timer? _timer;

  @override
  Map<String, bool> build() {
    // Return map of deviceId -> isOnline
    
    // Start periodic ping
    _timer = Timer.periodic(const Duration(seconds: 5), (_) {
      pingAll();
    });
    
    ref.onDispose(() {
      _timer?.cancel();
    });

    return {};
  }

  Future<void> pingAll() async {
    final devices = ref.read(deviceControllerProvider);
    Map<String, bool> newState = Map.from(state);
    
    for (var device in devices) {
      if (device.ipAddress != null && device.ipAddress!.isNotEmpty) {
        try {
          final ping = Ping(device.ipAddress!, count: 1, timeout: 1);
          await for (final data in ping.stream) {
            final isOnline = data.response != null;
            newState[device.id] = isOnline;
            // First response is enough
            break; 
          }
        } catch (e) {
           newState[device.id] = false;
        }
      }
    }
    state = newState;
  }
}
