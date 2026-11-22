import 'package:flutter/material.dart';
import 'package:aqua_node/core/theme/dark_theme.dart';
import 'package:aqua_node/core/theme/light_theme.dart';
import 'package:aqua_node/features/auth/sign_in_screen.dart';
import 'package:aqua_node/features/dashboard/dashboard_screen.dart';
import 'package:aqua_node/state/app_state.dart';

class AquaApp extends StatelessWidget {
  const AquaApp({super.key});

  @override
  Widget build(BuildContext context) => ListenableBuilder(
        listenable: store,
        builder: (_, __) => MaterialApp(
          title: 'Aqua Node',
          debugShowCheckedModeBanner: false,
          theme: lightTheme,
          darkTheme: darkTheme,
          themeMode: store.themeMode,
          home: store.signedIn ? const DashboardScreen() : const SignInScreen(),
        ),
      );
}
