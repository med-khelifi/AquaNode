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
  final VoidCallback? onTap;

  const DashStat(
    this.label,
    this.value,
    this.icon,
    this.color, {
    super.key,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) => Expanded(
        child: Card(
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, color: color, size: 20),
                  const SizedBox(height: 6),
                  Text(
                    value,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context)
                        .textTheme
                        .headlineSmall
                        ?.copyWith(fontWeight: FontWeight.w700),
                  ),
                  Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: tk(context).muted, fontSize: 12),
                  ),
                ],
              ),
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
              // Top Row: Name and connection chip
              Row(
                children: [
                  Expanded(
                    child: Text(
                      d.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(fontWeight: FontWeight.w600),
                    ),
                  ),
                  const SizedBox(width: 8),
                  connChip(context, d.conn),
                ],
              ),
              const SizedBox(height: 4),

              // Sub-header: ID, optional location, and disabled badge
              Row(
                children: [
                  Text(d.id, style: TextStyle(color: m, fontSize: 12.5)),
                  if (d.location.isNotEmpty) ...[
                    Text(' • ', style: TextStyle(color: m, fontSize: 12.5)),
                    Icon(Icons.location_on_outlined, size: 13, color: m),
                    const SizedBox(width: 2),
                    Flexible(
                      child: Text(
                        d.location,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: m, fontSize: 12.5),
                      ),
                    ),
                  ],
                  const Spacer(),
                  if (!d.enabled)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                      decoration: BoxDecoration(
                        color: tk(context).warning.withValues(alpha: .15),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'Disabled',
                        style: TextStyle(
                          color: tk(context).warning,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),

              // Telemetry & Valve status
              if (d.conn != Conn.never) ...[
                Wrap(
                  alignment: WrapAlignment.spaceBetween,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 12,
                  runSpacing: 8,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.thermostat_outlined, size: 18, color: m),
                        const SizedBox(width: 4),
                        BlocBuilder<SettingsCubit, SettingsState>(
                          builder: (context, state) => Text(
                            state.formatTemp(d.temp),
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Icon(Icons.water_drop_outlined, size: 18, color: m),
                        const SizedBox(width: 4),
                        Text(
                          '${d.hum.toStringAsFixed(0)}%',
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                    valveChip(context, d),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.access_time, size: 13, color: m),
                    const SizedBox(width: 4),
                    Text(
                      'Last seen: ${ago(d.lastSeen)}',
                      style: TextStyle(color: m, fontSize: 12),
                    ),
                  ],
                ),
              ] else
                Row(
                  children: [
                    Icon(Icons.cloud_off_outlined, size: 16, color: m),
                    const SizedBox(width: 6),
                    Text(
                      'No readings yet',
                      style: TextStyle(color: m, fontSize: 12.5),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}
