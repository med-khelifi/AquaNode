import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:aqua_node/core/services/connectivity/connectivity_service.dart';
import 'package:aqua_node/core/theme/dark_theme.dart';
import 'package:aqua_node/core/theme/light_theme.dart';
import 'package:aqua_node/data/repositories/auth_repository.dart';
import 'package:aqua_node/data/repositories/device_repository.dart';
import 'package:aqua_node/features/auth/cubit/auth_cubit.dart';
import 'package:aqua_node/features/auth/sign_in_screen.dart';
import 'package:aqua_node/features/connectivity/cubit/connectivity_cubit.dart';
import 'package:aqua_node/features/connectivity/screens/no_connection_screen.dart';
import 'package:aqua_node/features/dashboard/cubit/devices_cubit.dart';
import 'package:aqua_node/features/dashboard/dashboard_screen.dart';
import 'package:aqua_node/features/settings/cubit/settings_cubit.dart';

class AquaApp extends StatefulWidget {
  final AuthRepository? authRepository;
  final DeviceRepository? deviceRepository;
  final ConnectivityService? connectivityService;
  final bool? isConnected;

  const AquaApp({
    super.key,
    this.authRepository,
    this.deviceRepository,
    this.connectivityService,
    this.isConnected,
  });

  @override
  State<AquaApp> createState() => _AquaAppState();
}

class _AquaAppState extends State<AquaApp> {
  late final AuthRepository _authRepository =
      widget.authRepository ?? AuthRepository();
  late final DeviceRepository _deviceRepository =
      widget.deviceRepository ?? DeviceRepository();
  late final ConnectivityService _connectivityService =
      widget.connectivityService ?? AppConnectivityService();

  @override
  void dispose() {
    _connectivityService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider.value(value: _authRepository),
        RepositoryProvider.value(value: _deviceRepository),
        RepositoryProvider.value(value: _connectivityService),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (ctx) => AuthCubit(
              authRepository: ctx.read<AuthRepository>(),
            ),
          ),
          BlocProvider(
            create: (_) => SettingsCubit(),
          ),
          BlocProvider(
            create: (ctx) {
              final cubit = DevicesCubit(
                deviceRepository: ctx.read<DeviceRepository>(),
              );
              // Only load devices if already authenticated
              if (ctx.read<AuthRepository>().currentUser != null) {
                cubit.loadDevices();
              }
              return cubit;
            },
          ),
          BlocProvider(
            create: (ctx) => ConnectivityCubit(
              connectivityService: ctx.read<ConnectivityService>(),
              initialConnected: widget.isConnected,
            ),
          ),
        ],
        child: BlocBuilder<SettingsCubit, SettingsState>(
          builder: (context, settingsState) {
            return MaterialApp(
              title: 'Aqua Node',
              debugShowCheckedModeBanner: false,
              theme: lightTheme,
              darkTheme: darkTheme,
              themeMode: settingsState.themeMode,
              builder: (context, child) {
                return BlocConsumer<ConnectivityCubit, ConnectivityState>(
                  listenWhen: (prev, curr) =>
                      !prev.isConnected && curr.isConnected,
                  listener: (context, state) {
                    // Re-load devices from Firebase Firestore when connection is restored
                    if (context.read<AuthRepository>().currentUser != null) {
                      context.read<DevicesCubit>().loadDevices();
                    }
                  },
                  builder: (context, connectivityState) {
                    return Stack(
                      children: [
                        if (child != null) child,
                        if (!connectivityState.isConnected)
                          const Positioned.fill(
                            child: NoConnectionScreen(),
                          ),
                      ],
                    );
                  },
                );
              },
              home: BlocConsumer<AuthCubit, AuthState>(
                listenWhen: (prev, curr) =>
                    prev.status != curr.status && curr.isAuthenticated,
                listener: (context, authState) {
                  // Re-load devices from Firebase Firestore when user signs in
                  context.read<DevicesCubit>().loadDevices();
                },
                builder: (context, authState) {
                  if (authState.isAuthenticated) {
                    return const DashboardScreen();
                  }
                  return const SignInScreen();
                },
              ),
            );
          },
        ),
      ),
    );
  }
}
