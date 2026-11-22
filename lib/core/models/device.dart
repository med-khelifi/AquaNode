import 'package:aqua_node/core/enums/enums.dart';
import 'package:aqua_node/core/models/valve_info.dart';
import 'package:aqua_node/core/utils/firestore_helpers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

enum Conn { online, offline, never }
enum Verify { verified, pending, failed, unknown }
enum Range { h1, h24, d7 }

extension RangeX on Range {
  String get label => const {Range.h1: '1 hour', Range.h24: '24 hours', Range.d7: '7 days'}[this]!;
  Duration get span => const {Range.h1: Duration(hours: 1), Range.h24: Duration(hours: 24), Range.d7: Duration(days: 7)}[this]!;
  int get bucketMin => const {Range.h1: 1, Range.h24: 10, Range.d7: 60}[this]!;
}

class Sample {
  final DateTime t;
  final double temp, hum;
  Sample(this.t, this.temp, this.hum);
}

class Device {
  final String deviceId;
  final String ownerUid;
  String name;
  String locationLabel;
  String firmwareVersion;
  bool isEnabled;
  final int heartbeatIntervalSec;
  double? temperatureC;
  double? humidityPct;
  final DateTime? sampledAt;
  DateTime? lastSeenAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  ValveInfo valve;

  // Overrides for optimistic UI updates
  bool? _valveOpenOverride;
  Verify? _verifyOverride;
  Conn? _connOverride;

  /// Positional constructor for backwards compatibility with tests and domain fixtures:
  /// Device('AQN-001A', 'Tank', 'Greenhouse', '1.4.2', Conn.online, lastSeen, ...)
  Device(
    this.deviceId,
    this.name,
    this.locationLabel,
    this.firmwareVersion,
    Conn? conn,
    this.lastSeenAt, {
    double temp = 0,
    double hum = 0,
    bool valveOpen = false,
    Verify verify = Verify.unknown,
    bool enabled = true,
    this.ownerUid = '',
    this.heartbeatIntervalSec = 60,
    this.sampledAt,
    this.createdAt,
    this.updatedAt,
    this.valve = const ValveInfo(),
  })  : _connOverride = conn,
        _verifyOverride = verify,
        _valveOpenOverride = valveOpen,
        isEnabled = enabled,
        temperatureC = temp,
        humidityPct = hum;

  /// Firestore constructor using named parameters
  Device.firestore({
    required this.deviceId,
    required this.ownerUid,
    required this.name,
    this.locationLabel = '',
    this.firmwareVersion = 'unknown',
    this.isEnabled = true,
    this.heartbeatIntervalSec = 60,
    this.temperatureC,
    this.humidityPct,
    this.sampledAt,
    this.lastSeenAt,
    this.createdAt,
    this.updatedAt,
    this.valve = const ValveInfo(),
    Conn? conn,
    Verify? verify,
    bool? valveOpen,
  })  : _connOverride = conn,
        _verifyOverride = verify,
        _valveOpenOverride = valveOpen;

