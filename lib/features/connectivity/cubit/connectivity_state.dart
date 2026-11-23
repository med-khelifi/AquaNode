import 'package:equatable/equatable.dart';

enum ConnectivityStatus {
  connected,
  disconnected,
  checking,
}

class ConnectivityState extends Equatable {
  final ConnectivityStatus status;
  final String? errorMessage;
  final DateTime? lastChecked;

  const ConnectivityState({
    this.status = ConnectivityStatus.connected,
    this.errorMessage,
    this.lastChecked,
  });

  bool get isConnected => status == ConnectivityStatus.connected;
  bool get isDisconnected => status == ConnectivityStatus.disconnected;
  bool get isChecking => status == ConnectivityStatus.checking;

  ConnectivityState copyWith({
    ConnectivityStatus? status,
    String? errorMessage,
    DateTime? lastChecked,
  }) {
    return ConnectivityState(
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
      lastChecked: lastChecked ?? this.lastChecked,
    );
  }

  @override
  List<Object?> get props => [status, errorMessage, lastChecked];
}
