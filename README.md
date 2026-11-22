# Aqua Node
Flutter smart-home / industrial IoT dashboard (Light/Dark/System theme, fl_chart history).

## Run
    flutter create . --platforms=android   # generates android/, keeps lib/ and pubspec.yaml
    flutter pub get
    flutter run

Demo login: any valid email + 6+ char password (`wrong123` shows the error state). Data is mocked.

## Structure
    lib/
      main.dart, app.dart        entry + MaterialApp (theme modes)
      core/
        theme/app_theme.dart     tokens from spec section 8 (light + dark)
        utils/format.dart        relative-time helper
        widgets/                 StatusChip (icon + label + color), StateMessage (empty/error)
      data/models/device.dart    Device, Sample, Conn, Verify, Range
      state/app_state.dart       Store (ChangeNotifier): auth, theme, units, devices, mock API
      features/
        auth/                    sign in
        dashboard/               summary, search/filter, widgets/device_card.dart
        device_details/          readings, connection age, valve status
        history/                 range selector, widgets/metric_chart.dart (fl_chart, gaps, downsampling)
        valve/                   open/close, confirm, pending, result, physical warning
        device_settings/         rename, location, firmware, enable, provisioning entry
        settings/                theme, units, account, about
    test/widget_test.dart

## Next steps
- Replace mock methods in state/app_state.dart (signIn, setValve, history) with a repository + real API.
- Persist theme/units (shared_preferences).
- Build the network provisioning flow.
