import 'package:flutter/material.dart';
import 'package:aqua_node/core/utils/format.dart';
import 'package:aqua_node/core/widgets/status_chip.dart';
import 'package:aqua_node/data/models/device.dart';
import 'package:aqua_node/state/app_state.dart';
import 'package:aqua_node/features/device_details/device_details_screen.dart';

class DashStat extends StatelessWidget {
  final String label, value; final IconData icon; final Color color;
  const DashStat(this.label, this.value, this.icon, this.color, {super.key});
  @override
  Widget build(BuildContext context) => Expanded(child: Card(child: Padding(padding: const EdgeInsets.all(12), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Icon(icon, color: color, size: 20), const SizedBox(height: 6),
        Text(value, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700)),
        Text(label, style: TextStyle(color: tk(context).muted, fontSize: 12.5)),
      ]))));
}

class DeviceCard extends StatelessWidget {
  final Device d;
  const DeviceCard(this.d, {super.key});
  @override
  Widget build(BuildContext context) {
    final m = tk(context).muted;
    return Card(child: InkWell(borderRadius: BorderRadius.circular(16),
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => DeviceDetailsScreen(d))),
      child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(d.name, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
            Text(d.id, style: TextStyle(color: m, fontSize: 12.5)),
          ])),
          Icon(Icons.chevron_right, color: m),
        ]),
        const SizedBox(height: 10),
        Wrap(spacing: 8, runSpacing: 6, crossAxisAlignment: WrapCrossAlignment.center, children: [
          connChip(context, d.conn),
          Text('Last seen: ${ago(d.lastSeen)}', style: TextStyle(color: m, fontSize: 12.5)),
        ]),
        const SizedBox(height: 12),
        if (d.conn == Conn.never)
          Text('No readings yet', style: TextStyle(color: m))
        else
          Row(children: [
            Icon(Icons.thermostat, size: 18, color: m), const SizedBox(width: 4), Text(store.temp(d.temp)),
            const SizedBox(width: 18),
            Icon(Icons.water_drop_outlined, size: 18, color: m), const SizedBox(width: 4), Text('${d.hum.toStringAsFixed(0)} %'),
          ]),
        const SizedBox(height: 10),
        valveChip(context, d),
      ])),
    ));
  }
}
