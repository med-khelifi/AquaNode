import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:aqua_node/core/services/firebase/firebase.dart';
import 'package:aqua_node/data/models/device.dart';
import 'package:aqua_node/data/repositories/device_repository.dart';
import 'package:aqua_node/features/history/cubit/history_state.dart';

export 'history_state.dart';

class HistoryCubit extends Cubit<HistoryState> {
  final DeviceRepository _deviceRepository;

  HistoryCubit({required DeviceRepository deviceRepository})
      : _deviceRepository = deviceRepository,
        super(const HistoryState());

  Future<void> fetchHistory(Device device, Range range) async {
    emit(state.copyWith(status: HistoryStatus.loading, range: range));
    try {
      final samples = await _deviceRepository.getHistory(device, range);
      emit(state.copyWith(
        status: HistoryStatus.success,
        data: samples,
        range: range,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: HistoryStatus.failure,
        errorMessage: FirebaseService.firestoreMessage(e),
        range: range,
      ));
    }
  }
}
