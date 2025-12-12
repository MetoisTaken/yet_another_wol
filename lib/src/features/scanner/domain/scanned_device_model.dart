import 'package:network_tools/network_tools.dart';

class ScannedDevice {
  final ActiveHost activeHost;
  final String? hostname;
  final String? ipAddress;

  ScannedDevice({
    required this.activeHost,
    this.hostname,
    this.ipAddress,
  });
}
