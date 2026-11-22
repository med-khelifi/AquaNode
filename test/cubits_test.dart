import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:aqua_node/core/enums/enums.dart';
import 'package:aqua_node/core/models/command.dart';
import 'package:aqua_node/data/models/device.dart';
import 'package:aqua_node/data/repositories/auth_repository.dart';
import 'package:aqua_node/data/repositories/device_repository.dart';
import 'package:aqua_node/features/auth/cubit/auth_cubit.dart';
import 'package:aqua_node/features/dashboard/cubit/devices_cubit.dart';
import 'package:aqua_node/features/history/cubit/history_cubit.dart';
import 'package:aqua_node/features/settings/cubit/settings_cubit.dart';
import 'package:aqua_node/features/valve/cubit/valve_cubit.dart';

/// Test double for AuthRepository isolated in unit tests
class TestAuthRepository extends AuthRepository {
  User? _user;
  final _controller = StreamController<User?>.broadcast();

  @override
  User? get currentUser => _user;

  @override
  Stream<User?> get authState => _controller.stream;

  @override
  Future<String?> signIn(String email, String password) async {
    await Future.delayed(const Duration(milliseconds: 20));
    if (password == 'wrong123') {
      return 'Incorrect email or password.';
    }
    return null;
  }

  @override
  Future<void> signOut() async {
    _user = null;
    _controller.add(null);
  }

  void dispose() {
    _controller.close();
  }
}

/// Test double for DeviceRepository isolated in unit tests
class TestDeviceRepository extends DeviceRepository {
  final List<Device> _devices = [
    Device(
      'AQN-001A',
      'Greenhouse Tank',
      'Greenhouse',
      '1.4.2',
      Conn.online,
      DateTime.now(),
      temp: 22.4,
      hum: 61,
      valveOpen: true,
      verify: Verify.verified,
    ),
    Device(
      'AQN-002B',
      'Pump Room',
      'Basement',
      '1.4.2',
      Conn.online,
      DateTime.now(),
      temp: 18.9,
      hum: 72,
      valveOpen: false,
      verify: Verify.verified,
    ),
    Device(
      'AQN-003C',
      'Garden Line',
      'Backyard',
      '1.3.9',
      Conn.offline,
      DateTime.now(),
      temp: 25.1,
      hum: 48,
      valveOpen: false,
      verify: Verify.unknown,
    ),
    Device('AQN-004D', 'Spare Node', 'Unassigned', '1.4.2', Conn.never, null),
  ];

  final Map<String, Command> _commands = {};
  final _devicesController = StreamController<List<Device>>.broadcast();

  @override
  Stream<List<Device>> watchDevices() async* {
    yield List<Device>.from(_devices);
    yield* _devicesController.stream;
  }

  @override
  Future<List<Device>> getDevices() async {
    return List<Device>.from(_devices);
  }

  @override
  Stream<Device?> watchDevice(String deviceId) async* {
    yield _devices.where((d) => d.id == deviceId).firstOrNull;
  }

  @override
  Future<void> updateDevice(Device updated) async {
    final idx = _devices.indexWhere((d) => d.id == updated.id);
    if (idx != -1) {
      _devices[idx] = updated;
      _devicesController.add(List<Device>.from(_devices));
    }
  }

  @override
  Future<String> sendValveCommand(String deviceId, CommandAction action) async {
    final cmdId = 'cmd_${DateTime.now().millisecondsSinceEpoch}';
    _commands[cmdId] = Command(
      id: cmdId,
      deviceId: deviceId,
      ownerUid: 'test_user',
      requestedBy: 'test_user',
      action: action,
      status: CommandStatus.pending,
      createdAt: DateTime.now(),
    );
    return cmdId;
  }

  @override
  Stream<Command?> watchCommand(String commandId) async* {
    final cmd = _commands[commandId];
    if (cmd != null) {
      yield cmd;
      await Future.delayed(const Duration(milliseconds: 30));
      final executed = Command(
        id: cmd.id,
        deviceId: cmd.deviceId,
        ownerUid: cmd.ownerUid,
        requestedBy: cmd.requestedBy,
        action: cmd.action,
        status: CommandStatus.executed,
        createdAt: cmd.createdAt,
        receivedAt: DateTime.now(),
        completedAt: DateTime.now(),
      );
      _commands[commandId] = executed;
      yield executed;
    }
  }

  @override
  Future<void> cancelCommand(String commandId) async {
    final cmd = _commands[commandId];
    if (cmd != null) {
      _commands[commandId] = Command(
        id: cmd.id,
        deviceId: cmd.deviceId,
        ownerUid: cmd.ownerUid,
        requestedBy: cmd.requestedBy,
        action: cmd.action,
        status: CommandStatus.cancelled,
        createdAt: cmd.createdAt,
      );
    }
  }

  @override
  Future<bool> setValve(String deviceId, bool open) async {
    final d = _devices.firstWhere((dev) => dev.id == deviceId);
    d.valveOpen = open;
    d.verify = Verify.verified;
    return true;
  }

  @override
  Future<List<Sample>> getHistory(Device d, Range r) async {
    return [
      Sample(DateTime.now().subtract(const Duration(minutes: 30)), 22.0, 60.0),
      Sample(DateTime.now(), 23.0, 58.0),
    ];
  }
}

