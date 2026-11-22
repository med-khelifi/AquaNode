import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:aqua_node/core/utils/format.dart';
import 'package:aqua_node/core/widgets/status_chip.dart';
import 'package:aqua_node/data/models/device.dart';
import 'package:aqua_node/features/device_details/device_details_screen.dart';
import 'package:aqua_node/features/settings/cubit/settings_cubit.dart';

class DashStat extends StatelessWidget {
  final String label, value;
  final IconData icon;
  final Color color;

  const DashStat(this.label, this.value, this.icon, this.color, {super.key});

  @override
  Widget build(BuildContext context) => Expanded(
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(icon, color: color, size: 20),
                const SizedBox(height: 6),
                Text(
                  value,
                  style: Theme.of(context)
                      .textTheme
                      .headlineSmall
                      ?.copyWith(fontWeight: FontWeight.w700),
                ),
                Text(
                  label,
                  style: TextStyle(color: tk(context).muted, fontSize: 12.5),
                ),
              ],
            ),
          ),
        ),
      );
}

class DeviceCard extends StatelessWidget {
  final Device d;

  const DeviceCard(this.d, {super.key});

  @override
  Widget build(BuildContext context) {
    final m = tk(context).muted;
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => DeviceDetailsScreen(d)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      d.name,
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(fontWeight: FontWeight.w600),
                    ),
                  ),
                  connChip(context, d.conn),
                ],
              ),
              Text(d.id, style: TextStyle(color: m, fontSize: 12.5)),
              const SizedBox(height: 12),
              if (d.conn != Conn.never) ...[
                Row(
                  children: [
                    Icon(Icons.thermostat, size: 18, color: m),
                    const SizedBox(width: 4),
                    BlocBuilder<SettingsCubit, SettingsState>(
                      builder: (context, state) =>
                          Text(state.formatTemp(d.temp)),
                    ),
                    const SizedBox(width: 14),
                    Icon(Icons.water, size: 18, color: m),
                    const SizedBox(width: 4),
                    Text('${d.hum.toStringAsFixed(0)}%'),
                    const Spacer(),
                    valveChip(context, d),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Last seen: ${ago(d.lastSeen)}',
                  style: TextStyle(color: m, fontSize: 12.5),
                ),
              ] else
                Text('No readings yet', style: TextStyle(color: m)),
            ],
          ),
        ),
      ),
    );
  }
}
