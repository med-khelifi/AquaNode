import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:aqua_node/core/enums/enums.dart';
import 'package:aqua_node/core/models/command.dart';
import 'package:aqua_node/data/models/device.dart';
import 'package:aqua_node/data/repositories/device_repository.dart';
import 'package:aqua_node/features/valve/cubit/valve_state.dart';

export 'valve_state.dart';

/// Type alias allowing RelayCubit to be used interchangeably with ValveCubit.
typedef RelayCubit = ValveCubit;

/// Cubit managing smart relay / valve state with Firebase service commands.
class ValveCubit extends Cubit<ValveControlState> {
  final DeviceRepository _deviceRepository;
  StreamSubscription<Device?>? _deviceSubscription;
  StreamSubscription<Command?>? _commandSubscription;

  ValveCubit({
    required DeviceRepository deviceRepository,
    Device? initialDevice,
  })  : _deviceRepository = deviceRepository,
        super(ValveControlState(
          status:
              initialDevice != null ? ValveStatus.success : ValveStatus.initial,
          device: initialDevice,
        )) {
    if (initialDevice != null) {
      _listenToDevice(initialDevice.id);
    }
  }

  void _listenToDevice(String deviceId) {
    _deviceSubscription?.cancel();
    _deviceSubscription = _deviceRepository.watchDevice(deviceId).listen(
      (updated) {
        if (updated != null) {
          emit(state.copyWith(
            status: ValveStatus.success,
            device: updated,
          ));
        }
      },
      onError: (err) {
        emit(state.copyWith(
          errorMessage: 'Device stream note: $err',
        ));
      },
    );
  }

  /// Sends a valve/relay command (open/close) to Firebase and monitors execution.
  Future<void> toggleValve(bool open) async {
    final dev = state.device;
    if (dev == null) return;

    final action = open ? CommandAction.open : CommandAction.close;

    // Optimistic UI state
    dev.valveOpen = open;
    dev.verify = Verify.pending;
    emit(state.copyWith(
      isSubmitting: true,
      device: dev,
      errorMessage: null,
      successMessage: null,
    ));

    try {
      final commandId = await _deviceRepository.sendValveCommand(dev.id, action);

      await _commandSubscription?.cancel();
      _commandSubscription = _deviceRepository.watchCommand(commandId).listen(
        (cmd) {
          if (cmd == null) return;

          if (cmd.status == CommandStatus.executed) {
            dev.valveOpen = open;
            dev.verify = Verify.verified;
            emit(state.copyWith(
              isSubmitting: false,
              device: dev,
              activeCommand: () => cmd,
              successMessage:
                  'Relay command executed: valve is now ${open ? 'open' : 'closed'}.',
            ));
          } else if (cmd.status == CommandStatus.failed ||
              cmd.status == CommandStatus.expired) {
            dev.verify = Verify.failed;
            emit(state.copyWith(
              isSubmitting: false,
              device: dev,
              activeCommand: () => cmd,
              errorMessage:
                  cmd.resultMessage ?? 'Relay command failed on device.',
            ));
          } else if (cmd.status == CommandStatus.cancelled) {
            emit(state.copyWith(
              isSubmitting: false,
              activeCommand: () => cmd,
              errorMessage: 'Relay command was cancelled.',
            ));
          } else {
            // Command is pending or received by IoT hardware
            emit(state.copyWith(
              activeCommand: () => cmd,
            ));
          }
        },
        onError: (err) {
          dev.verify = Verify.failed;
          emit(state.copyWith(
            isSubmitting: false,
            device: dev,
            errorMessage: 'Error tracking command: $err',
          ));
        },
      );
    } catch (e) {
      dev.verify = Verify.failed;
      emit(state.copyWith(
        isSubmitting: false,
        device: dev,
        errorMessage: 'Failed to send relay command: $e',
      ));
    }
  }

  /// Cancels an in-flight command while it is still pending in Firebase.
  Future<void> cancelActiveCommand() async {
    final cmd = state.activeCommand;
    if (cmd == null || cmd.status != CommandStatus.pending) return;

    try {
      await _deviceRepository.cancelCommand(cmd.id);
      emit(state.copyWith(
        isSubmitting: false,
        successMessage: 'Command cancelled.',
      ));
    } catch (e) {
      emit(state.copyWith(errorMessage: 'Could not cancel command: $e'));
    }
  }

  @override
  Future<void> close() {
    _deviceSubscription?.cancel();
    _commandSubscription?.cancel();
    return super.close();
  }
}
