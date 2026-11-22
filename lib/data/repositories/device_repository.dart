import 'dart:math';
import 'package:aqua_node/data/models/device.dart';

/// Repository managing devices, valve controls, and metric history.
class DeviceRepository {
  final now = DateTime.now();
  late final List<Device> _devices = [
    Device(
      'AQN-001A',
      'Greenhouse Tank',
      'Greenhouse',
      '1.4.2',
      Conn.online,
      now.subtract(const Duration(seconds: 20)),
      temp: 22.4,
      hum: 61,
      valveOpen: true,
      verify: Verify.verified,
    ),
    Device(
      'AQN-002B',
      'Pump Room',
      'Basement',
      '1.4.2',
      Conn.online,
      now.subtract(const Duration(minutes: 1)),
      temp: 18.9,
      hum: 72,
      valveOpen: false,
      verify: Verify.pending,
    ),
    Device(
      'AQN-003C',
      'Garden Line',
      'Backyard',
      '1.3.9',
      Conn.offline,
      now.subtract(const Duration(hours: 5)),
      temp: 25.1,
      hum: 48,
      valveOpen: false,
      verify: Verify.unknown,
    ),
    Device('AQN-004D', 'Spare Node', 'Unassigned', '1.4.2', Conn.never, null),
  ];

  Future<List<Device>> getDevices() async {
    await Future.delayed(const Duration(milliseconds: 100));
    return List<Device>.from(_devices);
  }

  void updateDevice(Device updated) {
    final idx = _devices.indexWhere((d) => d.id == updated.id);
    if (idx != -1) {
      _devices[idx] = updated;
    }
  }

  Future<bool> setValve(String deviceId, bool open) async {
    final d = _devices.firstWhere((dev) => dev.id == deviceId);
    d.valveOpen = open;
    d.verify = Verify.pending;
    await Future.delayed(const Duration(seconds: 2));
    final ok = d.conn == Conn.online;
    d.verify = ok ? Verify.verified : Verify.failed;
    return ok;
  }

  Future<List<Sample>> getHistory(Device d, Range r) async {
    await Future.delayed(const Duration(milliseconds: 600));
    if (d.lastSeen == null) return [];
    final end = d.lastSeen!;
    final start = DateTime.now().subtract(r.span);
    final rnd = Random(d.id.hashCode);
    final raw = <Sample>[];
    final outStart = start.add(r.span * .45);
    final outEnd = start.add(r.span * .52);

    for (var t = start; t.isBefore(end); t = t.add(const Duration(minutes: 1))) {
      if (d.id == 'AQN-001A' && t.isAfter(outStart) && t.isBefore(outEnd)) continue;
      final h = t.millisecondsSinceEpoch / 3.6e6;
      raw.add(
        Sample(
          t,
          d.temp + 3 * sin(h / 3) + rnd.nextDouble() - .5,
          (d.hum + 10 * cos(h / 4) + rnd.nextDouble() * 2).clamp(0, 100),
        ),
      );
    }
    final b = r.bucketMin;
    if (b == 1) return raw;
    final out = <Sample>[];
    for (var i = 0; i < raw.length; i += b) {
      final c = raw.sublist(i, min(i + b, raw.length));
      out.add(
        Sample(
          c.first.t,
          c.map((s) => s.temp).reduce((a, b) => a + b) / c.length,
          c.map((s) => s.hum).reduce((a, b) => a + b) / c.length,
        ),
      );
    }
    return out;
  }
}
