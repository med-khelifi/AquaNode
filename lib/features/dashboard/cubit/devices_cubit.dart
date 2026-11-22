import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:aqua_node/data/models/device.dart';
import 'package:aqua_node/data/repositories/device_repository.dart';
import 'package:aqua_node/features/dashboard/cubit/devices_state.dart';

export 'devices_state.dart';

class DevicesCubit extends Cubit<DevicesState> {
  final DeviceRepository _deviceRepository;

  DevicesCubit({required DeviceRepository deviceRepository})
      : _deviceRepository = deviceRepository,
        super(const DevicesState());

  Future<void> loadDevices() async {
    emit(state.copyWith(status: DevicesStatus.loading));
    try {
      final devices = await _deviceRepository.getDevices();
      emit(state.copyWith(
        status: DevicesStatus.success,
        devices: devices,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: DevicesStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }

  void updateDevice(Device updated) {
    _deviceRepository.updateDevice(updated);
    emit(state.copyWith());
  }

  Future<void> toggleValve(String deviceId, bool open) async {
    final device = state.findDevice(deviceId);
    if (device == null) return;

    device.valveOpen = open;
    device.verify = Verify.pending;
    emit(state.copyWith());

    await _deviceRepository.setValve(deviceId, open);
    emit(state.copyWith());
  }
}
