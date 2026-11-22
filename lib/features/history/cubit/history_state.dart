import 'package:equatable/equatable.dart';
import 'package:aqua_node/data/models/device.dart';

enum HistoryStatus { initial, loading, success, failure }

class HistoryState extends Equatable {
  final HistoryStatus status;
  final List<Sample> data;
  final Range range;
  final String? errorMessage;

  const HistoryState({
    this.status = HistoryStatus.initial,
    this.data = const [],
    this.range = Range.h24,
    this.errorMessage,
  });

  HistoryState copyWith({
    HistoryStatus? status,
    List<Sample>? data,
    Range? range,
    String? errorMessage,
  }) =>
      HistoryState(
        status: status ?? this.status,
        data: data ?? this.data,
        range: range ?? this.range,
        errorMessage: errorMessage,
      );

  @override
  List<Object?> get props => [status, data, range, errorMessage];
}
