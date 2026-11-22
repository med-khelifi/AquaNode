import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:aqua_node/core/theme/app_theme.dart';

void main() {
  group('Theme System & Extensions', () {
    test('light_theme.dart provides valid light ThemeData with StatusColors', () {
      expect(lightTheme.brightness, Brightness.light);
      expect(lightTheme.colorScheme.primary, AppColors.primaryLight);
      expect(lightTheme.scaffoldBackgroundColor, AppColors.backgroundLight);
      expect(lightTheme.textTheme.bodyMedium?.fontFamily, AppTypography.fontFamily);

      final statusColors = lightTheme.extension<StatusColors>();
      expect(statusColors, isNotNull);
      expect(statusColors!.success, AppColors.successLight);
      expect(statusColors.warning, AppColors.warningLight);
      expect(statusColors.error, AppColors.errorLight);
      expect(statusColors.muted, AppColors.mutedLight);

      final shimmerColors = lightTheme.extension<ShimmerColors>();
      expect(shimmerColors, isNotNull);
      expect(shimmerColors!.baseColor, const Color(0xFFE2E8F0));
      expect(shimmerColors.highlightColor, const Color(0xFFF8FAFC));
    });

    test('dark_theme.dart provides valid dark ThemeData with StatusColors', () {
      expect(darkTheme.brightness, Brightness.dark);
      expect(darkTheme.colorScheme.primary, AppColors.primaryDark);
      expect(darkTheme.scaffoldBackgroundColor, AppColors.backgroundDark);
      expect(darkTheme.textTheme.bodyMedium?.fontFamily, AppTypography.fontFamily);

      final statusColors = darkTheme.extension<StatusColors>();
      expect(statusColors, isNotNull);
      expect(statusColors!.success, AppColors.successDark);
      expect(statusColors.warning, AppColors.warningDark);
      expect(statusColors.error, AppColors.errorDark);
      expect(statusColors.muted, AppColors.mutedDark);

      final shimmerColors = darkTheme.extension<ShimmerColors>();
      expect(shimmerColors, isNotNull);
      expect(shimmerColors!.baseColor, const Color(0xFF16243A));
      expect(shimmerColors.highlightColor, const Color(0xFF243653));
    });

    test('buildTheme resolves to lightTheme and darkTheme correctly', () {
      expect(buildTheme(Brightness.light), lightTheme);
      expect(buildTheme(Brightness.dark), darkTheme);
    });

    test('StatusColors copyWith and lerp operate accurately', () {
      final s1 = StatusColors.light();
      final copied = s1.copyWith(success: Colors.purple);
      expect(copied.success, Colors.purple);
      expect(copied.warning, s1.warning);

      final s2 = StatusColors.dark();
      final lerped = s1.lerp(s2, 0.5);
      expect(lerped, isNotNull);
      expect(lerped.success, Color.lerp(s1.success, s2.success, 0.5));
    });

    test('ShimmerColors copyWith and lerp operate accurately for light and dark', () {
      final shimLight = ShimmerColors.light();
      final copied = shimLight.copyWith(baseColor: Colors.grey);
      expect(copied.baseColor, Colors.grey);
      expect(copied.highlightColor, shimLight.highlightColor);

      final shimDark = ShimmerColors.dark();
      final lerped = shimLight.lerp(shimDark, 0.5);
      expect(lerped, isNotNull);
      expect(lerped.baseColor, Color.lerp(shimLight.baseColor, shimDark.baseColor, 0.5));
    });

    testWidgets('Shimmer and ShimmerBox render with theme-aware colors', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: lightTheme,
          darkTheme: darkTheme,
          home: const Scaffold(
            body: DashboardShimmer(),
          ),
        ),
      );

      expect(find.byType(DashboardShimmer), findsOneWidget);
      expect(find.byType(Shimmer), findsOneWidget);
      expect(find.byType(ShimmerBox), findsWidgets);
    });

    testWidgets('ThemeContextExtension and ShimmerWidgetExtension adapt to Light & Dark', (tester) async {
      late BuildContext lightCtx;
      late BuildContext darkCtx;

      await tester.pumpWidget(
        MaterialApp(
          theme: lightTheme,
          darkTheme: darkTheme,
          themeMode: ThemeMode.light,
          home: Builder(
            builder: (ctx) {
              lightCtx = ctx;
              return const Text('light').shimmer(ctx);
            },
          ),
        ),
      );

      expect(lightCtx.shimmerColors.baseColor, const Color(0xFFE2E8F0));
      expect(lightCtx.shimmerColors.highlightColor, const Color(0xFFF8FAFC));

      await tester.pumpWidget(
        MaterialApp(
          theme: lightTheme,
          darkTheme: darkTheme,
          themeMode: ThemeMode.dark,
          home: Builder(
            builder: (ctx) {
              darkCtx = ctx;
              return const Text('dark').shimmer(ctx);
            },
          ),
        ),
      );
      // Allow kThemeAnimationDuration (200ms) to complete theme transition
      await tester.pump(const Duration(milliseconds: 300));

      expect(darkCtx.shimmerColors.baseColor, const Color(0xFF16243A));
      expect(darkCtx.shimmerColors.highlightColor, const Color(0xFF243653));
    });

    test('AppTypography provides clean typography standards', () {
      expect(AppTypography.fontFamily, 'Roboto');
      expect(AppTypography.lightTextTheme.headlineLarge?.color, AppColors.textLight);
      expect(AppTypography.darkTextTheme.headlineLarge?.color, AppColors.textDark);
      expect(AppTypography.lightTextTheme.bodySmall?.color, AppColors.mutedLight);
    });

    testWidgets('ValveShimmer, DeviceDetailsShimmer and DeviceCardShimmer render properly', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: lightTheme,
          darkTheme: darkTheme,
          home: const Scaffold(
            body: SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: Column(
                children: [
                  ValveShimmer(),
                  DeviceDetailsShimmer(),
                  DeviceCardShimmer(),
                ],
              ),
            ),
          ),
        ),
      );

      expect(find.byType(ValveShimmer), findsOneWidget);
      expect(find.byType(DeviceDetailsShimmer), findsOneWidget);
      expect(find.byType(DeviceCardShimmer), findsOneWidget);
    });

    testWidgets('ShimmerContextExtension builds theme-aware placeholders', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: lightTheme,
          darkTheme: darkTheme,
          themeMode: ThemeMode.dark,
          home: Builder(
            builder: (ctx) {
              expect(ctx.isDarkMode, true);
              return Scaffold(
                body: Column(
                  children: [
                    ctx.shimmerBox(width: 100, height: 20),
                    ctx.shimmerCard(height: 80),
                  ],
                ),
              );
            },
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.byType(ShimmerBox), findsWidgets);
    });
  });
}
