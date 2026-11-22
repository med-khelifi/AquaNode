import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:aqua_node/features/auth/cubit/auth_cubit.dart';
import 'package:aqua_node/features/settings/cubit/settings_cubit.dart';

class AppSettingsScreen extends StatelessWidget {
  const AppSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('Theme', style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 8),
          BlocBuilder<SettingsCubit, SettingsState>(
            buildWhen: (prev, curr) => prev.themeMode != curr.themeMode,
            builder: (context, state) {
              return SegmentedButton<ThemeMode>(
                segments: const [
                  ButtonSegment(
                    value: ThemeMode.system,
                    icon: Icon(Icons.brightness_auto),
                    label: Text('System'),
                  ),
                  ButtonSegment(
                    value: ThemeMode.light,
                    icon: Icon(Icons.light_mode),
                    label: Text('Light'),
                  ),
                  ButtonSegment(
                    value: ThemeMode.dark,
                    icon: Icon(Icons.dark_mode),
                    label: Text('Dark'),
                  ),
                ],
                selected: {state.themeMode},
                showSelectedIcon: false,
                onSelectionChanged: (s) =>
                    context.read<SettingsCubit>().setThemeMode(s.first),
              );
            },
          ),
          const SizedBox(height: 20),
          Text('Units', style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 8),
          BlocBuilder<SettingsCubit, SettingsState>(
            buildWhen: (prev, curr) => prev.fahrenheit != curr.fahrenheit,
            builder: (context, state) {
              return SegmentedButton<bool>(
                segments: const [
                  ButtonSegment(value: false, label: Text('°C')),
                  ButtonSegment(value: true, label: Text('°F')),
                ],
                selected: {state.fahrenheit},
                showSelectedIcon: false,
                onSelectionChanged: (s) => context
                    .read<SettingsCubit>()
                    .setTemperatureUnit(s.first),
              );
            },
          ),
          const SizedBox(height: 20),
          BlocBuilder<AuthCubit, AuthState>(
            builder: (context, authState) {
              final email = authState.email ?? '';
              return Card(
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.person_outline),
                      title: const Text('Account'),
                      subtitle: Text(email),
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.logout),
                      title: const Text('Sign out'),
                      onTap: () {
                        Navigator.of(context).popUntil((r) => r.isFirst);
                        context.read<AuthCubit>().signOut();
                      },
                    ),
                    const Divider(height: 1),
                    const ListTile(
                      leading: Icon(Icons.info_outline),
                      title: Text('About'),
                      subtitle: Text('Aqua Node 1.0.0'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
