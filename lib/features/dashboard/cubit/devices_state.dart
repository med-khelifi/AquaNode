import 'package:equatable/equatable.dart';
import 'package:aqua_node/data/models/device.dart';

enum DevicesStatus { initial, loading, success, failure }

enum DeviceFilterType { all, active, inactive }

class DevicesState extends Equatable {
  final DevicesStatus status;
  final List<Device> devices;
  final String? errorMessage;
  final int version;
  final DeviceFilterType filter;
  final String searchQuery;

  const DevicesState({
    this.status = DevicesStatus.initial,
    this.devices = const [],
    this.errorMessage,
    this.version = 0,
    this.filter = DeviceFilterType.all,
    this.searchQuery = '',
  });

  int get onlineCount => devices.where((d) => d.conn == Conn.online).length;
  int get offlineCount => devices.where((d) => d.conn != Conn.online).length;
  int get activeCount =>
      devices.where((d) => d.enabled && d.conn == Conn.online).length;
  int get inactiveCount => devices.length - activeCount;

  List<Device> get filteredDevices {
    final q = searchQuery.trim().toLowerCase();
    return devices.where((d) {
      final matchesQuery = q.isEmpty ||
          d.name.toLowerCase().contains(q) ||
          d.id.toLowerCase().contains(q) ||
          d.location.toLowerCase().contains(q);

      final isDeviceActive = d.enabled && d.conn == Conn.online;
      final matchesFilter = switch (filter) {
        DeviceFilterType.active => isDeviceActive,
        DeviceFilterType.inactive => !isDeviceActive,
        DeviceFilterType.all => true,
      };

      return matchesQuery && matchesFilter;
    }).toList();
  }

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
    DeviceFilterType? filter,
    String? searchQuery,
  }) =>
      DevicesState(
        status: status ?? this.status,
        devices: devices ?? this.devices,
        errorMessage: errorMessage,
        version: version ?? (this.version + 1),
        filter: filter ?? this.filter,
        searchQuery: searchQuery ?? this.searchQuery,
      );

  @override
  List<Object?> get props => [
        status,
        devices,
        errorMessage,
        version,
        filter,
        searchQuery,
      ];
}
