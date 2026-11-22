import 'package:aqua_node/core/enums/enums.dart';
import 'package:aqua_node/core/utils/firestore_helpers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


class Command {
  final String id, deviceId, ownerUid, requestedBy;
  final CommandAction action;
  final CommandStatus status;
  final DateTime? createdAt, expiresAt, receivedAt, completedAt;
  final String? resultCode, resultMessage;

  const Command({required this.id, required this.deviceId, required this.ownerUid, required this.requestedBy,
      required this.action, required this.status, this.createdAt, this.expiresAt, this.receivedAt,
      this.completedAt, this.resultCode, this.resultMessage});

  factory Command.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final m = doc.data() ?? {};
    return Command(
      id: doc.id,
      deviceId: (m['deviceId'] as String?) ?? '',
      ownerUid: (m['ownerUid'] as String?) ?? '',
      requestedBy: (m['requestedBy'] as String?) ?? '',
      action: readEnum(CommandAction.values, m['action'], CommandAction.close), // fail safe
      status: readEnum(CommandStatus.values, m['status'], CommandStatus.failed),
      createdAt: readDate(m['createdAt']),
      expiresAt: readDate(m['expiresAt']),
      receivedAt: readDate(m['receivedAt']),
      completedAt: readDate(m['completedAt']),
      resultCode: m['resultCode'] as String?,
      resultMessage: m['resultMessage'] as String?,
    );
  }

  /// Payload for creating a command from the app.
  static Map<String, dynamic> create({required String deviceId, required String uid, required CommandAction action,
          Duration ttl = const Duration(minutes: 2)}) =>
      {
        'deviceId': deviceId, 'ownerUid': uid, 'requestedBy': uid,
        'action': action.name, 'status': CommandStatus.pending.name,
        'createdAt': FieldValue.serverTimestamp(),
        'expiresAt': Timestamp.fromDate(DateTime.now().add(ttl)),
        'receivedAt': null, 'completedAt': null, 'resultCode': null, 'resultMessage': null,
      };

  bool get isTerminal => const {CommandStatus.executed, CommandStatus.failed, CommandStatus.expired, CommandStatus.cancelled}.contains(status);

  /// Show "expired" immediately when the time is up, without waiting for the backend.
  CommandStatus effectiveStatus([DateTime? now]) =>
      !isTerminal && expiresAt != null && (now ?? DateTime.now()).isAfter(expiresAt!) ? CommandStatus.expired : status;
}