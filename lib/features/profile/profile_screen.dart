import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../design_system.dart';
import '../auth/presentation/screens/login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: DesignSystem.backgroundLight,
      appBar: AppBar(
        title: Text('Profile', style: DesignSystem.textTheme.headlineMedium),
        backgroundColor: DesignSystem.backgroundLight,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(DesignSystem.spacing16),
        child: Column(
          children: [
            // Profile Header
            Container(
              padding: const EdgeInsets.all(DesignSystem.spacing24),
              decoration: BoxDecoration(
                color: DesignSystem.backgroundLight,
                borderRadius: BorderRadius.circular(DesignSystem.radiusMedium),
              ),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: DesignSystem.primaryColor,
                    backgroundImage: user?.photoURL != null
                        ? NetworkImage(user!.photoURL!)
                        : null,
                    child: user?.photoURL == null
                        ? const Icon(
                            Icons.person,
                            size: 40,
                            color: Colors.white,
                          )
                        : null,
                  ),
                  const SizedBox(height: DesignSystem.spacing16),
                  Text(
                    user?.displayName ?? 'User Name',
                    style: DesignSystem.textTheme.titleLarge,
                  ),
                  const SizedBox(height: DesignSystem.spacing8),
                  Text(
                    user?.email ?? 'user@example.com',
                    style: DesignSystem.textTheme.bodyMedium?.copyWith(
                      color: DesignSystem.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: DesignSystem.spacing24),

            // Profile Options
            _buildProfileOption(
              icon: Icons.edit,
              title: 'Edit Profile',
              onTap: () {},
            ),
            _buildProfileOption(
              icon: Icons.notifications,
              title: 'Notifications',
              onTap: () {},
            ),
            _buildProfileOption(
              icon: Icons.security,
              title: 'Privacy & Security',
              onTap: () {},
            ),
            _buildProfileOption(
              icon: Icons.help,
              title: 'Help & Support',
              onTap: () {},
            ),
            _buildProfileOption(icon: Icons.info, title: 'About', onTap: () {}),
            _buildProfileOption(
              icon: Icons.logout,
              title: 'Logout',
              onTap: () async {
                await FirebaseAuth.instance.signOut();
                if (context.mounted) {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                    (route) => false,
                  );
                }
              },
              isDestructive: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileOption({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: DesignSystem.spacing12),
      color: DesignSystem.backgroundLight,
      child: ListTile(
        leading: Icon(
          icon,
          color: isDestructive
              ? DesignSystem.errorColor
              : DesignSystem.primaryColor,
        ),
        title: Text(
          title,
          style: DesignSystem.textTheme.titleMedium?.copyWith(
            color: isDestructive
                ? DesignSystem.errorColor
                : DesignSystem.textPrimary,
          ),
        ),
        trailing: const Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: DesignSystem.textSecondary,
        ),
        onTap: onTap,
      ),
    );
  }
}
