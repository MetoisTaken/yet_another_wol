import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

part 'device.g.dart';

@HiveType(typeId: 0)
class Device extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String macAddress;

  @HiveField(2)
  final String? ipAddress; // Optional for WoL but needed for Ping/Scan

  @HiveField(3)
  final String alias;

  @HiveField(4)
  final int port;

  @HiveField(5)
  bool isOnline;

  @HiveField(6, defaultValue: false)
  final bool isFavorite;

  Device({
    String? id,
    required this.macAddress,
    this.ipAddress,
    required this.alias,
    this.port = 9,
    this.isOnline = false,
    this.isFavorite = false,
  }) : id = id ?? const Uuid().v4();

  Device copyWith({
    String? macAddress,
    String? ipAddress,
    String? alias,
    int? port,
    bool? isOnline,
    bool? isFavorite,
  }) {
    return Device(
      id: id,
      macAddress: macAddress ?? this.macAddress,
      ipAddress: ipAddress ?? this.ipAddress,
      alias: alias ?? this.alias,
      port: port ?? this.port,
      isOnline: isOnline ?? this.isOnline,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }
}
