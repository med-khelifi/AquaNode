import 'package:aqua_node/core/enums/enums.dart';
import 'package:aqua_node/core/utils/firestore_helpers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


class Measurement {
  final String id, deviceId, ownerUid;
  final double temperatureC, humidityPct;
  final ValveState valveDesiredState, valveReportedOutput;
  final PhysicalState valvePhysicalState;
  final DateTime sampledAt; // device clock
  final DateTime? receivedAt; // server clock
  final DateTime? expiresAt;

  const Measurement({required this.id, required this.deviceId, required this.ownerUid, required this.temperatureC,
      required this.humidityPct, required this.sampledAt, this.receivedAt, this.expiresAt,
      this.valveDesiredState = ValveState.unknown, this.valveReportedOutput = ValveState.unknown,
      this.valvePhysicalState = PhysicalState.unverified});

  factory Measurement.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final m = doc.data() ?? {};
    return Measurement(
      id: doc.id,
      deviceId: (m['deviceId'] as String?) ?? '',
      ownerUid: (m['ownerUid'] as String?) ?? '',
      temperatureC: readDouble(m['temperatureC']) ?? double.nan,
      humidityPct: readDouble(m['humidityPct']) ?? double.nan,
      valveDesiredState: readEnum(ValveState.values, m['valveDesiredState'], ValveState.unknown),
      valveReportedOutput: readEnum(ValveState.values, m['valveReportedOutput'], ValveState.unknown),
      valvePhysicalState: readEnum(PhysicalState.values, m['valvePhysicalState'], PhysicalState.unverified),
      sampledAt: readDate(m['sampledAt']) ?? DateTime.fromMillisecondsSinceEpoch(0),
      receivedAt: readDate(m['receivedAt']),
      expiresAt: readDate(m['expiresAt']),
    );
  }

  /// Ignore sensor glitches in charts.
  bool get isPlausible => temperatureC.isFinite && humidityPct.isFinite &&
      temperatureC >= -40 && temperatureC <= 85 && humidityPct >= 0 && humidityPct <= 100;
}