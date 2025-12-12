import 'package:hive_flutter/hive_flutter.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:yet_another_wol/src/features/devices/domain/device.dart';

part 'device_repository.g.dart';

@Riverpod(keepAlive: true)
DeviceRepository deviceRepository(DeviceRepositoryRef ref) {
  return DeviceRepository();
}

class DeviceRepository {
  static const String boxName = 'devices';

  Future<void> init() async {
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(DeviceAdapter());
    }
    if (!Hive.isBoxOpen(boxName)) {
      await Hive.openBox<Device>(boxName);
    }
  }

  Box<Device> get _box => Hive.box<Device>(boxName);

  List<Device> getAllDevices() {
    return _box.values.toList();
  }

  Future<void> addDevice(Device device) async {
    await _box.put(device.id, device); // Use ID as key
  }

  Future<void> updateDevice(Device device) async {
    await _box.put(device.id, device);
  }

  Future<void> deleteDevice(String id) async {
    await _box.delete(id);
  }

  Future<void> deleteFavoriteDevices() async {
    final favorites = _box.values
        .where((d) => d.isFavorite)
        .map((d) => d.id)
        .toList();
    await _box.deleteAll(favorites);
  }

  Future<void> deleteAllDevices() async {
    await _box.clear();
  }
}
