import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:aqua_node/core/widgets/shimmer.dart';
import 'package:aqua_node/core/widgets/state_message.dart';
import 'package:aqua_node/core/widgets/status_chip.dart';
import 'package:aqua_node/features/dashboard/cubit/devices_cubit.dart';
import 'package:aqua_node/features/dashboard/widgets/device_card.dart';
import 'package:aqua_node/features/settings/app_settings_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

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
        final list = state.filteredDevices;
        final cubit = context.read<DevicesCubit>();

        return Scaffold(
          appBar: AppBar(
            title: const Text('Aqua Node'),
            actions: [
              IconButton(
                icon: const Icon(Icons.settings_outlined),
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const AppSettingsScreen(),
                    ),
                  );
                },
              ),
            ],
          ),
          body: RefreshIndicator(
            onRefresh: () => cubit.loadDevices(),
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
                      onTap: () => cubit.setFilter(DeviceFilterType.all),
                    ),
                    const SizedBox(width: 8),
                    DashStat(
                      'Online',
                      '${state.onlineCount}',
                      Icons.check_circle,
                      tk(context).success,
                      onTap: () => cubit.setFilter(DeviceFilterType.active),
                    ),
                    const SizedBox(width: 8),
                    DashStat(
                      'Offline',
                      '${state.offlineCount}',
                      Icons.cancel,
                      tk(context).error,
                      onTap: () => cubit.setFilter(DeviceFilterType.inactive),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextField(
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.search),
                    hintText: 'Search by name, ID, or location…',
                  ),
                  onChanged: (v) => cubit.setSearchQuery(v),
                ),
                const SizedBox(height: 14),
                _FilterBar(
                  selectedFilter: state.filter,
                  totalCount: all.length,
                  activeCount: state.activeCount,
                  inactiveCount: state.inactiveCount,
                  onChanged: (f) => cubit.setFilter(f),
                ),
                const SizedBox(height: 14),
                if (list.isEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 40),
                    child: StateMessage(
                      Icons.search_off,
                      'No devices found',
                      state.filter == DeviceFilterType.all
                          ? 'Try adjusting your search query.'
                          : 'No ${state.filter.name} devices match your search.',
                    ),
                  )
                else
                  ...list.map(
                    (d) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: DeviceCard(d),
                    ),
                  ),
                  SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _FilterBar extends StatelessWidget {
  final DeviceFilterType selectedFilter;
  final int totalCount;
  final int activeCount;
  final int inactiveCount;
  final ValueChanged<DeviceFilterType> onChanged;

  const _FilterBar({
    required this.selectedFilter,
    required this.totalCount,
    required this.activeCount,
    required this.inactiveCount,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final border = theme.cardTheme.shape is RoundedRectangleBorder
        ? (theme.cardTheme.shape as RoundedRectangleBorder).side
        : BorderSide(
            color: theme.colorScheme.outlineVariant,
          );

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: theme.cardTheme.color ?? theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.fromBorderSide(border),
      ),
      child: Row(
        children: [
          _Segment(
            label: 'All',
            count: totalCount,
            isSelected: selectedFilter == DeviceFilterType.all,
            onTap: () => onChanged(DeviceFilterType.all),
          ),
          _Segment(
            label: 'Active',
            count: activeCount,
            isSelected: selectedFilter == DeviceFilterType.active,
            onTap: () => onChanged(DeviceFilterType.active),
          ),
          _Segment(
            label: 'Inactive',
            count: inactiveCount,
            isSelected: selectedFilter == DeviceFilterType.inactive,
            onTap: () => onChanged(DeviceFilterType.inactive),
          ),
        ],
      ),
    );
  }
}

class _Segment extends StatelessWidget {
  final String label;
  final int count;
  final bool isSelected;
  final VoidCallback onTap;

  const _Segment({
    required this.label,
    required this.count,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    final onPrimary = theme.colorScheme.onPrimary;
    final muted = tk(context).muted;

    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeInOut,
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? primary : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: isSelected ? onPrimary : muted,
                ),
              ),
              const SizedBox(width: 6),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                decoration: BoxDecoration(
                  color: isSelected
                      ? onPrimary.withValues(alpha: 0.22)
                      : muted.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '$count',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: isSelected ? onPrimary : muted,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
