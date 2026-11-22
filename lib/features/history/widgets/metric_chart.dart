import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:aqua_node/core/widgets/status_chip.dart';
import 'package:aqua_node/data/models/device.dart';

/// fl_chart line chart. Inserts null spots across outages so gaps stay gaps.
class MetricChart extends StatelessWidget {
  final String title, unit; final List<Sample> data; final double Function(Sample) pick;
  final Color color; final Range range;
  const MetricChart({super.key, required this.title, required this.unit, required this.data, required this.pick, required this.color, required this.range});

  @override
  Widget build(BuildContext context) {
    final t = tk(context);
    final start = DateTime.now().subtract(range.span);
    double x(DateTime d) => d.difference(start).inMinutes.toDouble();
    final gapMin = {Range.h1: 5, Range.h24: 30, Range.d7: 180}[range]!;
    final spots = <FlSpot>[];
    for (var i = 0; i < data.length; i++) {
      if (i > 0 && data[i].t.difference(data[i - 1].t).inMinutes > gapMin) spots.add(FlSpot.nullSpot);
      spots.add(FlSpot(x(data[i].t), pick(data[i])));
    }
    final vals = data.map(pick);
    final lo = (vals.reduce((a, b) => a < b ? a : b) - 1).floorToDouble();
    final hi = (vals.reduce((a, b) => a > b ? a : b) + 1).ceilToDouble();
    final maxX = range.span.inMinutes.toDouble();
    String tl(double v) {
      final d = start.add(Duration(minutes: v.round()));
      if (range == Range.d7) return ['Mon','Tue','Wed','Thu','Fri','Sat','Sun'][d.weekday - 1];
      return '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
    }
    const none = AxisTitles(sideTitles: SideTitles(showTitles: false));
    final small = TextStyle(fontSize: 11, color: t.muted);
    return Card(child: Padding(
      padding: const EdgeInsets.fromLTRB(12, 14, 16, 10),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Padding(padding: const EdgeInsets.only(left: 4), child: Text('$title ($unit)', style: Theme.of(context).textTheme.titleSmall)),
        const SizedBox(height: 12),
        SizedBox(height: 180, child: LineChart(LineChartData(
          minX: 0, maxX: maxX, minY: lo, maxY: hi,
          gridData: FlGridData(drawVerticalLine: false, getDrawingHorizontalLine: (_) => FlLine(color: t.muted.withValues(alpha: .15), strokeWidth: 1)),
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(topTitles: none, rightTitles: none,
            leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 38,
                getTitlesWidget: (v, m) => (v == m.min || v == m.max) ? const SizedBox() : Text(v.toStringAsFixed(0), style: small))),
            bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 26, interval: maxX / 4,
                getTitlesWidget: (v, m) => Padding(padding: const EdgeInsets.only(top: 6), child: Text(tl(v), style: small))))),
          lineBarsData: [LineChartBarData(spots: spots, color: color, barWidth: 2.2, isCurved: false,
              dotData: const FlDotData(show: false),
              belowBarData: BarAreaData(show: true, color: color.withValues(alpha: .08)))],
        ))),
      ]),
    ));
  }
}
