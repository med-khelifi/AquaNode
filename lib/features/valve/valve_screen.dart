import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:aqua_node/core/widgets/status_chip.dart';
import 'package:aqua_node/data/models/device.dart';
import 'package:aqua_node/features/dashboard/cubit/devices_cubit.dart';

class ValveScreen extends StatefulWidget {
  final Device initialDevice;

  const ValveScreen(this.initialDevice, {super.key});

  @override
  State<ValveScreen> createState() => _ValveState();
}

class _ValveState extends State<ValveScreen> {
  bool _busy = false;

  void _toggle(Device d, bool open) {
    setState(() => _busy = true);
    context.read<DevicesCubit>().toggleValve(d.id, open);
    setState(() => _busy = false);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DevicesCubit, DevicesState>(
      builder: (context, state) {
        final d = state.findDevice(widget.initialDevice.id) ?? widget.initialDevice;

        final canSend =
            d.conn == Conn.online && d.enabled && !_busy && d.verify != Verify.pending;

        return Scaffold(
          appBar: AppBar(title: const Text('Valve Control')),
          body: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        Icon(
                          d.valveOpen ? Icons.water : Icons.water_drop_outlined,
                          size: 48,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(height: 10),
                        Text(d.name, style: Theme.of(context).textTheme.titleMedium),
                        const SizedBox(height: 12),
                        valveChip(context, d),
                        if (d.verify == Verify.pending) ...[
                          const SizedBox(height: 14),
                          const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Waiting for the device to confirm…',
                            style: TextStyle(color: tk(context).muted),
                          ),
                        ],
                        if (d.verify == Verify.failed) ...[
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Icon(Icons.error, color: tk(context).error, size: 18),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Command not confirmed. Check the valve on site.',
                                  style: TextStyle(color: tk(context).error),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                const Spacer(),
                if (!d.enabled || d.conn != Conn.online)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Text(
                      d.enabled
                          ? 'Device must be online to send commands.'
                          : 'Device is disabled.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: tk(context).muted),
                    ),
                  ),
                if (d.verify == Verify.pending)
                  Container(
                    padding: const EdgeInsets.all(14),
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: tk(context).warning.withValues(alpha: .12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.warning_amber, color: tk(context).warning),
                        const SizedBox(width: 10),
                        const Expanded(
                          child: Text('A command is already in flight.'),
                        ),
                      ],
                    ),
                  ),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed:
                            canSend && d.valveOpen ? () => _toggle(d, false) : null,
                        child: const Text('Close valve'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton(
                        onPressed:
                            canSend && !d.valveOpen ? () => _toggle(d, true) : null,
                        child: const Text('Open valve'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
