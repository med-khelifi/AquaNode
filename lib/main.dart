import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:aqua_node/firebase_options.dart';
import 'package:aqua_node/app.dart';



import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';



void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint('Firebase initialization note: $e');
  }
   await seedFirestore(uid: 'm1mCnKCOxMcRzwvjfu7g2wZYpGl2', force: false); // DEBUG ONLY
  runApp(const AquaApp());
}



/// DEBUG ONLY. Writes test data (users, devices, commands, 24 h of measurements).
/// Skips if it already ran. Pass force: true to overwrite.
/// Needs rules that allow client writes (see seed notes), because the real rules block them.
Future<void> seedFirestore({required String uid, bool force = false}) async {
  if (!kDebugMode) return;
  final db = FirebaseFirestore.instance;

  if (!force) {
    try {
      if ((await db.doc('devices/esp32_01').get()).exists) {
        debugPrint('[seed] already seeded, skipping');
        return;
      }
    } catch (_) {/* doc missing + strict rules → treat as not seeded */}
  }

  final now = DateTime.now();
  Timestamp ago(int s) => Timestamp.fromDate(now.subtract(Duration(seconds: s)));
  Timestamp inS(int s) => Timestamp.fromDate(now.add(Duration(seconds: s)));
  Timestamp at(DateTime t) => Timestamp.fromDate(t);
  final batch = db.batch();

  // ───── users ─────
  batch.set(db.doc('users/$uid'), {
    'displayName': 'Test User', 'email': 'test@example.com', 'createdAt': ago(2592000),
    'settings': {'theme': 'system', 'units': 'celsius'},
  });

  // ───── devices ─────
  Map<String, dynamic> device(String id, String name, String loc, {double? t, double? h, int? seenAgo,
          String desired = 'closed', String reported = 'unknown', String? lastCmd}) =>
      {
        'deviceId': id, 'ownerUid': uid, 'name': name, 'locationLabel': loc, 'isEnabled': true, 'heartbeatIntervalSec': 60,
        'current': {'temperatureC': t, 'humidityPct': h, 'sampledAt': seenAgo == null ? null : ago(seenAgo)},
        'connectivity': {'lastSeenAt': seenAgo == null ? null : ago(seenAgo), 'firmwareVersion': seenAgo == null ? 'unknown' : '1.0.0'},
        'valve': {'desiredState': desired, 'reportedOutput': reported, 'physicalState': 'unverified',
                  'lastCommandId': lastCmd, 'updatedAt': seenAgo == null ? null : ago(seenAgo)},
        'createdAt': ago(2592000), 'updatedAt': ago(seenAgo ?? 86400),
      };
  batch.set(db.doc('devices/esp32_01'), device('esp32_01', 'Garden', 'Garden', t: 25.6, h: 62.5, seenAgo: 20, desired: 'open', reported: 'open', lastCmd: 'cmd_001')); // online
  batch.set(db.doc('devices/esp32_02'), device('esp32_02', 'Pump Room', 'Basement', t: 18.9, h: 72, seenAgo: 900, lastCmd: 'cmd_003')); // offline
  batch.set(db.doc('devices/esp32_03'), device('esp32_03', 'Spare Node', '')); // never connected

  // ───── commands ─────
  Map<String, dynamic> cmd(String dev, String action, String status, Timestamp created, Timestamp expires,
          {Timestamp? received, Timestamp? completed, String? code, String? msg}) =>
      {'deviceId': dev, 'ownerUid': uid, 'requestedBy': uid, 'action': action, 'status': status, 'createdAt': created,
        'expiresAt': expires, 'receivedAt': received, 'completedAt': completed, 'resultCode': code, 'resultMessage': msg};
  batch.set(db.doc('commands/cmd_001'), cmd('esp32_01', 'open', 'executed', ago(3600), ago(3480), received: ago(3595), completed: ago(3593), code: 'ok', msg: 'Relay switched'));
  batch.set(db.doc('commands/cmd_002'), cmd('esp32_01', 'close', 'pending', ago(10), inS(110)));
  batch.set(db.doc('commands/cmd_003'), cmd('esp32_02', 'close', 'expired', ago(1000), ago(880), completed: ago(879), code: 'timeout'));

  // ───── measurements: 24 h, one per 10 min; esp32_01 has an outage to test chart gaps ─────
  final rnd = Random(7);
  const step = Duration(minutes: 10);
  for (final d in [('esp32_01', 0, 24.0, 62.0, 'open'), ('esp32_02', 2, 18.0, 70.0, 'closed')]) {
    final (dev, first, baseT, baseH, valve) = d;
    for (var i = first; i <= 144; i++) {
      if (dev == 'esp32_01' && i >= 60 && i <= 70) continue; // ~100 min gap
      final t = now.subtract(step * i);
      final h = t.millisecondsSinceEpoch / 3.6e6;
      batch.set(db.doc('measurements/${dev}_boot1_${200 - i}'), {
        'deviceId': dev, 'ownerUid': uid, 'bootId': 'boot1', 'seq': 200 - i,
        'temperatureC': double.parse((baseT + 3 * sin(h / 3) + rnd.nextDouble() * .4).toStringAsFixed(1)),
        'humidityPct': double.parse((baseH + 8 * cos(h / 4) + rnd.nextDouble()).toStringAsFixed(1)),
        'valveDesiredState': valve, 'valveReportedOutput': dev == 'esp32_01' ? 'open' : 'unknown', 'valvePhysicalState': 'unverified',
        'sampledAt': at(t), 'receivedAt': at(t.add(const Duration(seconds: 1))), 'expiresAt': at(t.add(const Duration(days: 7))),
      });
    }
  }

  await batch.commit(); // ~290 writes, under the 500 limit
  debugPrint('[seed] done');
}