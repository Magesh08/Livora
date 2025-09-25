import 'package:flutter/material.dart';
import '../../../../core/router/app_routes.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Livora Onboarding'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pushNamed(AppRoutes.login),
              child: const Text('Login'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pushNamed(AppRoutes.register),
              child: const Text('Register'),
            ),
          ],
        ),
      ),
    );
  }
}


