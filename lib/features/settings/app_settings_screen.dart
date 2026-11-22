import 'package:flutter/material.dart';
import 'package:aqua_node/state/app_state.dart';

class AppSettingsScreen extends StatelessWidget {
  const AppSettingsScreen({super.key});
  @override
  Widget build(BuildContext context) => ListenableBuilder(listenable: store, builder: (context, _) => Scaffold(
        appBar: AppBar(title: const Text('Settings')),
        body: ListView(padding: const EdgeInsets.all(16), children: [
          Text('Theme', style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 8),
          SegmentedButton<ThemeMode>(
            segments: const [
              ButtonSegment(value: ThemeMode.system, icon: Icon(Icons.brightness_auto), label: Text('System')),
              ButtonSegment(value: ThemeMode.light, icon: Icon(Icons.light_mode), label: Text('Light')),
              ButtonSegment(value: ThemeMode.dark, icon: Icon(Icons.dark_mode), label: Text('Dark')),
            ],
            selected: {store.themeMode}, showSelectedIcon: false, onSelectionChanged: (s) => store.setTheme(s.first)),
          const SizedBox(height: 20),
          Text('Units', style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 8),
          SegmentedButton<bool>(
            segments: const [ButtonSegment(value: false, label: Text('°C')), ButtonSegment(value: true, label: Text('°F'))],
            selected: {store.fahrenheit}, showSelectedIcon: false, onSelectionChanged: (s) => store.setUnits(s.first)),
          const SizedBox(height: 20),
          Card(child: Column(children: [
            ListTile(leading: const Icon(Icons.person_outline), title: const Text('Account'), subtitle: Text(store.email)),
            const Divider(height: 1),
            ListTile(leading: const Icon(Icons.logout), title: const Text('Sign out'), onTap: () { Navigator.of(context).popUntil((r) => r.isFirst); store.signOut(); }),
            const Divider(height: 1),
            const ListTile(leading: Icon(Icons.info_outline), title: Text('About'), subtitle: Text('Aqua Node 1.0.0')),
          ])),
        ]),
      ));
}
