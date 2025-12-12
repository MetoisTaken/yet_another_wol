import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:yet_another_wol/src/features/devices/data/device_repository.dart';
import 'package:yet_another_wol/src/features/devices/domain/device.dart';
import 'package:wake_on_lan/wake_on_lan.dart';

part 'device_controller.g.dart';

@riverpod
class DeviceController extends _$DeviceController {
  @override
  List<Device> build() {
    // Initial load from repository
    return ref.read(deviceRepositoryProvider).getAllDevices();
  }

  Future<void> addDevice(Device device) async {
    await ref.read(deviceRepositoryProvider).addDevice(device);
    // Refresh list
    state = ref.read(deviceRepositoryProvider).getAllDevices();
  }

  Future<void> updateDevice(Device device) async {
    await ref.read(deviceRepositoryProvider).updateDevice(device);
    state = ref.read(deviceRepositoryProvider).getAllDevices();
  }

  Future<void> deleteDevice(String id) async {
    await ref.read(deviceRepositoryProvider).deleteDevice(id);
    state = ref.read(deviceRepositoryProvider).getAllDevices();
  }

  Future<void> wakeDevice(Device device) async {
    // Send WoL packet
    // MAC address format: XX:XX:XX:XX:XX:XX
    if (MACAddress.validate(device.macAddress).state) {
      final mac = MACAddress(device.macAddress);
      // Determine broadcast address - usually 255.255.255.255 is safe for local network
      // But ideally we should calculate it from IP and Subnet.
      // For now, use global broadcast.
      // Use IPAddress class from wake_on_lan (exported via wake_on_lan.dart)
      final ipv4 = IPAddress('255.255.255.255');
      await WakeOnLAN(ipv4, mac, port: device.port).wake();
    } else {}
  }

  Future<void> wakeAllDevices() async {
    for (var device in state) {
      await wakeDevice(device);
    }
  }
}
