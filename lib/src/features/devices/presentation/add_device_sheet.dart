import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yet_another_wol/src/features/devices/domain/device.dart';
import 'package:yet_another_wol/src/features/devices/presentation/device_controller.dart';
import 'package:yet_another_wol/src/core/utils/formatters/mac_address_formatter.dart';

class AddDeviceSheet extends ConsumerStatefulWidget {
  final String? initialIp;
  final String? initialMac;
  final String? initialAlias;
  final Device? deviceToEdit;

  const AddDeviceSheet({
    super.key,
    this.initialIp,
    this.initialMac,
    this.initialAlias,
    this.deviceToEdit,
  });

  @override
  ConsumerState<AddDeviceSheet> createState() => _AddDeviceSheetState();
}

class _AddDeviceSheetState extends ConsumerState<AddDeviceSheet> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _aliasController;
  late TextEditingController _macController;
  late TextEditingController _ipController;
  
  @override
  void initState() {
    super.initState();
    _aliasController = TextEditingController(text: widget.deviceToEdit?.alias ?? widget.initialAlias);
    _macController = TextEditingController(text: widget.deviceToEdit?.macAddress ?? widget.initialMac);
    _ipController = TextEditingController(text: widget.deviceToEdit?.ipAddress ?? widget.initialIp);
  }

  @override
  void dispose() {
    _aliasController.dispose();
    _macController.dispose();
    _ipController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    
    final isEditing = widget.deviceToEdit != null;
    
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 16,
        right: 16,
        top: 16,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(isEditing ? "Edit Device" : "Add New Device", style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 16),
              TextFormField(
                controller: _aliasController,
                decoration: const InputDecoration(labelText: 'Alias (Name)'),
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
              TextFormField(
                controller: _macController,
                decoration: const InputDecoration(labelText: 'MAC Address (XX:XX:XX:XX:XX:XX)'),
                inputFormatters: [
                  MacAddressInputFormatter(),
                ],
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
               TextFormField(
                controller: _ipController,
                decoration: const InputDecoration(labelText: 'IP Address (Optional)'),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    if (isEditing) {
                        final updatedDevice = widget.deviceToEdit!.copyWith(
                           alias: _aliasController.text,
                           macAddress: _macController.text,
                           ipAddress: _ipController.text.isEmpty ? null : _ipController.text,
                        );
                        ref.read(deviceControllerProvider.notifier).updateDevice(updatedDevice);
                    } else {
                        final device = Device(
                          macAddress: _macController.text,
                          alias: _aliasController.text,
                          ipAddress: _ipController.text.isEmpty ? null : _ipController.text,
                        );
                        ref.read(deviceControllerProvider.notifier).addDevice(device);
                    }
                    Navigator.pop(context);
                  }
                },
                child: const Text("Save"),
              ),
              if (isEditing) ...[
                const SizedBox(height: 16),
                TextButton.icon(
                  onPressed: () {
                     ref.read(deviceControllerProvider.notifier).deleteDevice(widget.deviceToEdit!.id);
                     Navigator.pop(context, 'deleted');
                  },
                  icon: const Icon(Icons.delete, color: Colors.red),
                  label: const Text("Delete Device", style: TextStyle(color: Colors.red)),
                ),
              ],
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
