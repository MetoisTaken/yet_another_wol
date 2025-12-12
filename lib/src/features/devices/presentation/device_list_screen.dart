import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yet_another_wol/src/features/scanner/presentation/scan_screen.dart';
import 'package:yet_another_wol/src/features/devices/presentation/device_controller.dart';
import 'package:yet_another_wol/src/features/devices/presentation/pinger_controller.dart';
import 'package:yet_another_wol/src/features/devices/presentation/add_device_sheet.dart';
import 'package:yet_another_wol/src/features/devices/domain/device.dart';

class DeviceListScreen extends ConsumerWidget {
  const DeviceListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final devices = ref.watch(deviceControllerProvider);
    final pingerState = ref.watch(pingerControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Yet Another WoL'),
        actions: [
          IconButton(
            tooltip: "Wake Favorites",
            icon: const Icon(Icons.star, color: Colors.amber),
            onPressed: () {
              ref.read(deviceControllerProvider.notifier).wakeFavoriteDevices();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Waking favorite devices...')),
              );
            },
          ),
          IconButton(
            tooltip: "Wake All Devices",
            icon: const Icon(Icons.bolt, color: Colors.orange),
            onPressed: () {
              ref.read(deviceControllerProvider.notifier).wakeAllDevices();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Waking all devices...')),
              );
            },
          ),
          IconButton(
            tooltip: "Scan Network",
            icon: const Icon(Icons.radar),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const ScanScreen()),
              );
            },
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'deleteAll') {
                _confirmDelete(context, ref, 'All', () {
                  ref
                      .read(deviceControllerProvider.notifier)
                      .deleteAllDevices();
                });
              } else if (value == 'deleteFavorites') {
                _confirmDelete(context, ref, 'Favorite', () {
                  ref
                      .read(deviceControllerProvider.notifier)
                      .deleteFavoriteDevices();
                });
              }
            },
            itemBuilder: (BuildContext context) {
              return [
                const PopupMenuItem(
                  value: 'deleteFavorites',
                  child: Row(
                    children: [
                      Icon(Icons.star_border, color: Colors.grey),
                      SizedBox(width: 8),
                      Text('Remove Favorites'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'deleteAll',
                  child: Row(
                    children: [
                      Icon(Icons.delete_forever, color: Colors.red),
                      SizedBox(width: 8),
                      Text(
                        'Remove All Devices',
                        style: TextStyle(color: Colors.red),
                      ),
                    ],
                  ),
                ),
              ];
            },
          ),
        ],
      ),
      body: devices.isEmpty
          ? const Center(child: Text("No devices found. Add one!"))
          : RefreshIndicator(
              onRefresh: () async {
                await ref.read(pingerControllerProvider.notifier).pingAll();
              },
              child: ListView.builder(
                itemCount: devices.length,
                itemBuilder: (context, index) {
                  final device = devices[index];
                  final isOnline = pingerState[device.id] ?? false;

                  return Dismissible(
                    key: Key(device.id),
                    background: Container(color: Colors.red),
                    onDismissed: (_) {
                      ref
                          .read(deviceControllerProvider.notifier)
                          .deleteDevice(device.id);
                      _showUndoSnackBar(context, ref, device);
                    },
                    child: ListTile(
                      onTap: () {
                        ref
                            .read(deviceControllerProvider.notifier)
                            .wakeDevice(device);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Sent Magic Packet to ${device.alias}',
                            ),
                          ),
                        );
                      },
                      onLongPress: () async {
                        final result = await showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          builder: (_) => AddDeviceSheet(deviceToEdit: device),
                        );

                        if (result == 'deleted') {
                          if (context.mounted) {
                            _showUndoSnackBar(context, ref, device);
                          }
                        }
                      },
                      leading: Stack(
                        children: [
                          const CircleAvatar(child: Icon(Icons.computer)),
                          Positioned(
                            right: 0,
                            bottom: 0,
                            child: Container(
                              width: 12,
                              height: 12,
                              decoration: BoxDecoration(
                                color: isOnline ? Colors.green : Colors.red,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white,
                                  width: 2,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      title: Text(device.alias),
                      subtitle: Text(device.ipAddress ?? device.macAddress),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(
                              device.isFavorite
                                  ? Icons.star
                                  : Icons.star_border,
                              color: device.isFavorite
                                  ? Colors.amber
                                  : Colors.grey,
                            ),
                            onPressed: () async {
                              final success = await ref
                                  .read(deviceControllerProvider.notifier)
                                  .toggleFavorite(device);

                              if (!success && context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'iOS limit reached: Max 2 favorites.',
                                    ),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.power_settings_new),
                            color: isOnline ? Colors.green : Colors.grey,
                            onPressed: () {
                              ref
                                  .read(deviceControllerProvider.notifier)
                                  .wakeDevice(device);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Sent Magic Packet to ${device.alias}',
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            builder: (_) => const AddDeviceSheet(),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  void _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    String type,
    VoidCallback onDelete,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Delete $type Devices?'),
        content: Text(
          'Are you sure you want to delete $type devices? This cannot be undone from here.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              onDelete();
              Navigator.pop(ctx);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showUndoSnackBar(BuildContext context, WidgetRef ref, Device device) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${device.alias} deleted'),
        action: SnackBarAction(
          label: 'UNDO',
          onPressed: () {
            ref.read(deviceControllerProvider.notifier).addDevice(device);
          },
        ),
      ),
    );
  }
}
