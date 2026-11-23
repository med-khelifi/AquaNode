import 'package:aqua_node/core/extensions/theme_context_extension.dart';
import 'package:flutter/material.dart';

/// Highly customizable and smooth Shimmer widget supporting light (white) and dark themes.
class Shimmer extends StatefulWidget {
  final Widget child;
  final Color? baseColor;
  final Color? highlightColor;
  final Duration duration;

  const Shimmer({
    super.key,
    required this.child,
    this.baseColor,
    this.highlightColor,
    this.duration = const Duration(milliseconds: 1500),
  });

  @override
  State<Shimmer> createState() => _ShimmerState();
}

class _ShimmerState extends State<Shimmer> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration)
      ..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final shimmerColors = context.shimmerColors;
    final base = widget.baseColor ?? shimmerColors.baseColor;
    final highlight = widget.highlightColor ?? shimmerColors.highlightColor;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return ShaderMask(
          blendMode: BlendMode.srcATop,
          shaderCallback: (bounds) {
            final progress = _controller.value;
            return LinearGradient(
              begin: const Alignment(-1.0, -0.3),
              end: const Alignment(1.0, 0.3),
              stops: [
                (progress - 0.4).clamp(0.0, 1.0),
                progress.clamp(0.0, 1.0),
                (progress + 0.4).clamp(0.0, 1.0),
              ],
              colors: [
                base,
                highlight,
                base,
              ],
            ).createShader(bounds);
          },
          child: child,
        );
      },
      child: widget.child,
    );
  }
}

/// A placeholder shape styled with shimmer base color.
class ShimmerBox extends StatelessWidget {
  final double? width;
  final double? height;
  final double borderRadius;
  final ShapeBorder? shape;

  const ShimmerBox({
    super.key,
    this.width,
    this.height,
    this.borderRadius = 8,
    this.shape,
  });

  @override
  Widget build(BuildContext context) {
    final color = context.shimmerColors.baseColor;
    if (shape != null) {
      return Container(
        width: width,
        height: height,
        decoration: ShapeDecoration(
          color: color,
          shape: shape!,
        ),
      );
    }
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
    );
  }
}

/// Shimmer placeholder screen for Dashboard while devices are loading.
class DashboardShimmer extends StatelessWidget {
  const DashboardShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Aqua Node'),
      ),
      body: Shimmer(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Stat Cards Row
            Row(
              children: List.generate(
                3,
                (i) => Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(left: i == 0 ? 0 : 5, right: i == 2 ? 0 : 5),
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            ShimmerBox(width: 24, height: 24, borderRadius: 12),
                            SizedBox(height: 8),
                            ShimmerBox(width: 48, height: 24, borderRadius: 4),
                            SizedBox(height: 6),
                            ShimmerBox(width: 64, height: 12, borderRadius: 4),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Search Bar Shimmer
            const ShimmerBox(height: 52, borderRadius: 12),
            const SizedBox(height: 12),
            // Filter Bar Shimmer
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Theme.of(context).colorScheme.outlineVariant,
                ),
              ),
              child: Row(
                children: List.generate(
                  3,
                  (i) => Expanded(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: i == 1 ? 3 : 0),
                      child: const ShimmerBox(height: 32, borderRadius: 8),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Device Cards List
            ...List.generate(
              4,
              (i) => const Padding(
                padding: EdgeInsets.only(bottom: 12),
                child: DeviceCardShimmer(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Shimmer placeholder for a single Device Card.
class DeviceCardShimmer extends StatelessWidget {
  const DeviceCardShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: const [
                ShimmerBox(width: 140, height: 18, borderRadius: 4),
                Spacer(),
                ShimmerBox(width: 70, height: 24, borderRadius: 12),
              ],
            ),
            const SizedBox(height: 8),
            const ShimmerBox(width: 90, height: 12, borderRadius: 4),
            const SizedBox(height: 16),
            Row(
              children: const [
                ShimmerBox(width: 18, height: 18, borderRadius: 4),
                SizedBox(width: 6),
                ShimmerBox(width: 50, height: 14, borderRadius: 4),
                SizedBox(width: 16),
                ShimmerBox(width: 18, height: 18, borderRadius: 4),
                SizedBox(width: 6),
                ShimmerBox(width: 40, height: 14, borderRadius: 4),
                Spacer(),
                ShimmerBox(width: 90, height: 24, borderRadius: 12),
              ],
            ),
            const SizedBox(height: 10),
            const ShimmerBox(width: 120, height: 12, borderRadius: 4),
          ],
        ),
      ),
    );
  }
}

/// Shimmer placeholder for History screen during metrics loading.
class HistoryShimmer extends StatelessWidget {
  const HistoryShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer(
      child: Column(
        children: [
          // Temperature Chart Card
          Card(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(14, 16, 16, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  ShimmerBox(width: 140, height: 16, borderRadius: 4),
                  SizedBox(height: 18),
                  ShimmerBox(height: 160, borderRadius: 8),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Humidity Chart Card
          Card(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(14, 16, 16, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  ShimmerBox(width: 120, height: 16, borderRadius: 4),
                  SizedBox(height: 18),
                  ShimmerBox(height: 160, borderRadius: 8),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Shimmer placeholder for Valve/Relay screen while loading device state.
class ValveShimmer extends StatelessWidget {
  const ValveShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: const [
                    ShimmerBox(width: 56, height: 56, borderRadius: 28),
                    SizedBox(height: 16),
                    ShimmerBox(width: 160, height: 20, borderRadius: 4),
                    SizedBox(height: 14),
                    ShimmerBox(width: 90, height: 26, borderRadius: 13),
                    SizedBox(height: 16),
                    ShimmerBox(width: 200, height: 14, borderRadius: 4),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: const [
                Expanded(child: ShimmerBox(height: 48, borderRadius: 12)),
                SizedBox(width: 12),
                Expanded(child: ShimmerBox(height: 48, borderRadius: 12)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Shimmer placeholder for Device Details screen while fetching telemetry.
class DeviceDetailsShimmer extends StatelessWidget {
  const DeviceDetailsShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: const [
              ShimmerBox(width: 70, height: 24, borderRadius: 12),
              SizedBox(width: 10),
              ShimmerBox(width: 90, height: 16, borderRadius: 4),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: const [
              Expanded(
                child: Card(
                  child: Padding(
                    padding: EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ShimmerBox(width: 80, height: 14, borderRadius: 4),
                        SizedBox(height: 8),
                        ShimmerBox(width: 60, height: 24, borderRadius: 4),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(width: 10),
              Expanded(
                child: Card(
                  child: Padding(
                    padding: EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ShimmerBox(width: 80, height: 14, borderRadius: 4),
                        SizedBox(height: 8),
                        ShimmerBox(width: 60, height: 24, borderRadius: 4),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: List.generate(
                  4,
                  (i) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      children: const [
                        ShimmerBox(width: 100, height: 14, borderRadius: 4),
                        Spacer(),
                        ShimmerBox(width: 80, height: 14, borderRadius: 4),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          ...List.generate(
            3,
            (i) => const Padding(
              padding: EdgeInsets.only(bottom: 8),
              child: Card(
                child: ListTile(
                  leading: ShimmerBox(width: 24, height: 24, borderRadius: 12),
                  title: ShimmerBox(width: 120, height: 16, borderRadius: 4),
                  subtitle: ShimmerBox(width: 180, height: 12, borderRadius: 4),
                  trailing: ShimmerBox(width: 16, height: 16, borderRadius: 4),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
