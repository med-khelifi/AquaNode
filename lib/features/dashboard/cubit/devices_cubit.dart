import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:aqua_node/core/models/device.dart';
import 'package:aqua_node/data/repositories/device_repository.dart';
import 'package:aqua_node/features/dashboard/cubit/devices_state.dart';

export 'devices_state.dart';

class DevicesCubit extends Cubit<DevicesState> {
  final DeviceRepository _deviceRepository;
  StreamSubscription<List<Device>>? _devicesSubscription;

  DevicesCubit({required DeviceRepository deviceRepository})
      : _deviceRepository = deviceRepository,
        super(const DevicesState());

  /// Loads devices and listens to live real-time updates from Firebase.
  Future<void> loadDevices() async {
    emit(state.copyWith(status: DevicesStatus.loading));
    await _devicesSubscription?.cancel();

    try {
      final initial = await _deviceRepository.getDevices();
      emit(state.copyWith(
        status: DevicesStatus.success,
        devices: initial,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: DevicesStatus.failure,
        errorMessage: e.toString(),
      ));
      return;
    }

    _devicesSubscription = _deviceRepository.watchDevices().listen(
      (devices) {
        emit(state.copyWith(
          status: DevicesStatus.success,
          devices: devices,
        ));
      },
      onError: (e) {
        emit(state.copyWith(
          status: DevicesStatus.failure,
          errorMessage: e.toString(),
        ));
      },
    );
  }

  /// Updates device settings (name, location, enabled) locally and in Firebase.
  void updateDevice(Device updated) {
    _deviceRepository.updateDevice(updated);
    final currentList = List<Device>.from(state.devices);
    final idx = currentList.indexWhere((d) => d.id == updated.id);
    if (idx != -1) {
      currentList[idx] = updated;
    }
    emit(state.copyWith(devices: currentList));
  }

  /// Sends valve command to Firebase and tracks verification state.
  Future<void> toggleValve(String deviceId, bool open) async {
    final device = state.findDevice(deviceId);
    if (device == null) return;

    device.valveOpen = open;
    device.verify = Verify.pending;
    emit(state.copyWith());

    await _deviceRepository.setValve(deviceId, open);
    emit(state.copyWith());
  }

  @override
  Future<void> close() {
    _devicesSubscription?.cancel();
    return super.close();
  }
}