  factory Device.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final m = doc.data() ?? {};
    final cur = m['current'] as Map<String, dynamic>?;
    final con = m['connectivity'] as Map<String, dynamic>?;
    return Device.firestore(
      deviceId: (m['deviceId'] as String?) ?? doc.id,
      ownerUid: (m['ownerUid'] as String?) ?? '',
      name: (m['name'] as String?) ?? doc.id,
      locationLabel: (m['locationLabel'] as String?) ?? '',
      isEnabled: (m['isEnabled'] as bool?) ?? true,
      heartbeatIntervalSec: (m['heartbeatIntervalSec'] as num?)?.toInt() ?? 60,
      temperatureC: readDouble(cur?['temperatureC']),
      humidityPct: readDouble(cur?['humidityPct']),
      sampledAt: readDate(cur?['sampledAt']),
      lastSeenAt: readDate(con?['lastSeenAt']),
      firmwareVersion: (con?['firmwareVersion'] as String?) ?? 'unknown',
      valve: ValveInfo.fromMap(m['valve'] as Map<String, dynamic>?),
      createdAt: readDate(m['createdAt']),
      updatedAt: readDate(m['updatedAt']),
    );
  }

  /// UI compatibility properties & setters
  String get id => deviceId;

  String get location => locationLabel;
  set location(String val) => locationLabel = val;

  String get firmware => firmwareVersion;
  set firmware(String val) => firmwareVersion = val;

  bool get enabled => isEnabled;
  set enabled(bool val) => isEnabled = val;

  double get temp => temperatureC ?? 0.0;
  set temp(double val) => temperatureC = val;

  double get hum => humidityPct ?? 0.0;
  set hum(double val) => humidityPct = val;

  DateTime? get lastSeen => lastSeenAt;
  set lastSeen(DateTime? val) => lastSeenAt = val;

  bool get valveOpen =>
      _valveOpenOverride ?? (valve.desiredState == ValveState.open);
  set valveOpen(bool val) => _valveOpenOverride = val;

  Verify get verify {
    if (_verifyOverride != null) return _verifyOverride!;
    if (valveMismatch) return Verify.pending;
    if (valveVerified) return Verify.verified;
    if (valve.physicalState == PhysicalState.unverified &&
        valve.reportedOutput == ValveState.unknown) {
      return Verify.unknown;
    }
    return Verify.failed;
  }
  set verify(Verify val) => _verifyOverride = val;

  Conn get conn {
    if (_connOverride != null) return _connOverride!;
    switch (connection()) {
      case ConnectionStatus.online:
        return Conn.online;
      case ConnectionStatus.offline:
        return Conn.offline;
      case ConnectionStatus.neverConnected:
        return Conn.never;
    }
  }
  set conn(Conn val) => _connOverride = val;

  /// The only fields the app may write (see firestore.rules).
  static Map<String, dynamic> settingsUpdate({
    required String name,
    required String locationLabel,
    required bool isEnabled,
  }) => {
        'name': name,
        'locationLabel': locationLabel,
        'isEnabled': isEnabled,
        'updatedAt': FieldValue.serverTimestamp(),
      };

  // Derived state
  Duration get offlineAfter => Duration(
      seconds: heartbeatIntervalSec * 3 < 90 ? 90 : heartbeatIntervalSec * 3);

  ConnectionStatus connection([DateTime? now]) {
    if (lastSeenAt == null) return ConnectionStatus.neverConnected;
    return (now ?? DateTime.now()).difference(lastSeenAt!) > offlineAfter
        ? ConnectionStatus.offline
        : ConnectionStatus.online;
  }

  bool get valveMismatch =>
      valve.reportedOutput != ValveState.unknown &&
      valve.reportedOutput != valve.desiredState;
  bool get valveVerified =>
      valve.physicalState == PhysicalState.verified &&
      valve.reportedOutput == valve.desiredState;

  Device copyWith({
    String? deviceId,
    String? ownerUid,
    String? name,
    String? locationLabel,
    String? firmwareVersion,
    bool? isEnabled,
    int? heartbeatIntervalSec,
    double? temperatureC,
    double? humidityPct,
    DateTime? sampledAt,
    DateTime? lastSeenAt,
    DateTime? createdAt,
    DateTime? updatedAt,
    ValveInfo? valve,
    Conn? conn,
    Verify? verify,
    bool? valveOpen,
  }) =>
      Device.firestore(
        deviceId: deviceId ?? this.deviceId,
        ownerUid: ownerUid ?? this.ownerUid,
        name: name ?? this.name,
        locationLabel: locationLabel ?? this.locationLabel,
        firmwareVersion: firmwareVersion ?? this.firmwareVersion,
        isEnabled: isEnabled ?? this.isEnabled,
        heartbeatIntervalSec: heartbeatIntervalSec ?? this.heartbeatIntervalSec,
        temperatureC: temperatureC ?? this.temperatureC,
        humidityPct: humidityPct ?? this.humidityPct,
        sampledAt: sampledAt ?? this.sampledAt,
        lastSeenAt: lastSeenAt ?? this.lastSeenAt,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        valve: valve ?? this.valve,
        conn: conn ?? _connOverride,
        verify: verify ?? _verifyOverride,
        valveOpen: valveOpen ?? _valveOpenOverride,
      );
}
