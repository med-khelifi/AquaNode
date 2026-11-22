import 'package:flutter/material.dart';
import 'package:aqua_node/core/widgets/status_chip.dart';

class StateMessage extends StatelessWidget {
  final IconData icon; final String title, body; final Widget? action;
  const StateMessage(this.icon, this.title, this.body, {this.action, super.key});
  @override
  Widget build(BuildContext context) => Center(
        child: Padding(padding: const EdgeInsets.all(24), child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, size: 40, color: tk(context).muted), const SizedBox(height: 12),
          Text(title, style: Theme.of(context).textTheme.titleMedium, textAlign: TextAlign.center),
          const SizedBox(height: 6),
          Text(body, style: TextStyle(color: tk(context).muted), textAlign: TextAlign.center),
          if (action != null) ...[const SizedBox(height: 16), action!],
        ])),
      );
}
