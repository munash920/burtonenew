import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/notification_provider.dart';

class NotificationSettingsScreen extends StatelessWidget {
  const NotificationSettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notification Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Column(
              children: [
                SwitchListTile(
                  title: const Text('Push Notifications'),
                  subtitle: const Text('Receive push notifications'),
                  value: true, // TODO: Connect to actual settings
                  onChanged: (bool value) {
                    // TODO: Implement notification toggle
                  },
                ),
                const Divider(),
                SwitchListTile(
                  title: const Text('Email Notifications'),
                  subtitle: const Text('Receive email notifications'),
                  value: true, // TODO: Connect to actual settings
                  onChanged: (bool value) {
                    // TODO: Implement email notification toggle
                  },
                ),
                const Divider(),
                SwitchListTile(
                  title: const Text('Due Date Reminders'),
                  subtitle: const Text('Get reminded about upcoming due dates'),
                  value: true, // TODO: Connect to actual settings
                  onChanged: (bool value) {
                    // TODO: Implement reminder toggle
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text(
                    'Notification Types',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                CheckboxListTile(
                  title: const Text('Client Updates'),
                  value: true, // TODO: Connect to actual settings
                  onChanged: (bool? value) {
                    // TODO: Implement setting toggle
                  },
                ),
                const Divider(),
                CheckboxListTile(
                  title: const Text('Transaction Alerts'),
                  value: true, // TODO: Connect to actual settings
                  onChanged: (bool? value) {
                    // TODO: Implement setting toggle
                  },
                ),
                const Divider(),
                CheckboxListTile(
                  title: const Text('System Updates'),
                  value: true, // TODO: Connect to actual settings
                  onChanged: (bool? value) {
                    // TODO: Implement setting toggle
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
} 