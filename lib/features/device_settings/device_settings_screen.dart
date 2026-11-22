import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:aqua_node/data/models/device.dart';
import 'package:aqua_node/features/dashboard/cubit/devices_cubit.dart';

class DeviceSettingsScreen extends StatelessWidget {
  final Device initialDevice;

  const DeviceSettingsScreen(this.initialDevice, {super.key});

  Future<void> _edit(
    BuildContext context,
    String title,
    String initial,
    void Function(String) save,
  ) async {
    final c = TextEditingController(text: initial);
    final v = await showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: TextField(controller: c, autofocus: true),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(c.text.trim()),
            child: const Text('Save'),
          ),
        ],
      ),
    );
    if (v != null && v.isNotEmpty) {
      save(v);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DevicesCubit, DevicesState>(
      builder: (context, state) {
        final d = state.findDevice(initialDevice.id) ?? initialDevice;

        return Scaffold(
          appBar: AppBar(title: const Text('Device Settings')),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Card(
                child: Column(
                  children: [
                    ListTile(
                      title: const Text('Device name'),
                      subtitle: Text(d.name),
                      trailing: const Icon(Icons.edit_outlined),
                      onTap: () => _edit(context, 'Edit name', d.name, (v) {
                        d.name = v;
                        context.read<DevicesCubit>().updateDevice(d);
                      }),
                    ),
                    const Divider(height: 1),
                    ListTile(
                      title: const Text('Location'),
                      subtitle: Text(d.location),
                      trailing: const Icon(Icons.edit_outlined),
                      onTap: () => _edit(context, 'Edit location', d.location, (v) {
                        d.location = v;
                        context.read<DevicesCubit>().updateDevice(d);
                      }),
                    ),
                    const Divider(height: 1),
                    SwitchListTile(
                      title: const Text('Device enabled'),
                      subtitle:
                          const Text('When disabled, valve commands are blocked'),
                      value: d.enabled,
                      onChanged: (v) {
                        d.enabled = v;
                        context.read<DevicesCubit>().updateDevice(d);
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Card(
                child: Column(
                  children: [
                    ListTile(title: const Text('Hardware ID'), subtitle: Text(d.id)),
                    const Divider(height: 1),
                    ListTile(
                      title: const Text('Firmware version'),
                      subtitle: Text(d.firmware),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
