import 'dart:math';
import 'package:flutter/material.dart';
import 'package:aqua_node/data/models/device.dart';

class Store extends ChangeNotifier {
  bool signedIn = false;
  String email = '';
  ThemeMode themeMode = ThemeMode.system;
  bool fahrenheit = false;
  final now = DateTime.now();
  late final List<Device> devices = [
    Device('AQN-001A', 'Greenhouse Tank', 'Greenhouse', '1.4.2', Conn.online, now.subtract(const Duration(seconds: 20)),
        temp: 22.4, hum: 61, valveOpen: true, verify: Verify.verified),
    Device('AQN-002B', 'Pump Room', 'Basement', '1.4.2', Conn.online, now.subtract(const Duration(minutes: 1)),
        temp: 18.9, hum: 72, valveOpen: false, verify: Verify.pending),
    Device('AQN-003C', 'Garden Line', 'Backyard', '1.3.9', Conn.offline, now.subtract(const Duration(hours: 5)),
        temp: 25.1, hum: 48, valveOpen: false, verify: Verify.unknown),
    Device('AQN-004D', 'Spare Node', 'Unassigned', '1.4.2', Conn.never, null),
  ];

  Future<String?> signIn(String e, String p) async {
    await Future.delayed(const Duration(milliseconds: 800));
    if (p == 'wrong123') return 'Incorrect email or password.';
    signedIn = true; email = e; notifyListeners();
    return null;
  }

  void signOut() { signedIn = false; notifyListeners(); }
  void setTheme(ThemeMode m) { themeMode = m; notifyListeners(); }
  void setUnits(bool f) { fahrenheit = f; notifyListeners(); }
  void touch() => notifyListeners();

  String temp(double c) => fahrenheit ? '${(c * 9 / 5 + 32).toStringAsFixed(1)} °F' : '${c.toStringAsFixed(1)} °C';
  double tVal(double c) => fahrenheit ? c * 9 / 5 + 32 : c;
  String get tUnit => fahrenheit ? '°F' : '°C';

  /// Returns true when command is verified, false if verification failed.
  Future<bool> setValve(Device d, bool open) async {
    d.valveOpen = open; d.verify = Verify.pending; notifyListeners();
    await Future.delayed(const Duration(seconds: 2));
    final ok = d.conn == Conn.online;
    d.verify = ok ? Verify.verified : Verify.failed;
    notifyListeners();
    return ok;
  }

  /// Mock history: 1-min samples, an outage window, then bucket-averaged.
  Future<List<Sample>> history(Device d, Range r) async {
    await Future.delayed(const Duration(milliseconds: 600));
    if (d.lastSeen == null) return [];
    final end = d.lastSeen!, start = DateTime.now().subtract(r.span);
    final rnd = Random(d.id.hashCode);
    final raw = <Sample>[];
    final outStart = start.add(r.span * .45), outEnd = start.add(r.span * .52);
    for (var t = start; t.isBefore(end); t = t.add(const Duration(minutes: 1))) {
      if (d.id == 'AQN-001A' && t.isAfter(outStart) && t.isBefore(outEnd)) continue;
      final h = t.millisecondsSinceEpoch / 3.6e6;
      raw.add(Sample(t, d.temp + 3 * sin(h / 3) + rnd.nextDouble() - .5, (d.hum + 10 * cos(h / 4) + rnd.nextDouble() * 2).clamp(0, 100)));
    }
    final b = r.bucketMin;
    if (b == 1) return raw;
    final out = <Sample>[];
    for (var i = 0; i < raw.length; i += b) {
      final c = raw.sublist(i, min(i + b, raw.length));
      out.add(Sample(c.first.t, c.map((s) => s.temp).reduce((a, b) => a + b) / c.length, c.map((s) => s.hum).reduce((a, b) => a + b) / c.length));
    }
    return out;
  }
}
final store = Store();
