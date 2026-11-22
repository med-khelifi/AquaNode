import 'package:flutter/material.dart';
import 'package:aqua_node/core/widgets/status_chip.dart';
import 'package:aqua_node/data/models/device.dart';
import 'package:aqua_node/state/app_state.dart';

class ValveScreen extends StatefulWidget {
  final Device d;
  const ValveScreen(this.d, {super.key});
  @override
  State<ValveScreen> createState() => _ValveState();
}

class _ValveState extends State<ValveScreen> {
  Future<void> _request(bool open) async {
    final d = widget.d;
    final ok = await showDialog<bool>(context: context, builder: (c) => AlertDialog(
      icon: Icon(open ? Icons.lock_open : Icons.lock),
      title: Text('${open ? 'Open' : 'Close'} valve?'),
      content: Text('Send a request to ${d.name}. Confirm the physical valve state on site.'),
      actions: [TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Cancel')),
        FilledButton(onPressed: () => Navigator.pop(c, true), child: Text(open ? 'Open' : 'Close'))]));
    if (ok != true) return;
    final res = await store.setValve(d, open);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(res ? 'Valve ${open ? 'open' : 'closed'} confirmed by device.' : 'Device did not confirm the command.')));
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(listenable: store, builder: (context, _) {
        final d = widget.d;
        final pending = d.verify == Verify.pending;
        final canSend = d.enabled && d.conn == Conn.online && !pending;
        return Scaffold(
          appBar: AppBar(title: const Text('Valve control')),
          body: ListView(padding: const EdgeInsets.all(16), children: [
            Card(child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(d.name, style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 10), valveChip(context, d),
              if (pending) ...[const SizedBox(height: 14), const LinearProgressIndicator(), const SizedBox(height: 6),
                Text('Waiting for the device to confirm…', style: TextStyle(color: tk(context).muted))],
              if (d.verify == Verify.failed) ...[const SizedBox(height: 14),
                Row(children: [Icon(Icons.error, color: tk(context).error, size: 18), const SizedBox(width: 8),
                  Expanded(child: Text('Command not confirmed. Check the valve on site.', style: TextStyle(color: tk(context).error)))])],
            ]))),
            const SizedBox(height: 12),
            Row(children: [
              Expanded(child: FilledButton.icon(icon: const Icon(Icons.lock_open), label: const Text('Open'), onPressed: canSend ? () => _request(true) : null)),
              const SizedBox(width: 12),
              Expanded(child: OutlinedButton.icon(icon: const Icon(Icons.lock), label: const Text('Close'), onPressed: canSend ? () => _request(false) : null)),
            ]),
            if (!canSend && !pending) Padding(padding: const EdgeInsets.only(top: 10),
                child: Text(d.enabled ? 'Device must be online to send commands.' : 'Device is disabled.', style: TextStyle(color: tk(context).muted))),
            const SizedBox(height: 16),
            Container(padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: tk(context).warning.withValues(alpha: .12), borderRadius: BorderRadius.circular(12)),
              child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Icon(Icons.warning_amber, color: tk(context).warning), const SizedBox(width: 10),
                const Expanded(child: Text('This app shows the requested state and the device report. It cannot see the physical valve. Always verify on site when it matters.')),
              ])),
          ]),
        );
      });
}
