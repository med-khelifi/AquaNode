import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:aqua_node/core/widgets/shimmer.dart';
import 'package:aqua_node/core/widgets/state_message.dart';
import 'package:aqua_node/core/widgets/status_chip.dart';
import 'package:aqua_node/features/dashboard/cubit/devices_cubit.dart';
import 'package:aqua_node/features/dashboard/widgets/device_card.dart';
import 'package:aqua_node/features/settings/app_settings_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashState();
}

class _DashState extends State<DashboardScreen> {
  String _q = '';
  String? _loc;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DevicesCubit, DevicesState>(
      builder: (context, state) {
        if (state.status == DevicesStatus.loading) {
          return const DashboardShimmer();
        }

        if (state.status == DevicesStatus.failure) {
          return Scaffold(
            appBar: AppBar(title: const Text('Aqua Node')),
            body: StateMessage(
              Icons.error_outline,
              'Error loading devices',
              state.errorMessage ?? 'An unexpected error occurred.',
              action: OutlinedButton(
                onPressed: () => context.read<DevicesCubit>().loadDevices(),
                child: const Text('Retry'),
              ),
            ),
          );
        }

        final all = state.devices;
        final online = state.onlineCount;
        final offline = state.offlineCount;
        final locs = {'All', ...all.map((d) => d.location)}.toList();
        final list = all.where((d) {
          final mQ = _q.isEmpty ||
              d.name.toLowerCase().contains(_q.toLowerCase()) ||
              d.id.toLowerCase().contains(_q.toLowerCase());
          final mL = _loc == null || _loc == 'All' || d.location == _loc;
          return mQ && mL;
        }).toList();

        return Scaffold(
          appBar: AppBar(
            title: const Text('Aqua Node'),
            actions: [
              IconButton(
                icon: const Icon(Icons.settings_outlined),
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const AppSettingsScreen(),
                  ),
                ),
              ),
            ],
          ),
          body: RefreshIndicator(
            onRefresh: () => context.read<DevicesCubit>().loadDevices(),
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Row(
                  children: [
                    DashStat(
                      'Total Nodes',
                      '${all.length}',
                      Icons.sensors,
                      Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 10),
                    DashStat('Online', '$online', Icons.check_circle, tk(context).success),
                    const SizedBox(width: 10),
                    DashStat('Offline', '$offline', Icons.cancel, tk(context).error),
                  ],
                ),
                const SizedBox(height: 16),
                TextField(
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.search),
                    hintText: 'Search by name or ID…',
                  ),
                  onChanged: (v) => setState(() => _q = v),
                ),
                const SizedBox(height: 10),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: locs
                        .map(
                          (l) => Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: FilterChip(
                              label: Text(l),
                              selected: (_loc ?? 'All') == l,
                              onSelected: (_) => setState(() => _loc = l),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ),
                const SizedBox(height: 12),
                if (list.isEmpty)
                  const Padding(
                    padding: EdgeInsets.only(top: 40),
                    child: StateMessage(
                      Icons.search_off,
                      'No devices found',
                      'Try adjusting your search or location filter.',
                    ),
                  )
                else
                  ...list.map(
                    (d) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: DeviceCard(d),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
