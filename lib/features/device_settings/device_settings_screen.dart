import 'package:flutter/material.dart';
import 'package:aqua_node/data/models/device.dart';
import 'package:aqua_node/state/app_state.dart';

class DeviceSettingsScreen extends StatelessWidget {
  final Device d;
  const DeviceSettingsScreen(this.d, {super.key});

  Future<void> _edit(BuildContext context, String title, String initial, void Function(String) save) async {
    final c = TextEditingController(text: initial);
    final v = await showDialog<String>(context: context, builder: (x) => AlertDialog(
      title: Text(title), content: TextField(controller: c, autofocus: true),
      actions: [TextButton(onPressed: () => Navigator.pop(x), child: const Text('Cancel')),
        FilledButton(onPressed: () => Navigator.pop(x, c.text.trim()), child: const Text('Save'))]));
    if (v != null && v.isNotEmpty) { save(v); store.touch(); }
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(listenable: store, builder: (context, _) => Scaffold(
        appBar: AppBar(title: const Text('Device settings')),
        body: ListView(padding: const EdgeInsets.all(16), children: [
          Card(child: Column(children: [
            ListTile(leading: const Icon(Icons.edit_outlined), title: const Text('Name'), subtitle: Text(d.name),
                onTap: () => _edit(context, 'Rename device', d.name, (v) => d.name = v)),
            const Divider(height: 1),
            ListTile(leading: const Icon(Icons.place_outlined), title: const Text('Location label'), subtitle: Text(d.location),
                onTap: () => _edit(context, 'Location label', d.location, (v) => d.location = v)),
            const Divider(height: 1),
            ListTile(leading: const Icon(Icons.fingerprint), title: const Text('Device ID'), subtitle: Text(d.id)),
            const Divider(height: 1),
            ListTile(leading: const Icon(Icons.memory), title: const Text('Firmware'), subtitle: Text('v${d.firmware}')),
            const Divider(height: 1),
            SwitchListTile(secondary: const Icon(Icons.power_settings_new), title: const Text('Enabled'),
                subtitle: Text(d.enabled ? 'Device accepts commands' : 'Commands are blocked'),
                value: d.enabled, onChanged: (v) { d.enabled = v; store.touch(); }),
          ])),
          const SizedBox(height: 12),
          Card(child: ListTile(leading: const Icon(Icons.wifi_tethering), title: const Text('Network provisioning'),
              subtitle: const Text('Connect this device to Wi-Fi'), trailing: const Icon(Icons.chevron_right),
              onTap: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Provisioning flow is not implemented yet.'))))),
        ]),
      ));
}
