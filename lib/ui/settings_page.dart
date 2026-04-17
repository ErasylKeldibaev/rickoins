import 'package:flutter/material.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool notifications = true;
  bool darkMode = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        centerTitle: true,
      ),
      body: ListView(
        children: [
          SwitchListTile(
            value: notifications,
            onChanged: (value) {
              setState(() {
                notifications = value;
              });
            },
            title: const Text('Notifications'),
            subtitle: const Text('Demo setting'),
          ),
          SwitchListTile(
            value: darkMode,
            onChanged: (value) {
              setState(() {
                darkMode = value;
              });
            },
            title: const Text('Dark mode'),
            subtitle: const Text('Demo setting'),
          ),
          const ListTile(
            leading: Icon(Icons.info_outline),
            title: Text('About app'),
            subtitle: Text('Rickoins project'),
          ),
        ],
      ),
    );
  }
}