import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as path_helper;
import '../../providers/theme_provider.dart';
import '../../providers/auth_provider.dart';
import 'profile_edit_screen.dart';
import 'notification_settings_screen.dart';
import 'widgets/change_password_dialog.dart';
import '../transactions/transaction_history_screen.dart';
import '../../services/sync_service.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  Future<void> _initializeDatabase(BuildContext context) async {
    final databasePath = await getDatabasesPath();
    final dbPath = path_helper.join(databasePath, 'app_data.db');
    await openDatabase(
      dbPath,
      version: 1,
      onCreate: (db, version) {
        db.execute(
          'CREATE TABLE IF NOT EXISTS data (id INTEGER PRIMARY KEY, content TEXT)',
        );
      },
    );
  }

  Future<void> _syncData(BuildContext context) async {
    try {
      final syncService = SyncService();

      // Show loading indicator
      if (!context.mounted) return;
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext dialogContext) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      await syncService.fullSync();

      // Close loading indicator
      if (!context.mounted) return;
      Navigator.pop(context);

      // Show success message
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Data synchronized successfully'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      // Close loading indicator if open
      if (context.mounted) {
        Navigator.pop(context);
      }

      // Show error message
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Sync failed: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    _initializeDatabase(context);

    final themeProvider = Provider.of<ThemeProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;

    final initials = user?.displayName != null ? user!.displayName![0] : 'U';
    final name = user?.displayName ?? 'Unknown User';
    final email = user?.email ?? 'No email';

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? Colors.white : Colors.black;
    final secondaryColor = isDark ? Colors.white70 : Colors.black54;
    final backgroundColor = isDark ? const Color(0xFF191919) : Colors.white;
    final cardColor = isDark ? const Color(0xFF262626) : const Color(0xFFF7F7F7);
    final borderColor = isDark ? Colors.white12 : Colors.black12;

    Widget settingsCard({
      required String title,
      required List<Widget> children,
      EdgeInsets? padding,
    }) {
      return Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderColor),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: secondaryColor,
                  letterSpacing: -0.2,
                ),
              ),
            ),
            const Divider(height: 1),
            Padding(
              padding: padding ?? EdgeInsets.zero,
              child: Column(children: children),
            ),
          ],
        ),
      );
    }

    Widget settingsTile({
      required IconData icon,
      required String title,
      Widget? trailing,
      VoidCallback? onTap,
      Color? iconColor,
      bool showDivider = true,
    }) {
      return Column(
        children: [
          ListTile(
            leading: Icon(icon, size: 20, color: iconColor ?? secondaryColor),
            title: Text(
              title,
              style: TextStyle(
                fontSize: 15,
                color: primaryColor,
                letterSpacing: -0.3,
              ),
            ),
            trailing: trailing ?? Icon(Icons.chevron_right, color: secondaryColor, size: 20),
            onTap: onTap,
          ),
          if (showDivider) Divider(height: 1, color: borderColor),
        ],
      );
    }

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: Text(
          'Settings',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: primaryColor,
            letterSpacing: -0.3,
          ),
        ),
        centerTitle: true,
        backgroundColor: backgroundColor,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Profile Card
          settingsCard(
            title: 'PROFILE',
            padding: const EdgeInsets.symmetric(vertical: 16),
            children: [
              Center(
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundColor: isDark ? Colors.white24 : Colors.black12,
                      child: Text(
                        initials,
                        style: TextStyle(
                          fontSize: 24,
                          color: primaryColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      name,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: primaryColor,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      email,
                      style: TextStyle(
                        fontSize: 14,
                        color: secondaryColor,
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(height: 16),
                    OutlinedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const ProfileEditScreen()),
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: primaryColor,
                        side: BorderSide(color: borderColor),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text('Edit Profile'),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // Preferences Card
          settingsCard(
            title: 'PREFERENCES',
            children: [
              settingsTile(
                icon: Icons.notifications_outlined,
                title: 'Notifications',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const NotificationSettingsScreen()),
                  );
                },
              ),
              settingsTile(
                icon: isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
                title: 'Dark Mode',
                trailing: Switch(
                  value: themeProvider.isDarkMode,
                  onChanged: (value) => themeProvider.toggleTheme(),
                ),
              ),
            ],
          ),

          // Data Management Card
          settingsCard(
            title: 'DATA MANAGEMENT',
            children: [
              settingsTile(
                icon: Icons.history_outlined,
                title: 'Transaction History',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const TransactionHistoryScreen()),
                  );
                },
              ),
              settingsTile(
                icon: Icons.sync_outlined,
                title: 'Sync Data',
                onTap: () => _syncData(context),
              ),
            ],
          ),

          // Security Card
          settingsCard(
            title: 'SECURITY',
            children: [
              settingsTile(
                icon: Icons.lock_outline,
                title: 'Change Password',
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (context) => const ChangePasswordDialog(),
                  );
                },
              ),
              settingsTile(
                icon: Icons.logout,
                title: 'Logout',
                iconColor: Colors.red,
                showDivider: false,
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Text(
                        'Confirm Logout',
                        style: TextStyle(
                          color: primaryColor,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      content: Text(
                        'Are you sure you want to logout?',
                        style: TextStyle(
                          color: secondaryColor,
                          fontSize: 14,
                        ),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text(
                            'Cancel',
                            style: TextStyle(color: secondaryColor),
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            authProvider.signOut();
                            Navigator.pop(context);
                          },
                          child: const Text(
                            'Logout',
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}