import 'package:equatable/equatable.dart';
import 'package:aqua_node/core/enums/enums.dart';
import 'package:aqua_node/core/models/command.dart';
import 'package:aqua_node/data/models/device.dart';

enum ValveStatus { initial, loading, success, failure }

/// Represents the control and monitoring state of an IoT valve relay.
class ValveControlState extends Equatable {
  final ValveStatus status;
  final Device? device;
  final Command? activeCommand;
  final bool isSubmitting;
  final String? errorMessage;
  final String? successMessage;

  const ValveControlState({
    this.status = ValveStatus.initial,
    this.device,
    this.activeCommand,
    this.isSubmitting = false,
    this.errorMessage,
    this.successMessage,
  });

  bool get isOpen => device?.valveOpen ?? false;
  bool get isPending =>
      device?.verify == Verify.pending ||
      (activeCommand != null &&
          (activeCommand!.status == CommandStatus.pending ||
              activeCommand!.status == CommandStatus.received));
  bool get canCancel =>
      activeCommand != null && activeCommand!.status == CommandStatus.pending;

  ValveControlState copyWith({
    ValveStatus? status,
    Device? device,
    Command? Function()? activeCommand,
    bool? isSubmitting,
    String? errorMessage,
    String? successMessage,
  }) {
    return ValveControlState(
      status: status ?? this.status,
      device: device ?? this.device,
      activeCommand:
          activeCommand != null ? activeCommand() : this.activeCommand,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      errorMessage: errorMessage,
      successMessage: successMessage,
    );
  }

  @override
  List<Object?> get props => [
        status,
        device?.id,
        device?.valveOpen,
        device?.verify,
        activeCommand?.id,
        activeCommand?.status,
        isSubmitting,
        errorMessage,
        successMessage,
      ];
}

typedef RelayControlState = ValveControlState;
