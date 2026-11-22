
import 'package:aqua_node/core/enums/enums.dart';
import 'package:aqua_node/core/models/valve_info.dart';
import 'package:aqua_node/core/utils/firestore_helpers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Device {
  final String deviceId, ownerUid, name, locationLabel, firmwareVersion;
  final bool isEnabled;
  final int heartbeatIntervalSec;
  final double? temperatureC, humidityPct;
  final DateTime? sampledAt, lastSeenAt, createdAt, updatedAt;
  final ValveInfo valve;

  const Device({required this.deviceId, required this.ownerUid, required this.name, this.locationLabel = '',
      this.firmwareVersion = 'unknown', this.isEnabled = true, this.heartbeatIntervalSec = 60,
      this.temperatureC, this.humidityPct, this.sampledAt, this.lastSeenAt, this.createdAt, this.updatedAt,
      this.valve = const ValveInfo()});

  factory Device.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final m = doc.data() ?? {};
    final cur = m['current'] as Map<String, dynamic>?;
    final con = m['connectivity'] as Map<String, dynamic>?;
    return Device(
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

  /// The only fields the app may write (see firestore.rules).
  static Map<String, dynamic> settingsUpdate({required String name, required String locationLabel, required bool isEnabled}) =>
      {'name': name, 'locationLabel': locationLabel, 'isEnabled': isEnabled, 'updatedAt': FieldValue.serverTimestamp()};

  // Derived state
  Duration get offlineAfter => Duration(seconds: heartbeatIntervalSec * 3 < 90 ? 90 : heartbeatIntervalSec * 3);

  ConnectionStatus connection([DateTime? now]) {
    if (lastSeenAt == null) return ConnectionStatus.neverConnected;
    return (now ?? DateTime.now()).difference(lastSeenAt!) > offlineAfter ? ConnectionStatus.offline : ConnectionStatus.online;
  }

  bool get valveMismatch => valve.reportedOutput != ValveState.unknown && valve.reportedOutput != valve.desiredState;
  bool get valveVerified => valve.physicalState == PhysicalState.verified && valve.reportedOutput == valve.desiredState;
}