void main() {
  group('AuthCubit', () {
    late TestAuthRepository authRepository;
    late AuthCubit authCubit;

    setUp(() {
      authRepository = TestAuthRepository();
      authCubit = AuthCubit(authRepository: authRepository);
    });

    tearDown(() {
      authCubit.close();
      authRepository.dispose();
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
    late TestDeviceRepository deviceRepository;
    late DevicesCubit devicesCubit;

    setUp(() {
      deviceRepository = TestDeviceRepository();
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

    test('toggleValve sends command and updates device state', () async {
      await devicesCubit.loadDevices();
      final device = devicesCubit.state.findDevice('AQN-001A')!;
      expect(device.valveOpen, true);

      await devicesCubit.toggleValve('AQN-001A', false);
      final updated = devicesCubit.state.findDevice('AQN-001A')!;
      expect(updated.valveOpen, false);
    });

    test('updateDevice persists settings updates', () async {
      await devicesCubit.loadDevices();
      final device = devicesCubit.state.findDevice('AQN-001A')!;
      device.name = 'Updated Tank Name';
      device.location = 'Roof';
      device.enabled = false;

      devicesCubit.updateDevice(device);
      final updated = devicesCubit.state.findDevice('AQN-001A')!;
      expect(updated.name, 'Updated Tank Name');
      expect(updated.location, 'Roof');
      expect(updated.enabled, false);
    });

    test('filter and search correctly filter devices', () async {
      await devicesCubit.loadDevices();
      expect(devicesCubit.state.filteredDevices.length, 4);

      devicesCubit.setFilter(DeviceFilterType.active);
      expect(devicesCubit.state.filter, DeviceFilterType.active);
      expect(devicesCubit.state.filteredDevices.length, 2);

      devicesCubit.setFilter(DeviceFilterType.inactive);
      expect(devicesCubit.state.filter, DeviceFilterType.inactive);
      expect(devicesCubit.state.filteredDevices.length, 2);

      devicesCubit.setFilter(DeviceFilterType.all);
      devicesCubit.setSearchQuery('Greenhouse');
      expect(devicesCubit.state.filteredDevices.length, 1);
      expect(devicesCubit.state.filteredDevices.first.id, 'AQN-001A');
    });
  });

  group('HistoryCubit', () {
    late TestDeviceRepository deviceRepository;
    late HistoryCubit historyCubit;

    setUp(() {
      deviceRepository = TestDeviceRepository();
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

  group('ValveCubit / RelayCubit', () {
    late TestDeviceRepository deviceRepository;
    late Device testDevice;
    late ValveCubit valveCubit;

    setUp(() {
      deviceRepository = TestDeviceRepository();
      testDevice = Device(
        'AQN-TEST',
        'Test Tank',
        'Lab',
        '1.0',
        Conn.online,
        DateTime.now(),
        valveOpen: false,
        verify: Verify.verified,
      );
      valveCubit = ValveCubit(
        deviceRepository: deviceRepository,
        initialDevice: testDevice,
      );
    });

    tearDown(() {
      valveCubit.close();
    });

    test('initial state has device and correct open/pending properties', () {
      expect(valveCubit.state.status, ValveStatus.success);
      expect(valveCubit.state.isOpen, false);
      expect(valveCubit.state.isPending, false);
      expect(valveCubit.state.device?.name, 'Test Tank');
    });

    test('toggleValve sends command, monitors execution and updates state', () async {
      expectLater(
        valveCubit.stream,
        emitsThrough(
          isA<ValveControlState>()
              .having((s) => s.isOpen, 'isOpen', true)
              .having((s) => s.successMessage, 'successMessage', isNotNull),
        ),
      );

      await valveCubit.toggleValve(true);
      expect(valveCubit.state.isOpen, true);
    });

    test('cancelActiveCommand cancels a pending relay command', () async {
      final cmdId = await deviceRepository.sendValveCommand(
        testDevice.id,
        CommandAction.open,
      );
      await deviceRepository.cancelCommand(cmdId);
      final streamCmd = await deviceRepository.watchCommand(cmdId).first;
      expect(streamCmd?.status, CommandStatus.cancelled);
    });

    test('RelayCubit typedef works seamlessly as an alias for ValveCubit', () {
      final RelayCubit relay = ValveCubit(
        deviceRepository: deviceRepository,
        initialDevice: testDevice,
      );
      expect(relay, isA<ValveCubit>());
      relay.close();
    });
  });

  group('DeviceRepository Firebase commands', () {
    late TestDeviceRepository repo;

    setUp(() {
      repo = TestDeviceRepository();
    });

    test('sendValveCommand creates a pending command and returns commandId', () async {
      final cmdId = await repo.sendValveCommand('AQN-001A', CommandAction.open);
      expect(cmdId, isNotEmpty);
      expect(cmdId.startsWith('cmd_'), true);
    });

    test('watchCommand yields command stream with progression', () async {
      final cmdId = await repo.sendValveCommand('AQN-001A', CommandAction.close);
      final first = await repo.watchCommand(cmdId).first;
      expect(first, isNotNull);
      expect(first?.deviceId, 'AQN-001A');
      expect(first?.action, CommandAction.close);
    });

    test('watchDevice yields device by ID', () async {
      final dev = await repo.watchDevice('AQN-001A').first;
      expect(dev, isNotNull);
      expect(dev?.id, 'AQN-001A');
      expect(dev?.name, 'Greenhouse Tank');
    });
  });
}
