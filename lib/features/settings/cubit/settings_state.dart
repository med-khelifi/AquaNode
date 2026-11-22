import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

class SettingsState extends Equatable {
  final ThemeMode themeMode;
  final bool fahrenheit;

  const SettingsState({
    this.themeMode = ThemeMode.system,
    this.fahrenheit = false,
  });

  String formatTemp(double c) => fahrenheit
      ? '${(c * 9 / 5 + 32).toStringAsFixed(1)} °F'
      : '${c.toStringAsFixed(1)} °C';

  double convertTemp(double c) => fahrenheit ? c * 9 / 5 + 32 : c;

  String get tempUnit => fahrenheit ? '°F' : '°C';

  SettingsState copyWith({
    ThemeMode? themeMode,
    bool? fahrenheit,
  }) =>
      SettingsState(
        themeMode: themeMode ?? this.themeMode,
        fahrenheit: fahrenheit ?? this.fahrenheit,
      );

  @override
  List<Object?> get props => [themeMode, fahrenheit];
}
