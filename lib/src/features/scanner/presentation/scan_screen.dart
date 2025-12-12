import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yet_another_wol/src/features/scanner/presentation/scanner_controller.dart';
import 'package:yet_another_wol/src/features/devices/presentation/add_device_sheet.dart';

class ScanScreen extends ConsumerStatefulWidget {
  const ScanScreen({super.key});

  @override
  ConsumerState<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends ConsumerState<ScanScreen> {
  bool _scanStarted = false;
  
  @override
  void initState() {
    super.initState();
    // Delay scan start to allow UI to render first
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted && !_scanStarted) {
        _scanStarted = true;
        ref.read(scannerControllerProvider.notifier).startScan();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final scanState = ref.watch(scannerControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan Network'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.read(scannerControllerProvider.notifier).startScan();
            },
          ),
        ],
      ),
      body: scanState.when(
        data: (scanResults) {
          if (scanResults.isEmpty && !_scanStarted) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.radar, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('Preparing scanner...'),
                ],
              ),
            );
          }
          
          if (scanResults.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Scanning network...'),
                ],
              ),
            );
          }
          
          return ListView.builder(
            itemCount: scanResults.length,
            itemBuilder: (context, index) {
              final device = scanResults[index];
              return ListTile(
                leading: const Icon(Icons.lan),
                title: Text(device.hostname ?? device.ipAddress ?? "Unknown"),
                subtitle: device.hostname != null 
                    ? Text(device.ipAddress ?? "") 
                    : const Text("Tap + to setup"),
                trailing: IconButton(
                  icon: const Icon(Icons.add_circle_outline),
                  onPressed: () async {
                    final arp = await device.activeHost.arpData;
                    final mac = arp?.macAddress; 
                    
                    // Fallback if not resolved yet
                    final alias = device.hostname ?? await device.activeHost.hostName;

                    if (context.mounted) {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        builder: (_) => AddDeviceSheet(
                          initialIp: device.ipAddress,
                          initialMac: mac,
                          initialAlias: alias,
                        ),
                      );
                    }
                  },
                ),
              );
            },
          );
        },
        loading: () => const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Initializing scanner...'),
            ],
          ),
        ),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Text('Error: $error'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  ref.read(scannerControllerProvider.notifier).startScan();
                },
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
