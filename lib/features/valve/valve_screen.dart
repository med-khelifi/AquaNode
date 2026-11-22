import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:aqua_node/core/enums/enums.dart';
import 'package:aqua_node/core/widgets/shimmer.dart';
import 'package:aqua_node/core/widgets/status_chip.dart';
import 'package:aqua_node/data/models/device.dart';
import 'package:aqua_node/data/repositories/device_repository.dart';
import 'package:aqua_node/features/dashboard/cubit/devices_cubit.dart';
import 'package:aqua_node/features/valve/cubit/valve_cubit.dart';

/// Valve & Relay control screen connected to Firebase commands via [ValveCubit].
class ValveScreen extends StatelessWidget {
  final Device initialDevice;

  const ValveScreen(this.initialDevice, {super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (ctx) => ValveCubit(
        deviceRepository: ctx.read<DeviceRepository>(),
        initialDevice: initialDevice,
      ),
      child: const _ValveView(),
    );
  }
}

class _ValveView extends StatelessWidget {
  const _ValveView();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ValveCubit, ValveControlState>(
      listener: (context, state) {
        if (state.errorMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage!),
              backgroundColor: tk(context).error,
            ),
          );
        } else if (state.successMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.successMessage!),
              backgroundColor: tk(context).success,
            ),
          );
          // Sync with global DevicesCubit
          if (state.device != null) {
            context.read<DevicesCubit>().updateDevice(state.device!);
          }
        }
      },
      builder: (context, state) {
        if (state.status == ValveStatus.loading) {
          return Scaffold(
            appBar: AppBar(title: const Text('Valve & Relay Control')),
            body: const ValveShimmer(),
          );
        }

        final d = state.device;
        if (d == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Valve Control')),
            body: const Center(child: Text('Device not found.')),
          );
        }

        final activeCommand = state.activeCommand;
        final isSubmitting = state.isSubmitting;
        final canSend = d.conn == Conn.online &&
            d.enabled &&
            !isSubmitting &&
            d.verify != Verify.pending;

        return Scaffold(
          appBar: AppBar(title: const Text('Valve & Relay Control')),
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
                        Text(d.name,
                            style: Theme.of(context).textTheme.titleMedium),
                        const SizedBox(height: 12),
                        valveChip(context, d),
                        if (d.verify == Verify.pending || isSubmitting) ...[
                          const SizedBox(height: 14),
                          const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            activeCommand?.status == CommandStatus.received
                                ? 'Relay received command, executing on hardware…'
                                : 'Waiting for device to confirm relay actuation…',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: tk(context).muted),
                          ),
                        ],
                        if (d.verify == Verify.failed) ...[
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Icon(Icons.error,
                                  color: tk(context).error, size: 18),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Relay command not confirmed. Check valve hardware.',
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
                if (activeCommand != null) ...[
                  const SizedBox(height: 12),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          Icon(
                            activeCommand.status == CommandStatus.executed
                                ? Icons.check_circle_outline
                                : activeCommand.status == CommandStatus.pending
                                    ? Icons.schedule
                                    : Icons.info_outline,
                            color: activeCommand.status == CommandStatus.executed
                                ? tk(context).success
                                : Theme.of(context).colorScheme.primary,
                            size: 20,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Command: ${activeCommand.action.name.toUpperCase()} • ${activeCommand.status.name}',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ),
                          if (state.canCancel)
                            TextButton(
                              onPressed: () => context
                                  .read<ValveCubit>()
                                  .cancelActiveCommand(),
                              child: const Text('Cancel'),
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
                const Spacer(),
                if (!d.enabled || d.conn != Conn.online)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Text(
                      d.enabled
                          ? 'Device must be online to trigger relay commands.'
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
                          child: Text('A relay command is currently in flight.'),
                        ),
                      ],
                    ),
                  ),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: canSend && d.valveOpen
                            ? () =>
                                context.read<ValveCubit>().toggleValve(false)
                            : null,
                        child: const Text('Close valve'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton(
                        onPressed: canSend && !d.valveOpen
                            ? () =>
                                context.read<ValveCubit>().toggleValve(true)
                            : null,
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
