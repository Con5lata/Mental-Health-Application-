import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        centerTitle: true,
        title: const Text(
          'Settings',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.menu, color: Colors.black),
          onPressed: () {},
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Profile Card
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: const BorderSide(color: Colors.grey),
              ),
              child: ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Colors.grey,
                  child: Text('AS', style: TextStyle(color: Colors.white)),
                ),
                title: const Text(
                  'Alex Smith',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: const Text(
                  'alex.smith@university.edu',
                  style: TextStyle(color: Colors.grey),
                ),
                onTap: () {},
              ),
            ),
            const SizedBox(height: 10),

            // Settings Options
            _buildSettingsTile('Manage 2FA', Icons.arrow_forward_ios),
            _buildSettingsTile('Notification Preferences', Icons.arrow_forward_ios),
            _buildSettingsTile('Privacy Policy', Icons.arrow_forward_ios),
            _buildSettingsTile('Terms of Service', Icons.arrow_forward_ios),
            _buildSettingsTile('About', Icons.arrow_forward_ios),

            const SizedBox(height: 10),

            // Sign Out Button
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: const BorderSide(color: Colors.grey),
              ),
              child: ListTile(
                title: const Center(
                  child: Text(
                    'Sign Out',
                    style: TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                onTap: () {},
              ),
            ),

            const Spacer(),

            // Footer
            const Center(
              child: Text(
                'Settings Screen',
                style: TextStyle(color: Colors.grey),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsTile(String title, IconData icon) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Colors.grey),
      ),
      child: ListTile(
        title: Text(title),
        trailing: Icon(icon, size: 16, color: Colors.grey),
        onTap: () {},
      ),
    );
  }
}
