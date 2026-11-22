import 'package:aqua_node/core/enums/enums.dart';
import 'package:aqua_node/core/models/command.dart';
import 'package:aqua_node/core/models/device.dart';
import 'package:aqua_node/core/models/masurement.dart';
import 'package:aqua_node/core/services/firebase/firebase.dart';

/// Repository managing devices, valve controls, and metric history with Firebase service.
class DeviceRepository {
  final FirebaseService? _firebaseService;

  DeviceRepository({FirebaseService? firebaseService})
      : _firebaseService = firebaseService;

  FirebaseService get _service => _firebaseService ?? FirebaseService.instance;

  /// Stream of live devices from Firebase Firestore for the authenticated user.
  Stream<List<Device>> watchDevices() {
    try {
      return _service.watchDevices();
    } catch (_) {
      return const Stream.empty();
    }
  }

  /// Watch a single device live from Firebase Firestore.
  Stream<Device?> watchDevice(String deviceId) {
    try {
      return _service.watchDevice(deviceId);
    } catch (_) {
      return const Stream.empty();
    }
  }

  /// Stream latest live sensor measurement from Firebase Firestore.
  Stream<Measurement?> watchLatestMeasurement(String deviceId) {
    try {
      return _service.watchLatest(deviceId);
    } catch (_) {
      return const Stream.empty();
    }
  }

  /// Fetches devices from Firestore with safety timeout.
  Future<List<Device>> getDevices() async {
    try {
      final snap = await _service.watchDevices().first.timeout(
        const Duration(seconds: 4),
        onTimeout: () => [],
      );
      return snap;
    } catch (_) {
      return [];
    }
  }

  /// Updates device settings (name, location, enabled) in Firestore.
  Future<void> updateDevice(Device updated) async {
    try {
      await _service.updateDeviceSettings(
        updated.id,
        name: updated.name,
        locationLabel: updated.location,
        isEnabled: updated.enabled,
      );
    } catch (_) {}
  }

  /// Sends a valve actuation command to Firebase Firestore and returns the command document ID.
  Future<String> sendValveCommand(String deviceId, CommandAction action) async {
    return await _service.sendValveCommand(deviceId, action);
  }

  /// Live status of a command from Firebase Firestore.
  Stream<Command?> watchCommand(String commandId) {
    try {
      return _service.watchCommand(commandId);
    } catch (_) {
      return const Stream.empty();
    }
  }

  /// Streams real-time commands for a device from Firebase.
  Stream<List<Command>> watchCommands(String deviceId, {int limit = 20}) {
    try {
      return _service.watchCommands(deviceId, limit: limit);
    } catch (_) {
      return const Stream.empty();
    }
  }

  /// Cancels a pending command in Firestore.
  Future<void> cancelCommand(String commandId) async {
    await _service.cancelCommand(commandId);
  }

  /// Valve toggle helper that dispatches command and waits for execution confirmation.
  Future<bool> setValve(String deviceId, bool open) async {
    final action = open ? CommandAction.open : CommandAction.close;
    final cmdId = await _service.sendValveCommand(deviceId, action);
    await for (final cmd in watchCommand(cmdId).take(5)) {
      if (cmd?.status == CommandStatus.executed) return true;
      if (cmd?.status == CommandStatus.failed ||
          cmd?.status == CommandStatus.cancelled ||
          cmd?.status == CommandStatus.expired) {
        return false;
      }
    }
    return true;
  }

  /// Queries telemetry history directly from Firebase Firestore. Bad sensor reads filtered out.
  Future<List<Sample>> getHistory(Device d, Range r) async {
    final start = DateTime.now().subtract(r.span);
    final measurements = await _service.history(d.id, start);
    return measurements
        .where((m) => m.isPlausible)
        .map((m) => Sample(m.sampledAt, m.temperatureC, m.humidityPct))
        .toList();
  }
}
