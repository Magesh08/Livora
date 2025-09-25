import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../design_system.dart';
import '../auth/presentation/screens/login_screen.dart';

class ProfileWalletScreen extends StatelessWidget {
  const ProfileWalletScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(title: const Text('Profile & Wallet')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: DesignSystem.backgroundLight,
              borderRadius: BorderRadius.circular(16),
              boxShadow: DesignSystem.cardShadow,
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundImage: user?.photoURL != null ? NetworkImage(user!.photoURL!) : null,
                  child: user?.photoURL == null ? const Icon(Icons.person) : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user?.displayName ?? 'No Name',
                        style: DesignSystem.textTheme.titleLarge,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        user?.email ?? 'No Email',
                        style: DesignSystem.textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                OutlinedButton(onPressed: () {}, child: const Text('Edit')),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: DesignSystem.backgroundLight,
              borderRadius: BorderRadius.circular(16),
              boxShadow: DesignSystem.cardShadow,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Wallet Balance', style: DesignSystem.textTheme.titleLarge),
                const SizedBox(height: 8),
                Text('\$245.00', style: DesignSystem.textTheme.displaySmall?.copyWith(color: DesignSystem.accentColor)),
                const SizedBox(height: 12),
                Row(
                  children: [
                    FilledButton(onPressed: () {}, child: const Text('Add Funds')),
                    const SizedBox(width: 12),
                    OutlinedButton(onPressed: () {}, child: const Text('Transactions')),
                  ],
                )
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text('Settings', style: DesignSystem.textTheme.headlineSmall),
          const SizedBox(height: 8),
          _tile(Icons.notifications_rounded, 'Notifications', () {}),
          _tile(Icons.language_rounded, 'Language', () {}),
          _tile(Icons.color_lens_rounded, 'Theme', () {}),
          _tile(Icons.logout_rounded, 'Logout', () async {
            await FirebaseAuth.instance.signOut();
            if (context.mounted) {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
                (route) => false,
              );
            }
          }),
        ],
      ),
    );
  }

  Widget _tile(IconData icon, String title, VoidCallback onTap) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: DesignSystem.backgroundLight,
        borderRadius: BorderRadius.circular(12),
        boxShadow: DesignSystem.cardShadow,
      ),
      child: ListTile(
        leading: Icon(icon),
        title: Text(title),
        trailing: const Icon(Icons.chevron_right_rounded),
        onTap: onTap,
      ),
    );
  }
}


