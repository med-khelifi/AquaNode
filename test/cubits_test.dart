import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:aqua_node/data/models/device.dart';
import 'package:aqua_node/data/repositories/auth_repository.dart';
import 'package:aqua_node/data/repositories/device_repository.dart';
import 'package:aqua_node/features/auth/cubit/auth_cubit.dart';
import 'package:aqua_node/features/dashboard/cubit/devices_cubit.dart';
import 'package:aqua_node/features/history/cubit/history_cubit.dart';
import 'package:aqua_node/features/settings/cubit/settings_cubit.dart';

void main() {
  group('AuthCubit', () {
    late AuthRepository authRepository;
    late AuthCubit authCubit;

    setUp(() {
      authRepository = AuthRepository();
      authCubit = AuthCubit(authRepository: authRepository);
    });

    tearDown(() {
      authCubit.close();
    });

    test('initial state has AuthStatus.initial', () {
      expect(authCubit.state.status, AuthStatus.initial);
      expect(authCubit.state.isAuthenticated, false);
      expect(authCubit.state.isLoading, false);
    });

    test('emits loading and authenticated on successful signIn', () async {
      expectLater(
        authCubit.stream,
        emitsInOrder([
          const AuthState(status: AuthStatus.loading),
          const AuthState(
            status: AuthStatus.authenticated,
            email: 'user@aquanode.io',
          ),
        ]),
      );

      await authCubit.signIn('user@aquanode.io', 'pass123');
    });

    test('emits loading and failure on wrong password', () async {
      expectLater(
        authCubit.stream,
        emitsInOrder([
          const AuthState(status: AuthStatus.loading),
          const AuthState(
            status: AuthStatus.failure,
            errorMessage: 'Incorrect email or password.',
          ),
        ]),
      );

      await authCubit.signIn('user@aquanode.io', 'wrong123');
    });

    test('signOut resets state to initial', () {
      authCubit.signOut();
      expect(authCubit.state.status, AuthStatus.initial);
      expect(authCubit.state.email, null);
    });
  });

  group('SettingsCubit', () {
    late SettingsCubit settingsCubit;

    setUp(() {
      settingsCubit = SettingsCubit();
    });

    tearDown(() {
      settingsCubit.close();
    });

    test('initial state has default system theme and celsius', () {
      expect(settingsCubit.state.themeMode, ThemeMode.system);
      expect(settingsCubit.state.fahrenheit, false);
      expect(settingsCubit.state.tempUnit, '°C');
      expect(settingsCubit.state.formatTemp(25), '25.0 °C');
    });

    test('setThemeMode updates themeMode', () {
      settingsCubit.setThemeMode(ThemeMode.dark);
      expect(settingsCubit.state.themeMode, ThemeMode.dark);
    });

    test('setTemperatureUnit updates unit & format', () {
      settingsCubit.setTemperatureUnit(true);
      expect(settingsCubit.state.fahrenheit, true);
      expect(settingsCubit.state.tempUnit, '°F');
      expect(settingsCubit.state.formatTemp(0), '32.0 °F');
    });
  });

  group('DevicesCubit', () {
    late DeviceRepository deviceRepository;
    late DevicesCubit devicesCubit;

    setUp(() {
      deviceRepository = DeviceRepository();
      devicesCubit = DevicesCubit(deviceRepository: deviceRepository);
    });

    tearDown(() {
      devicesCubit.close();
    });

    test('initial state has DevicesStatus.initial', () {
      expect(devicesCubit.state.status, DevicesStatus.initial);
      expect(devicesCubit.state.devices, isEmpty);
    });

    test('loadDevices emits loading then success with device list', () async {
      expectLater(
        devicesCubit.stream,
        emitsInOrder([
          isA<DevicesState>().having((s) => s.status, 'status', DevicesStatus.loading),
          isA<DevicesState>()
              .having((s) => s.status, 'status', DevicesStatus.success)
              .having((s) => s.devices.length, 'devices length', 4)
              .having((s) => s.onlineCount, 'online nodes', 2)
              .having((s) => s.offlineCount, 'offline nodes', 2),
        ]),
      );

      await devicesCubit.loadDevices();
    });
  });

  group('HistoryCubit', () {
    late DeviceRepository deviceRepository;
    late HistoryCubit historyCubit;

    setUp(() {
      deviceRepository = DeviceRepository();
      historyCubit = HistoryCubit(deviceRepository: deviceRepository);
    });

    tearDown(() {
      historyCubit.close();
    });

    test('initial state has HistoryStatus.initial', () {
      expect(historyCubit.state.status, HistoryStatus.initial);
      expect(historyCubit.state.range, Range.h24);
      expect(historyCubit.state.data, isEmpty);
    });

    test('fetchHistory emits loading then success with data', () async {
      final device = Device(
        'AQN-001A',
        'Test Node',
        'Lab',
        '1.0',
        Conn.online,
        DateTime.now(),
        temp: 21,
        hum: 55,
      );

      expectLater(
        historyCubit.stream,
        emitsInOrder([
          const HistoryState(status: HistoryStatus.loading, range: Range.h1),
          isA<HistoryState>()
              .having((s) => s.status, 'status', HistoryStatus.success)
              .having((s) => s.range, 'range', Range.h1)
              .having((s) => s.data.isNotEmpty, 'has data', true),
        ]),
      );

      await historyCubit.fetchHistory(device, Range.h1);
    });
  });
}
