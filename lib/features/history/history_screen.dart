import 'package:flutter/material.dart';
import 'package:aqua_node/core/widgets/status_chip.dart';
import 'package:aqua_node/core/widgets/state_message.dart';
import 'package:aqua_node/data/models/device.dart';
import 'package:aqua_node/state/app_state.dart';
import 'package:aqua_node/features/history/widgets/metric_chart.dart';

class HistoryScreen extends StatefulWidget {
  final Device d;
  const HistoryScreen(this.d, {super.key});
  @override
  State<HistoryScreen> createState() => _HistState();
}

class _HistState extends State<HistoryScreen> {
  Range _r = Range.h24;
  late Future<List<Sample>> _f = store.history(widget.d, _r);

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('History')),
        body: ListView(padding: const EdgeInsets.all(16), children: [
          SegmentedButton<Range>(
            segments: [for (final r in Range.values) ButtonSegment(value: r, label: Text(r.label))],
            selected: {_r}, showSelectedIcon: false,
            onSelectionChanged: (s) => setState(() { _r = s.first; _f = store.history(widget.d, _r); }),
          ),
          const SizedBox(height: 16),
          FutureBuilder<List<Sample>>(future: _f, builder: (context, snap) {
            if (snap.connectionState != ConnectionState.done) {
              return const Padding(padding: EdgeInsets.only(top: 80), child: Center(child: CircularProgressIndicator()));
            }
            if (snap.hasError) {
              return StateMessage(Icons.error_outline, 'Could not load history', 'Check your connection and try again.',
                  action: OutlinedButton(onPressed: () => setState(() => _f = store.history(widget.d, _r)), child: const Text('Retry')));
            }
            final data = snap.data!;
            if (data.isEmpty) return const Padding(padding: EdgeInsets.only(top: 60), child: StateMessage(Icons.insights, 'No data yet', 'This device has not reported readings in this period.'));
            return Column(children: [
              MetricChart(title: 'Temperature', unit: store.tUnit, data: data, pick: (s) => store.tVal(s.temp), color: Theme.of(context).colorScheme.primary, range: _r),
              const SizedBox(height: 12),
              MetricChart(title: 'Humidity', unit: '%', data: data, pick: (s) => s.hum, color: tk(context).success, range: _r),
              const SizedBox(height: 10),
              Text('Gaps in the line mean the device reported no data.', style: TextStyle(color: tk(context).muted, fontSize: 12.5)),
            ]);
          }),
        ]),
      );
}
