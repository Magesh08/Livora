import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/router/app_routes.dart';

class SplashScreen extends ConsumerWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!Navigator.of(context).mounted) return;
      Navigator.of(context).pushReplacementNamed(AppRoutes.superShell);
    });

    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}


