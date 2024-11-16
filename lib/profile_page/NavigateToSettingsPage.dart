import 'dart:developer';

import 'package:flutter/material.dart';

import '../global_widgets/database_model.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {

  final database = DatabaseModel();
  late bool _darkmodeState = false;

  @override void initState() {
    darkModeCheckInit();
    super.initState();
  }
  Future<void> darkModeCheckInit() async {
    Map<String, String> maps = await database.getUserOptionsAsMaps(); //need to make function to do this
    if(maps["darkmode"] == "true") {
      _darkmodeState = true;
    } else {
      _darkmodeState = false;
    }
    setState(() {}); //needed because of the future

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          // Account Settings
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('Account Settings'),
            subtitle: const Text('Manage your account'),
            onTap: () {
              log('Account Settings');
            },
          ),
          const Divider(),

          // Dark Mode Toggle
          ListTile(
            leading: const Icon(Icons.dark_mode),
            title: const Text('Dark Mode'),
            trailing: Switch(
              inactiveThumbColor: Colors.white,
              inactiveTrackColor: Colors.grey,
              value: _darkmodeState,
              onChanged: (value) {
                database.editUserOption("darkmode", "$value");
                setState(() {
                  _darkmodeState = value;
                });
                _showRestartAppDialog(context);
                log('Dark Mode toggled: $value');
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showRestartAppDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Restart Required'),
          content: const Text('Please restart your app for the changes to take effect.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text('Ok'),
            ),
          ],
        );
      },
    );
  }
}
