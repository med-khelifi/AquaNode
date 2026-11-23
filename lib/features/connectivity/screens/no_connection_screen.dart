import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:aqua_node/core/widgets/status_chip.dart';
import 'package:aqua_node/features/connectivity/cubit/connectivity_cubit.dart';

/// Screen displayed when the application is offline or loses internet connection.
class NoConnectionScreen extends StatefulWidget {
  final VoidCallback? onRetry;
  final bool isChecking;

  const NoConnectionScreen({
    super.key,
    this.onRetry,
    this.isChecking = false,
  });

  @override
  State<NoConnectionScreen> createState() => _NoConnectionScreenState();
}

class _NoConnectionScreenState extends State<NoConnectionScreen> {
  bool _isLocallyChecking = false;

  Future<void> _handleRetry() async {
    if (widget.onRetry != null) {
      widget.onRetry!();
      return;
    }

    // Attempt re-check via ConnectivityCubit if present in tree
    final cubit = context.read<ConnectivityCubit?>();
    if (cubit != null) {
      setState(() => _isLocallyChecking = true);
      final connected = await cubit.checkConnection();
      if (!mounted) return;
      setState(() => _isLocallyChecking = false);

      if (!connected) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Still offline. Please check your network and try again.'),
            duration: Duration(seconds: 3),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final statusColor = tk(context);
    final checkingFromCubit =
        context.watch<ConnectivityCubit?>()?.state.isChecking ?? false;
    final isChecking =
        widget.isChecking || _isLocallyChecking || checkingFromCubit;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Container(
                      width: 88,
                      height: 88,
                      decoration: BoxDecoration(
                        color: statusColor.error.withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: statusColor.error.withValues(alpha: 0.28),
                          width: 2,
                        ),
                      ),
                      child: Center(
                        child: Icon(
                          Icons.wifi_off_rounded,
                          size: 44,
                          color: statusColor.error,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: StatusChip(
                      'No Connection',
                      Icons.cloud_off_rounded,
                      statusColor.error,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'No Internet Connection',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Aqua Node requires an active network connection to reach your IoT smart-nodes and display real-time sensor measurements.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: statusColor.muted,
                      fontSize: 13.5,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 18),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.lightbulb_outline_rounded,
                                size: 18,
                                color: theme.colorScheme.primary,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Troubleshooting steps',
                                  style: theme.textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          const _TroubleshootStep(
                            icon: Icons.wifi,
                            text: 'Make sure Wi-Fi or cellular data is enabled.',
                          ),
                          const SizedBox(height: 6),
                          const _TroubleshootStep(
                            icon: Icons.airplanemode_inactive_rounded,
                            text: 'Check that Airplane mode is turned off.',
                          ),
                          const SizedBox(height: 6),
                          const _TroubleshootStep(
                            icon: Icons.router_outlined,
                            text: 'Confirm your router or access point has internet access.',
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  FilledButton.icon(
                    onPressed: isChecking ? null : _handleRetry,
                    icon: isChecking
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.refresh_rounded),
                    label: Text(
                      isChecking ? 'Checking Connection…' : 'Try Again',
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.sync,
                        size: 15,
                        color: statusColor.muted,
                      ),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          'Automatically reconnects when back online',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 12,
                            color: statusColor.muted,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _TroubleshootStep extends StatelessWidget {
  final IconData icon;
  final String text;

  const _TroubleshootStep({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    final muted = tk(context).muted;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: muted),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 12.5,
              color: muted,
              height: 1.25,
            ),
          ),
        ),
      ],
    );
  }
}
