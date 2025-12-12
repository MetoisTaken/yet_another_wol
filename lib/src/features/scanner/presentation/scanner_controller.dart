import 'dart:async';
import 'dart:io';
import 'package:network_tools/network_tools.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:yet_another_wol/src/features/scanner/domain/scanned_device_model.dart';

part 'scanner_controller.g.dart';

/// Tracks if network_tools has been initialized
bool _networkToolsInitialized = false;

/// Initialize network_tools lazily (only when scanner is used)
Future<void> _ensureNetworkToolsInitialized() async {
  if (_networkToolsInitialized) return;
  
  final appDocDir = await getApplicationDocumentsDirectory();
  await configureNetworkTools(appDocDir.path, enableDebugging: false);
  _networkToolsInitialized = true;
}

@riverpod
class ScannerController extends _$ScannerController {
  StreamSubscription<ActiveHost>? _subscription;
  Timer? _updateTimer;
  
  @override
  AsyncValue<List<ScannedDevice>> build() {
    ref.onDispose(() {
      _subscription?.cancel();
      _updateTimer?.cancel();
    });
    return const AsyncValue.data([]);
  }

  Future<void> startScan() async {
    // Cancel any existing scan
    _subscription?.cancel();
    _updateTimer?.cancel();
    
    // Set loading state immediately
    state = const AsyncValue.loading();
    
    try {
      // Initialize network_tools lazily (first scan only)
      await _ensureNetworkToolsInitialized();
      
      final info = NetworkInfo();
      String? wifiIp = await info.getWifiIP();
      
      // Fallback for desktop or Ethernet connections
      if (wifiIp == null && (Platform.isWindows || Platform.isLinux || Platform.isMacOS)) {
         try {
           final interfaces = await NetworkInterface.list(type: InternetAddressType.IPv4);
           for (var interface in interfaces) {
             // Skip likely virtual interfaces if possible?
             // Simple heuristic: pick first non-loopback non-link-local
             for (var addr in interface.addresses) {
               if (!addr.isLoopback && !addr.isLinkLocal) {
                 wifiIp = addr.address;
                 break;
               }
             }
             if (wifiIp != null) break;
           }
         } catch (e) {
           // ignore error, will fail via null check below
         }
      }
      
      if (wifiIp == null) {
        state = AsyncValue.error('No Network connection', StackTrace.current);
        return;
      }

      final String targetSubnet = wifiIp.substring(0, wifiIp.lastIndexOf('.'));
      
      // Collect hosts in a list
      final List<ScannedDevice> collectedHosts = [];
      
      // Start scanning - non-blocking stream
      final stream = HostScannerService.instance.getAllPingableDevices(
        targetSubnet,
        firstHostId: 1,
        lastHostId: 254,
        progressCallback: (progress) {},
      );

      // Use listen() instead of await for - this doesn't block
      _subscription = stream.listen(
        (host) {
          final device = ScannedDevice(
            activeHost: host, 
            ipAddress: host.internetAddress.address
          );
          collectedHosts.add(device);
          // Trigger resolution but don't await it here
          _resolveHostname(device, collectedHosts);
        },
        onDone: () {
          _updateTimer?.cancel();
          state = AsyncValue.data(List.from(collectedHosts));
        },
        onError: (e, st) {
          _updateTimer?.cancel();
          state = AsyncValue.error(e, st);
        },
      );
      
      // Periodic UI updates (every 1 second)
      _updateTimer = Timer.periodic(const Duration(seconds: 1), (_) {
        if (collectedHosts.isNotEmpty) {
           // We might want to sort them or just show as is
           state = AsyncValue.data(List.from(collectedHosts));
        }
      });
      
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
  
  Future<void> _resolveHostname(ScannedDevice device, List<ScannedDevice> currentList) async {
    try {
      final hostname = await device.activeHost.hostName;
      // device.activeHost.hostName returns null or empty string if failed?
      // Actually network_tools usually returns generic name if failed.
      // We check if we got something useful.
      
      if (hostname != null && hostname.isNotEmpty && hostname != device.ipAddress) {
        final index = currentList.indexOf(device);
        if (index != -1) {
            currentList[index] = ScannedDevice(
              activeHost: device.activeHost,
              ipAddress: device.ipAddress,
              hostname: hostname
            );
            // State update will happen on next timer tick
        }
      }
    } catch (e) {
      // Ignore resolution errors
    }
  }
  
  void stopScan() {
    _subscription?.cancel();
    _updateTimer?.cancel();
  }
}
