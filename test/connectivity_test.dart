import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:aqua_node/app.dart';
import 'package:aqua_node/core/services/connectivity/connectivity_service.dart';
import 'package:aqua_node/core/theme/dark_theme.dart';
import 'package:aqua_node/core/theme/light_theme.dart';
import 'package:aqua_node/features/connectivity/cubit/connectivity_cubit.dart';
import 'package:aqua_node/features/connectivity/screens/no_connection_screen.dart';

void main() {
  group('ConnectivityService', () {
    test('hasConnection returns true for wifi, mobile, ethernet', () {
      expect(AppConnectivityService.hasConnection([ConnectivityResult.wifi]), true);
      expect(AppConnectivityService.hasConnection([ConnectivityResult.mobile]), true);
      expect(AppConnectivityService.hasConnection([ConnectivityResult.ethernet]), true);
      expect(AppConnectivityService.hasConnection([ConnectivityResult.vpn]), true);
      expect(
        AppConnectivityService.hasConnection([
          ConnectivityResult.none,
          ConnectivityResult.wifi,
        ]),
        true,
      );
    });

    test('hasConnection returns false for none or empty list', () {
      expect(AppConnectivityService.hasConnection([ConnectivityResult.none]), false);
      expect(AppConnectivityService.hasConnection([]), false);
    });

    test('FakeConnectivityService accurately updates state and streams', () async {
      final fake = FakeConnectivityService(isConnected: true);
      expect(fake.isConnected, true);
      expect(await fake.checkConnection(), true);

      expectLater(fake.onConnectivityChanged, emitsInOrder([false, true]));

      fake.setConnected(false);
      expect(fake.isConnected, false);
      expect(await fake.checkConnection(), false);

      fake.setConnected(true);
      expect(fake.isConnected, true);

      fake.dispose();
    });
  });

  group('ConnectivityCubit', () {
    late FakeConnectivityService fakeService;
    late ConnectivityCubit cubit;

    setUp(() {
      fakeService = FakeConnectivityService(isConnected: true);
    });

    tearDown(() {
      cubit.close();
      fakeService.dispose();
    });

    test('initial state defaults to connected when initialConnected is true', () {
      cubit = ConnectivityCubit(
        connectivityService: fakeService,
        initialConnected: true,
      );
      expect(cubit.state.status, ConnectivityStatus.connected);
      expect(cubit.state.isConnected, true);
      expect(cubit.state.isDisconnected, false);
    });

    test('initial state sets disconnected when initialConnected is false', () {
      fakeService = FakeConnectivityService(isConnected: false);
      cubit = ConnectivityCubit(
        connectivityService: fakeService,
        initialConnected: false,
      );
      expect(cubit.state.status, ConnectivityStatus.disconnected);
      expect(cubit.state.isConnected, false);
      expect(cubit.state.isDisconnected, true);
    });

    test('emits disconnected and connected as stream updates', () async {
      cubit = ConnectivityCubit(
        connectivityService: fakeService,
        initialConnected: true,
      );

      expectLater(
        cubit.stream,
        emitsInOrder([
          isA<ConnectivityState>().having(
            (s) => s.status,
            'status',
            ConnectivityStatus.disconnected,
          ),
          isA<ConnectivityState>().having(
            (s) => s.status,
            'status',
            ConnectivityStatus.connected,
          ),
        ]),
      );

      fakeService.setConnected(false);
      await Future<void>.delayed(const Duration(milliseconds: 10));
      fakeService.setConnected(true);
    });

    test('checkConnection emits checking then updates to connected/disconnected', () async {
      cubit = ConnectivityCubit(
        connectivityService: fakeService,
        initialConnected: false,
      );

      final future = cubit.checkConnection();
      expect(cubit.state.status, ConnectivityStatus.checking);
      expect(cubit.state.isChecking, true);

      final result = await future;
      expect(result, true);
      expect(cubit.state.status, ConnectivityStatus.connected);
    });
  });

  group('NoConnectionScreen Widget', () {
    testWidgets('renders all visual elements in light theme', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: lightTheme,
          darkTheme: darkTheme,
          themeMode: ThemeMode.light,
          home: const NoConnectionScreen(),
        ),
      );

      expect(find.byType(NoConnectionScreen), findsOneWidget);
      expect(find.text('No Connection'), findsOneWidget);
      expect(find.text('No Internet Connection'), findsOneWidget);
      expect(find.byIcon(Icons.wifi_off_rounded), findsOneWidget);
      expect(find.text('Troubleshooting steps'), findsOneWidget);
      expect(find.text('Make sure Wi-Fi or cellular data is enabled.'), findsOneWidget);
      expect(find.text('Check that Airplane mode is turned off.'), findsOneWidget);
      expect(find.text('Confirm your router or access point has internet access.'), findsOneWidget);
      expect(find.text('Try Again'), findsOneWidget);
      expect(find.text('Automatically reconnects when back online'), findsOneWidget);
    });

    testWidgets('renders properly in dark theme', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: lightTheme,
          darkTheme: darkTheme,
          themeMode: ThemeMode.dark,
          home: const NoConnectionScreen(),
        ),
      );

      expect(find.byType(NoConnectionScreen), findsOneWidget);
      expect(find.text('No Internet Connection'), findsOneWidget);
      expect(find.text('Try Again'), findsOneWidget);
    });

    testWidgets('calls onRetry callback when Try Again is tapped', (tester) async {
      var retried = false;
      await tester.pumpWidget(
        MaterialApp(
          theme: lightTheme,
          home: NoConnectionScreen(
            onRetry: () => retried = true,
          ),
        ),
      );

      final buttonFinder = find.text('Try Again');
      await tester.ensureVisible(buttonFinder);
      await tester.tap(buttonFinder);
      await tester.pump();
      expect(retried, true);
    });

    testWidgets('displays checking progress indicator when isChecking is true', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: lightTheme,
          home: const NoConnectionScreen(isChecking: true),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Checking Connection…'), findsOneWidget);
    });

    testWidgets('shows snackbar when retry from cubit fails while still offline', (tester) async {
      final fakeService = FakeConnectivityService(isConnected: false);
      final cubit = ConnectivityCubit(
        connectivityService: fakeService,
        initialConnected: false,
      );

      await tester.pumpWidget(
        MaterialApp(
          theme: lightTheme,
          home: BlocProvider.value(
            value: cubit,
            child: const ScaffoldMessenger(
              child: NoConnectionScreen(),
            ),
          ),
        ),
      );

      final buttonFinder = find.text('Try Again');
      await tester.ensureVisible(buttonFinder);
      await tester.tap(buttonFinder);
      await tester.pump(); // Start async check
      await tester.pumpAndSettle(); // Settle future and snackbar animation

      expect(
        find.text('Still offline. Please check your network and try again.'),
        findsOneWidget,
      );

      cubit.close();
      fakeService.dispose();
    });
  });

  group('AquaApp Offline Integration', () {
    testWidgets('shows NoConnectionScreen when AquaApp starts offline', (tester) async {
      final fake = FakeConnectivityService(isConnected: false);

      await tester.pumpWidget(
        AquaApp(
          connectivityService: fake,
          isConnected: false,
        ),
      );
      await tester.pump();

      expect(find.byType(NoConnectionScreen), findsOneWidget);
      expect(find.text('No Internet Connection'), findsOneWidget);
      expect(find.text('Try Again'), findsOneWidget);

      fake.dispose();
    });

    testWidgets('dynamically hides NoConnectionScreen when back online', (tester) async {
      final fake = FakeConnectivityService(isConnected: false);

      await tester.pumpWidget(
        AquaApp(
          connectivityService: fake,
          isConnected: false,
        ),
      );
      await tester.pump();

      expect(find.byType(NoConnectionScreen), findsOneWidget);

      // Restore network
      fake.setConnected(true);
      await tester.pumpAndSettle();

      // NoConnectionScreen should be gone, showing main flow (SignInScreen)
      expect(find.byType(NoConnectionScreen), findsNothing);
      expect(find.text('Sign in'), findsWidgets);

      fake.dispose();
    });
  });
}
