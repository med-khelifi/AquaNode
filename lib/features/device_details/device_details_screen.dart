import 'package:flutter/material.dart';
import 'package:aqua_node/core/utils/format.dart';
import 'package:aqua_node/core/widgets/status_chip.dart';
import 'package:aqua_node/data/models/device.dart';
import 'package:aqua_node/state/app_state.dart';
import 'package:aqua_node/features/history/history_screen.dart';
import 'package:aqua_node/features/valve/valve_screen.dart';
import 'package:aqua_node/features/device_settings/device_settings_screen.dart';

class DeviceDetailsScreen extends StatelessWidget {
  final Device d;
  const DeviceDetailsScreen(this.d, {super.key});
  @override
  Widget build(BuildContext context) => ListenableBuilder(listenable: store, builder: (context, _) {
        final m = tk(context).muted;
        return Scaffold(
          appBar: AppBar(title: Text(d.name), actions: [
            IconButton(tooltip: 'Device settings', icon: const Icon(Icons.tune),
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => DeviceSettingsScreen(d)))),
          ]),
          body: ListView(padding: const EdgeInsets.all(16), children: [
            Row(children: [connChip(context, d.conn), const SizedBox(width: 10), Text(d.id, style: TextStyle(color: m))]),
            if (!d.enabled) Padding(padding: const EdgeInsets.only(top: 10),
                child: StatusChip('Disabled', Icons.block, tk(context).warning)),
            const SizedBox(height: 16),
            Row(children: [
              _Reading('Temperature', d.conn == Conn.never ? '—' : store.temp(d.temp), Icons.thermostat),
              const SizedBox(width: 12),
              _Reading('Humidity', d.conn == Conn.never ? '—' : '${d.hum.toStringAsFixed(0)} %', Icons.water_drop_outlined),
            ]),
            const SizedBox(height: 12),
            Card(child: Column(children: [
              ListTile(leading: const Icon(Icons.wifi), title: const Text('Connection age'),
                  trailing: Text(d.lastSeen == null ? 'Never' : ago(d.lastSeen))),
              const Divider(height: 1),
              ListTile(leading: const Icon(Icons.update), title: const Text('Last update'),
                  trailing: Text(d.lastSeen == null ? '—' : '${d.lastSeen!.hour.toString().padLeft(2, '0')}:${d.lastSeen!.minute.toString().padLeft(2, '0')}')),
            ])),
            const SizedBox(height: 12),
            Card(child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Valve', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 10), valveChip(context, d), const SizedBox(height: 14),
              OutlinedButton.icon(icon: const Icon(Icons.toggle_on_outlined), label: const Text('Control valve'),
                  onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ValveScreen(d)))),
            ]))),
            const SizedBox(height: 12),
            FilledButton.icon(icon: const Icon(Icons.show_chart), label: const Text('View history'),
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => HistoryScreen(d)))),
          ]),
        );
      });
}

class _Reading extends StatelessWidget {
  final String label, value; final IconData icon;
  const _Reading(this.label, this.value, this.icon);
  @override
  Widget build(BuildContext context) => Expanded(child: Card(child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [Icon(icon, size: 18, color: tk(context).muted), const SizedBox(width: 6), Text(label, style: TextStyle(color: tk(context).muted))]),
        const SizedBox(height: 8),
        Text(value, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700)),
      ]))));
}
