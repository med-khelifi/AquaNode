import 'package:equatable/equatable.dart';
import 'package:aqua_node/data/models/device.dart';

enum DevicesStatus { initial, loading, success, failure }

class DevicesState extends Equatable {
  final DevicesStatus status;
  final List<Device> devices;
  final String? errorMessage;
  final int version;

  const DevicesState({
    this.status = DevicesStatus.initial,
    this.devices = const [],
    this.errorMessage,
    this.version = 0,
  });

  int get onlineCount => devices.where((d) => d.conn == Conn.online).length;
  int get offlineCount => devices.where((d) => d.conn != Conn.online).length;

  Device? findDevice(String id) {
    try {
      return devices.firstWhere((d) => d.id == id);
    } catch (_) {
      return null;
    }
  }

  DevicesState copyWith({
    DevicesStatus? status,
    List<Device>? devices,
    String? errorMessage,
    int? version,
  }) =>
      DevicesState(
        status: status ?? this.status,
        devices: devices ?? this.devices,
        errorMessage: errorMessage,
        version: version ?? (this.version + 1),
      );

  @override
  List<Object?> get props => [status, devices, errorMessage, version];
}
