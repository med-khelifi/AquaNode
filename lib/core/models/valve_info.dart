import 'package:aqua_node/core/enums/enums.dart';
import 'package:aqua_node/core/utils/firestore_helpers.dart';



class ValveInfo {
  final ValveState desiredState, reportedOutput;
  final PhysicalState physicalState;
  final String? lastCommandId;
  final DateTime? updatedAt;
  const ValveInfo({this.desiredState = ValveState.closed, this.reportedOutput = ValveState.unknown,
      this.physicalState = PhysicalState.unverified, this.lastCommandId, this.updatedAt});

  factory ValveInfo.fromMap(Map<String, dynamic>? m) => ValveInfo(
        desiredState: readEnum(ValveState.values, m?['desiredState'], ValveState.closed),
        reportedOutput: readEnum(ValveState.values, m?['reportedOutput'], ValveState.unknown),
        physicalState: readEnum(PhysicalState.values, m?['physicalState'], PhysicalState.unverified),
        lastCommandId: m?['lastCommandId'] as String?,
        updatedAt: readDate(m?['updatedAt']),
      );
}