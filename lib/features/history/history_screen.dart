import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:aqua_node/core/widgets/shimmer.dart';
import 'package:aqua_node/core/widgets/state_message.dart';
import 'package:aqua_node/core/widgets/status_chip.dart';
import 'package:aqua_node/data/models/device.dart';
import 'package:aqua_node/data/repositories/device_repository.dart';
import 'package:aqua_node/features/history/cubit/history_cubit.dart';
import 'package:aqua_node/features/history/widgets/metric_chart.dart';
import 'package:aqua_node/features/settings/cubit/settings_cubit.dart';

class HistoryScreen extends StatelessWidget {
  final Device d;

  const HistoryScreen(this.d, {super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (ctx) => HistoryCubit(
        deviceRepository: ctx.read<DeviceRepository>(),
      )..fetchHistory(d, Range.h24),
      child: _HistoryView(d: d),
    );
  }
}

class _HistoryView extends StatelessWidget {
  final Device d;

  const _HistoryView({required this.d});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('${d.name} History')),
      body: BlocBuilder<HistoryCubit, HistoryState>(
        builder: (context, state) {
          final range = state.range;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              SegmentedButton<Range>(
                segments: const [
                  ButtonSegment(value: Range.h1, label: Text('1h')),
                  ButtonSegment(value: Range.h24, label: Text('24h')),
                  ButtonSegment(value: Range.d7, label: Text('7d')),
                ],
                selected: {range},
                showSelectedIcon: false,
                onSelectionChanged: (s) => context.read<HistoryCubit>().fetchHistory(
                      d,
                      s.first,
                    ),
              ),
              const SizedBox(height: 16),
              if (state.status == HistoryStatus.loading)
                const HistoryShimmer()
              else if (state.status == HistoryStatus.failure)
                StateMessage(
                  Icons.error_outline,
                  'Failed to load history',
                  state.errorMessage ?? 'An error occurred.',
                  action: OutlinedButton(
                    onPressed: () => context.read<HistoryCubit>().fetchHistory(d, range),
                    child: const Text('Retry'),
                  ),
                )
              else if (state.status == HistoryStatus.success) ...[
                BlocBuilder<SettingsCubit, SettingsState>(
                  builder: (context, settingsState) {
                    return MetricChart(
                      title: 'Temperature',
                      unit: settingsState.tempUnit,
                      data: state.data,
                      pick: (s) => settingsState.convertTemp(s.temp),
                      color: Theme.of(context).colorScheme.primary,
                      range: range,
                    );
                  },
                ),
                const SizedBox(height: 16),
                MetricChart(
                  title: 'Humidity',
                  unit: '%',
                  data: state.data,
                  pick: (s) => s.hum,
                  color: tk(context).success,
                  range: range,
                ),
                const SizedBox(height: 12),
                Text(
                  'Gaps in the line mean the device reported no data.',
                  style: TextStyle(color: tk(context).muted, fontSize: 12.5),
                ),
              ],
            ],
          );
        },
      ),
    );
  }
}
