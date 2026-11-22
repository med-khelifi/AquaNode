import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:aqua_node/core/theme/dark_theme.dart';
import 'package:aqua_node/core/theme/light_theme.dart';
import 'package:aqua_node/data/repositories/auth_repository.dart';
import 'package:aqua_node/data/repositories/device_repository.dart';
import 'package:aqua_node/features/auth/cubit/auth_cubit.dart';
import 'package:aqua_node/features/auth/sign_in_screen.dart';
import 'package:aqua_node/features/dashboard/cubit/devices_cubit.dart';
import 'package:aqua_node/features/dashboard/dashboard_screen.dart';
import 'package:aqua_node/features/settings/cubit/settings_cubit.dart';

class AquaApp extends StatefulWidget {
  final AuthRepository? authRepository;
  final DeviceRepository? deviceRepository;

  const AquaApp({
    super.key,
    this.authRepository,
    this.deviceRepository,
  });

  @override
  State<AquaApp> createState() => _AquaAppState();
}

class _AquaAppState extends State<AquaApp> {
  late final AuthRepository _authRepository =
      widget.authRepository ?? AuthRepository();
  late final DeviceRepository _deviceRepository =
      widget.deviceRepository ?? DeviceRepository();

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider.value(value: _authRepository),
        RepositoryProvider.value(value: _deviceRepository),
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
            create: (ctx) => DevicesCubit(
              deviceRepository: ctx.read<DeviceRepository>(),
            )..loadDevices(),
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
              home: BlocBuilder<AuthCubit, AuthState>(
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
