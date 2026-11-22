import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:aqua_node/core/utils/format.dart';
import 'package:aqua_node/core/widgets/status_chip.dart';
import 'package:aqua_node/data/models/device.dart';
import 'package:aqua_node/features/dashboard/cubit/devices_cubit.dart';
import 'package:aqua_node/features/device_settings/device_settings_screen.dart';
import 'package:aqua_node/features/history/history_screen.dart';
import 'package:aqua_node/features/settings/cubit/settings_cubit.dart';
import 'package:aqua_node/features/valve/valve_screen.dart';

class DeviceDetailsScreen extends StatelessWidget {
  final Device initialDevice;

  const DeviceDetailsScreen(this.initialDevice, {super.key});

  @override
  Widget build(BuildContext context) {
    final m = tk(context).muted;
    return BlocBuilder<DevicesCubit, DevicesState>(
      builder: (context, devicesState) {
        final d = devicesState.findDevice(initialDevice.id) ?? initialDevice;

        return Scaffold(
          appBar: AppBar(title: Text(d.name)),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Row(
                children: [
                  connChip(context, d.conn),
                  const SizedBox(width: 10),
                  Text(d.id, style: TextStyle(color: m)),
                  const Spacer(),
                  if (!d.enabled)
                    Tooltip(
                      message: 'Device is disabled in settings',
                      child: StatusChip(
                        'Disabled',
                        Icons.block,
                        tk(context).warning,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              BlocBuilder<SettingsCubit, SettingsState>(
                builder: (context, settingsState) {
                  return Row(
                    children: [
                      Expanded(
                        child: _Reading(
                          'Temperature',
                          d.conn == Conn.never
                              ? '—'
                              : settingsState.formatTemp(d.temp),
                          Icons.thermostat,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _Reading(
                          'Humidity',
                          d.conn == Conn.never
                              ? '—'
                              : '${d.hum.toStringAsFixed(0)} %',
                          Icons.water,
                        ),
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _Row('Location', d.location),
                      _Row('Firmware', d.firmware),
                      _Row('Last seen', ago(d.lastSeen)),
                      _Row('Valve status', null, widget: valveChip(context, d)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Card(
                child: ListTile(
                  leading: const Icon(Icons.tune),
                  title: const Text('Valve & Relay Control'),
                  subtitle: Text(d.valveOpen ? 'Open' : 'Closed'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => ValveScreen(d)),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Card(
                child: ListTile(
                  leading: const Icon(Icons.show_chart),
                  title: const Text('History'),
                  subtitle: const Text('View temperature and humidity trends'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => HistoryScreen(d)),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Card(
                child: ListTile(
                  leading: const Icon(Icons.settings_outlined),
                  title: const Text('Device Settings'),
                  subtitle:
                      const Text('Rename, move location, firmware info'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => DeviceSettingsScreen(d)),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _Reading extends StatelessWidget {
  final String label, value;
  final IconData icon;

  const _Reading(this.label, this.value, this.icon);

  @override
  Widget build(BuildContext context) => Card(
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, size: 18, color: tk(context).muted),
                  const SizedBox(width: 6),
                  Text(label, style: TextStyle(color: tk(context).muted)),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                value,
                style: Theme.of(context)
                    .textTheme
                    .headlineSmall
                    ?.copyWith(fontWeight: FontWeight.w700),
              ),
            ],
          ),
        ),
      );
}

class _Row extends StatelessWidget {
  final String label;
  final String? value;
  final Widget? widget;

  const _Row(this.label, this.value, {this.widget});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          children: [
            Text(label, style: TextStyle(color: tk(context).muted)),
            const Spacer(),
            widget ??
                Text(
                  value ?? '',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
          ],
        ),
      );
}
