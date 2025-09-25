import 'package:flutter/material.dart';
import '../../features/auth/presentation/screens/splash_screen.dart';
import '../../features/auth/presentation/screens/onboarding_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/shell/driver_shell.dart';
import '../../features/shell/host_shell.dart';
import '../../features/super/super_shell.dart';
import '../../features/jobs/presentation/job_details_screen.dart';
import '../../features/jobs/presentation/job_category_screen.dart';

// ew
class AppRoutes {
  AppRoutes._();

  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String register = '/register';
  static const String driverShell = '/driver';
  static const String hostShell = '/host';
  static const String superShell = '/super';
  static const String jobDetails = '/job_details';
  static const String jobCategory = '/job_category';
//.
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash:
        return MaterialPageRoute(builder: (_) => const SplashScreen());
      case onboarding:
        return MaterialPageRoute(builder: (_) => const OnboardingScreen());
      case login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case register:
        return MaterialPageRoute(builder: (_) => const RegisterScreen());
      case driverShell:
        return MaterialPageRoute(builder: (_) => const DriverShell());
      case hostShell:
        return MaterialPageRoute(builder: (_) => const HostShell());
      case superShell:
        return MaterialPageRoute(builder: (_) => const SuperShell());
      case jobDetails:
        final id = settings.arguments as String?;
        return MaterialPageRoute(
          builder: (_) => JobDetailsScreen(jobId: id ?? ''),
        );
      case jobCategory:
        return MaterialPageRoute(builder: (_) => const JobCategoryScreen());
      default:
        return MaterialPageRoute(
          builder: (_) =>
              const Scaffold(body: Center(child: Text('Route not found'))),
        );
    }
  }
}
