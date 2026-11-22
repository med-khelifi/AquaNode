import 'package:flutter/material.dart';
import 'package:aqua_node/core/widgets/status_chip.dart';
import 'package:aqua_node/core/widgets/state_message.dart';
import 'package:aqua_node/data/models/device.dart';
import 'package:aqua_node/state/app_state.dart';
import 'package:aqua_node/features/settings/app_settings_screen.dart';
import 'package:aqua_node/features/dashboard/widgets/device_card.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});
  @override
  State<DashboardScreen> createState() => _DashState();
}

class _DashState extends State<DashboardScreen> {
  String _q = ''; Conn? _filter;

  @override
  Widget build(BuildContext context) => ListenableBuilder(listenable: store, builder: (context, _) {
        final all = store.devices;
        final online = all.where((d) => d.conn == Conn.online).length;
        final offline = all.where((d) => d.conn == Conn.offline).length;
        final list = all.where((d) =>
            (_filter == null || d.conn == _filter) &&
            (d.name.toLowerCase().contains(_q.toLowerCase()) || d.id.toLowerCase().contains(_q.toLowerCase()))).toList();
        return Scaffold(
          appBar: AppBar(title: const Text('Devices'), actions: [
            IconButton(tooltip: 'Settings', icon: const Icon(Icons.settings_outlined),
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AppSettingsScreen()))),
          ]),
          body: ListView(padding: const EdgeInsets.all(16), children: [
            Row(children: [
              DashStat('Total', '${all.length}', Icons.sensors, Theme.of(context).colorScheme.primary),
              const SizedBox(width: 10), DashStat('Online', '$online', Icons.check_circle, tk(context).success),
              const SizedBox(width: 10), DashStat('Offline', '$offline', Icons.cancel, tk(context).error),
            ]),
            const SizedBox(height: 16),
            TextField(onChanged: (v) => setState(() => _q = v),
                decoration: const InputDecoration(hintText: 'Search name or device ID', prefixIcon: Icon(Icons.search))),
            const SizedBox(height: 10),
            Wrap(spacing: 8, children: [
              for (final f in <(String, Conn?)>[('All', null), ('Online', Conn.online), ('Offline', Conn.offline), ('Never connected', Conn.never)])
                ChoiceChip(label: Text(f.$1), selected: _filter == f.$2, onSelected: (_) => setState(() => _filter = f.$2)),
            ]),
            const SizedBox(height: 12),
            if (list.isEmpty)
              const Padding(padding: EdgeInsets.only(top: 48), child: StateMessage(Icons.search_off, 'No devices found', 'Try a different search or filter.'))
            else
              for (final d in list) Padding(padding: const EdgeInsets.only(bottom: 12), child: DeviceCard(d)),
          ]),
        );
      });
}


