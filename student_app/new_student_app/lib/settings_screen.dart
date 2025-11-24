import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'account_screen.dart'; // Ensure this file exists or create it

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // Local state variables
  bool _isDarkMode = false;
  bool _notificationsEnabled = true;
  bool _biometricEnabled = false;

  Future<void> _signOut(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Sign Out', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        content: Text('Are you sure you want to sign out?', style: GoogleFonts.poppins(color: Colors.grey[700])),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel', style: GoogleFonts.poppins(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            ),
            onPressed: () => Navigator.pop(context, true),
            child: Text('Sign Out', style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await FirebaseAuth.instance.signOut();
      if (context.mounted) {
        // Navigate back to the very start (Login)
        Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: Text(
          "Settings",
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            color: const Color(0xFF1A1C1E),
          ),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: const Color(0xFFF8F9FA),
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // --- PROFILE SECTION ---
          _buildSectionHeader("Account"),
          Container(
            decoration: _boxDecoration(),
            child: Column(
              children: [
                ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  leading: CircleAvatar(
                    radius: 28,
                    backgroundColor: Colors.indigo.shade50,
                    backgroundImage: user?.photoURL != null ? NetworkImage(user!.photoURL!) : null,
                    child: user?.photoURL == null
                        ? Icon(Icons.person, color: Colors.indigo.shade400, size: 28)
                        : null,
                  ),
                  title: Text(
                    user?.displayName ?? "MindCare User",
                    style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 16),
                  ),
                  subtitle: Text(
                    user?.email ?? "No email",
                    style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey),
                  ),
                  trailing: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.edit, size: 18, color: Colors.grey),
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const AccountScreen()),
                    );
                  },
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),

          // --- PREFERENCES SECTION ---
          _buildSectionHeader("Preferences"),
          Container(
            decoration: _boxDecoration(),
            child: Column(
              children: [
                _buildSwitchTile(
                  title: "Dark Mode",
                  icon: Icons.dark_mode_outlined,
                  iconColor: Colors.purple.shade400,
                  value: _isDarkMode,
                  onChanged: (val) {
                    setState(() => _isDarkMode = val);
                    // Note: To make this apply globally, you'd need a ThemeProvider
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(val ? "Dark mode enabled (UI demo)" : "Light mode enabled")),
                    );
                  },
                ),
                _buildDivider(),
                _buildSwitchTile(
                  title: "Notifications",
                  icon: Icons.notifications_outlined,
                  iconColor: Colors.orange.shade400,
                  value: _notificationsEnabled,
                  onChanged: (val) {
                    setState(() => _notificationsEnabled = val);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(val ? "Notifications enabled" : "Notifications disabled")),
                    );
                  },
                ),
                _buildDivider(),
                _buildSwitchTile(
                  title: "Biometric Lock",
                  icon: Icons.fingerprint,
                  iconColor: Colors.blue.shade400,
                  value: _biometricEnabled,
                  onChanged: (val) {
                    setState(() => _biometricEnabled = val);
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // --- GENERAL SECTION ---
          _buildSectionHeader("General"),
          Container(
            decoration: _boxDecoration(),
            child: Column(
              children: [
                _buildActionTile(
                  title: "Help & Support",
                  icon: Icons.help_outline,
                  iconColor: Colors.teal.shade400,
                  onTap: () {
                    // Navigate to support or show dialog
                  },
                ),
                _buildDivider(),
                _buildActionTile(
                  title: "Privacy Policy",
                  icon: Icons.lock_outline,
                  iconColor: Colors.green.shade400,
                  onTap: () {},
                ),
                _buildDivider(),
                _buildActionTile(
                  title: "About MindCare",
                  icon: Icons.info_outline,
                  iconColor: Colors.indigo.shade400,
                  onTap: () {
                    showAboutDialog(
                      context: context,
                      applicationName: "MindCare",
                      applicationVersion: "1.0.0",
                      applicationLegalese: "© 2025 MindCare Inc.",
                    );
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 30),

          // --- LOGOUT BUTTON ---
          SizedBox(
            width: double.infinity,
            child: TextButton.icon(
              onPressed: () => _signOut(context),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: Colors.red.shade50,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              icon: Icon(Icons.logout, color: Colors.red.shade600),
              label: Text(
                "Log Out",
                style: GoogleFonts.poppins(
                  color: Colors.red.shade700,
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Center(
            child: Text(
              "Version 1.0.0",
              style: GoogleFonts.poppins(color: Colors.grey.shade400, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  // --- HELPER WIDGETS ---

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, left: 4),
      child: Text(
        title.toUpperCase(),
        style: GoogleFonts.poppins(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          letterSpacing: 1.2,
          color: Colors.grey.shade500,
        ),
      ),
    );
  }

  BoxDecoration _boxDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: Colors.grey.shade100),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.03),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required IconData icon,
    required Color iconColor,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: iconColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: iconColor, size: 20),
      ),
      title: Text(
        title,
        style: GoogleFonts.poppins(fontWeight: FontWeight.w500, fontSize: 15),
      ),
      trailing: Switch.adaptive(
        value: value,
        onChanged: onChanged,
        activeColor: Colors.indigo,
      ),
    );
  }

  Widget _buildActionTile({
    required String title,
    required IconData icon,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: iconColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: iconColor, size: 20),
      ),
      title: Text(
        title,
        style: GoogleFonts.poppins(fontWeight: FontWeight.w500, fontSize: 15),
      ),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
    );
  }

  Widget _buildDivider() {
    return Divider(height: 1, thickness: 1, color: Colors.grey.shade50, indent: 60);
  }
}