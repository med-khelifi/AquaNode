import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:aqua_node/core/services/connectivity/connectivity_service.dart';
import 'package:aqua_node/features/connectivity/cubit/connectivity_state.dart';

export 'connectivity_state.dart';

class ConnectivityCubit extends Cubit<ConnectivityState> {
  final ConnectivityService _service;
  StreamSubscription<bool>? _subscription;

  ConnectivityCubit({
    required ConnectivityService connectivityService,
    bool? initialConnected,
  })  : _service = connectivityService,
        super(ConnectivityState(
          status: (initialConnected ?? true)
              ? ConnectivityStatus.connected
              : ConnectivityStatus.disconnected,
        )) {
    _init(initialConnected);
  }

  void _init(bool? initialConnected) {
    _subscription = _service.onConnectivityChanged.listen((connected) {
      if (connected) {
        emit(state.copyWith(
          status: ConnectivityStatus.connected,
          errorMessage: null,
          lastChecked: DateTime.now(),
        ));
      } else {
        emit(state.copyWith(
          status: ConnectivityStatus.disconnected,
          lastChecked: DateTime.now(),
        ));
      }
    });

    if (initialConnected == null) {
      checkConnection();
    }
  }

  /// Triggers a manual connection re-check and updates state.
  Future<bool> checkConnection() async {
    emit(state.copyWith(status: ConnectivityStatus.checking));
    try {
      final connected = await _service.checkConnection();
      emit(state.copyWith(
        status: connected
            ? ConnectivityStatus.connected
            : ConnectivityStatus.disconnected,
        lastChecked: DateTime.now(),
      ));
      return connected;
    } catch (_) {
      emit(state.copyWith(
        status: ConnectivityStatus.disconnected,
        errorMessage: 'Unable to verify connection.',
        lastChecked: DateTime.now(),
      ));
      return false;
    }
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
