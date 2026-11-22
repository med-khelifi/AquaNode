import 'package:flutter/material.dart';
import 'package:aqua_node/core/theme/extensions/status_colors.dart';
import 'package:aqua_node/data/models/device.dart';

/// Access status colors from context.
StatusColors tk(BuildContext c) => Theme.of(c).extension<StatusColors>()!;

/// Status chip: color + icon + label (never color alone).
class StatusChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;

  const StatusChip(this.label, this.icon, this.color, {super.key});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: color.withValues(alpha: .12),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 5),
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w600,
                  fontSize: 12.5,
                ),
              ),
            ),
          ],
        ),
      );
}

StatusChip connChip(BuildContext c, Conn s) {
  final t = tk(c);
  switch (s) {
    case Conn.online:
      return StatusChip('Online', Icons.check_circle, t.success);
    case Conn.offline:
      return StatusChip('Offline', Icons.cancel, t.error);
    case Conn.never:
      return StatusChip('Never connected', Icons.help_outline, t.neutral);
  }
}

StatusChip valveChip(BuildContext c, Device d) {
  final t = tk(c);
  final s = d.valveOpen ? 'Open' : 'Closed';
  switch (d.verify) {
    case Verify.verified:
      return StatusChip('$s · Verified', Icons.verified, t.success);
    case Verify.pending:
      return StatusChip('$s requested · Pending', Icons.hourglass_top, t.warning);
    case Verify.failed:
      return StatusChip('$s · Not verified', Icons.error, t.error);
    case Verify.unknown:
      return StatusChip('Valve unverified', Icons.help_outline, t.neutral);
  }
}
