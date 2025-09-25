import 'package:firebase_auth/firebase_auth.dart' show User;
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../super/super_shell.dart' show SuperShell;
import '../controllers/auth_controller.dart';
// import 'package:Livora_parker/features/jobs/presentation/jobs_list_screen.dart'; // Keep if used elsewhere, not directly in this snippet
import '../../../../design_system.dart'; // Import your DesignSystem

// ignore: unused_import
import 'onboarding_screen.dart'; // Keep if used elsewhere, not directly in this snippet

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  // Keeping _formKey for now, though not strictly needed if fields are commented out.
  // Can be removed if email/password fields are permanently gone.
  final _formKey = GlobalKey<FormBuilderState>();

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Welcome Back!',
          style: DesignSystem.textTheme.headlineMedium,
        ),
        backgroundColor: DesignSystem.backgroundLight,
        elevation: 0,
        centerTitle: true, // Centered the app bar title for better aesthetics
      ),
      body: Container(
        decoration: BoxDecoration(color: DesignSystem.backgroundDark),
        padding: const EdgeInsets.all(DesignSystem.spacing24),
        child: Center(
          child: SingleChildScrollView(
            child: FormBuilder(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo or app icon placeholder - using serviceimage.png here
                  Image.asset(
                    'assets/service1.png', // Using your specified image here
                    height: 300, // Made bigger
                    width: 300,  // Made bigger
                    // You might want to adjust color or fit based on your image
                  ),
                  const SizedBox(height: DesignSystem.spacing40),

                  Text(
                    'Login to your Account',
                    style: DesignSystem.textTheme.headlineLarge
                        ?.copyWith(color: DesignSystem.textPrimary),
                  ),
                  const SizedBox(height: DesignSystem.spacing20),

                  // --- COMMENTED OUT: Email Text Field ---
                  // FormBuilderTextField(
                  //   name: 'email',
                  //   decoration: InputDecoration(
                  //     labelText: 'Email',
                  //     hintText: 'Enter your email',
                  //     labelStyle: DesignSystem.textTheme.bodyMedium
                  //         ?.copyWith(color: DesignSystem.textSecondary),
                  //     hintStyle: DesignSystem.textTheme.bodyMedium
                  //         ?.copyWith(color: DesignSystem.textTertiary),
                  //     prefixIcon: Icon(Icons.email,
                  //         color: DesignSystem.textSecondary.withOpacity(0.7)),
                  //     contentPadding:
                  //         const EdgeInsets.all(DesignSystem.spacing16),
                  //     enabledBorder: OutlineInputBorder(
                  //       borderRadius:
                  //           BorderRadius.circular(DesignSystem.radiusMedium),
                  //       borderSide: BorderSide(
                  //           color: DesignSystem.textSecondary.withOpacity(0.3),
                  //           width: 1),
                  //     ),
                  //     focusedBorder: OutlineInputBorder(
                  //       borderRadius:
                  //           BorderRadius.circular(DesignSystem.radiusMedium),
                  //       borderSide:
                  //           const BorderSide(color: DesignSystem.primaryColor, width: 2),
                  //     ),
                  //     errorBorder: OutlineInputBorder(
                  //       borderRadius:
                  //           BorderRadius.circular(DesignSystem.radiusMedium),
                  //       borderSide:
                  //           const BorderSide(color: DesignSystem.errorColor, width: 1),
                  //     ),
                  //     focusedErrorBorder: OutlineInputBorder(
                  //       borderRadius:
                  //           BorderRadius.circular(DesignSystem.radiusMedium),
                  //       borderSide:
                  //           const BorderSide(color: DesignSystem.errorColor, width: 2),
                  //     ),
                  //     filled: true,
                  //     fillColor: DesignSystem.backgroundLighter,
                  //   ),
                  //   style: DesignSystem.textTheme.bodyMedium
                  //       ?.copyWith(color: DesignSystem.textPrimary),
                  //   validator: (value) =>
                  //       (value == null || value.isEmpty) ? 'Email cannot be empty' : null,
                  // ),
                  // const SizedBox(height: DesignSystem.spacing16), // Also comment out if no email field
                  // --- END COMMENTED OUT ---

                  // --- COMMENTED OUT: Password Text Field ---
                  // FormBuilderTextField(
                  //   name: 'password',
                  //   obscureText: true,
                  //   decoration: InputDecoration(
                  //     labelText: 'Password',
                  //     hintText: 'Enter your password',
                  //     labelStyle: DesignSystem.textTheme.bodyMedium
                  //         ?.copyWith(color: DesignSystem.textSecondary),
                  //     hintStyle: DesignSystem.textTheme.bodyMedium
                  //         ?.copyWith(color: DesignSystem.textTertiary),
                  //     prefixIcon: Icon(Icons.lock,
                  //         color: DesignSystem.textSecondary.withOpacity(0.7)),
                  //     contentPadding:
                  //         const EdgeInsets.all(DesignSystem.spacing16),
                  //     enabledBorder: OutlineInputBorder(
                  //       borderRadius:
                  //           BorderRadius.circular(DesignSystem.radiusMedium),
                  //       borderSide: BorderSide(
                  //           color: DesignSystem.textSecondary.withOpacity(0.3),
                  //           width: 1),
                  //     ),
                  //     focusedBorder: OutlineInputBorder(
                  //       borderRadius:
                  //           BorderRadius.circular(DesignSystem.radiusMedium),
                  //       borderSide:
                  //           const BorderSide(color: DesignSystem.primaryColor, width: 2),
                  //     ),
                  //     errorBorder: OutlineInputBorder(
                  //       borderRadius:
                  //           BorderRadius.circular(DesignSystem.radiusMedium),
                  //       borderSide:
                  //           const BorderSide(color: DesignSystem.errorColor, width: 1),
                  //     ),
                  //     focusedErrorBorder: OutlineInputBorder(
                  //       borderRadius:
                  //           BorderRadius.circular(DesignSystem.radiusMedium),
                  //       borderSide:
                  //           const BorderSide(color: DesignSystem.errorColor, width: 2),
                  //     ),
                  //     filled: true,
                  //     fillColor: DesignSystem.backgroundLighter,
                  //   ),
                  //   style: DesignSystem.textTheme.bodyMedium
                  //       ?.copyWith(color: DesignSystem.textPrimary),
                  //   validator: (value) => (value == null || value.isEmpty)
                  //       ? 'Password cannot be empty'
                  //       : null,
                  // ),
                  // const SizedBox(height: DesignSystem.spacing32), // Also comment out if no password field
                  // --- END COMMENTED OUT ---

                  // --- COMMENTED OUT: Sign in with Email Button ---
                  // SizedBox(
                  //   width: double.infinity,
                  //   height: DesignSystem.spacing56,
                  //   child: ElevatedButton.icon(
                  //     icon: authState.isLoading
                  //         ? const SizedBox.shrink() // Hide icon when loading
                  //         : const Icon(Icons.login,
                  //             color: DesignSystem.textPrimary),
                  //     label: authState.isLoading
                  //         ? const SizedBox(
                  //             width: DesignSystem.spacing20,
                  //             height: DesignSystem.spacing20,
                  //             child: CircularProgressIndicator(
                  //               color: DesignSystem.textPrimary,
                  //               strokeWidth: 2,
                  //             ),
                  //           )
                  //         : Text(
                  //             'Sign in with Email',
                  //             style: DesignSystem.textTheme.labelLarge
                  //                 ?.copyWith(color: DesignSystem.textPrimary),
                  //           ),
                  //     onPressed: authState.isLoading
                  //         ? null
                  //         : () {
                  //             final valid =
                  //                 _formKey.currentState?.saveAndValidate() ?? false;
                  //             if (!valid) return;
                  //             final values = _formKey.currentState!.value;
                  //             ref.read(authControllerProvider.notifier).signIn(
                  //                   values['email'] as String,
                  //                   values['password'] as String,
                  //                 );
                  //           },
                  //     style: ElevatedButton.styleFrom(
                  //       backgroundColor: DesignSystem.primaryColor,
                  //       shape: RoundedRectangleBorder(
                  //         borderRadius:
                  //             BorderRadius.circular(DesignSystem.radiusMedium),
                  //       ),
                  //       elevation: 5,
                  //       shadowColor: DesignSystem.primaryColor.withOpacity(0.5),
                  //     ),
                  //   ),
                  // ),
                  // const SizedBox(height: DesignSystem.spacing16), // Also comment out this spacing
                  // --- END COMMENTED OUT ---

                  // Add some extra space before the Google button if the other buttons are commented out
                  const SizedBox(height: DesignSystem.spacing10),

                  SizedBox(
                    width: double.infinity,
                    height: DesignSystem.spacing64,
                    child: OutlinedButton.icon(
                      icon: Image.asset(
                        'assets/gf.png', // Changed to gf.png
                        height: DesignSystem.spacing48,
                        width: DesignSystem.spacing48, // Explicitly set width
                      ),
                      label: authState.isLoading
                          ? const SizedBox(
                              width: DesignSystem.spacing20,
                              height: DesignSystem.spacing20,
                              child: CircularProgressIndicator(
                                color: DesignSystem.textPrimary,
                                strokeWidth: 2,
                              ),
                            )
                          : Text(
                              "Sign in with Google",
                              style: DesignSystem.textTheme.labelLarge
                                  ?.copyWith(color: DesignSystem.textPrimary),
                            ),
                      onPressed: authState.isLoading
                          ? null
                          : () async {
                              final user = await ref
                                  .read(authControllerProvider.notifier)
                                  .signInWithGoogle();

                              if (user != null) {
                                print("====== Google User Signed In ======");
                                print("👤 Name: ${user.displayName}");
                                print("📧 Email: ${user.email}");
                                print("🆔 UID: ${user.uid}");
                                print("🖼️ PhotoURL: ${user.photoURL}");
                                print("===================================");

          // 🔑 Get Firebase ID Token here
          final idToken = await user.getIdToken();
          print("🔑 Firebase ID Token: $idToken");
          print("===================================");

                                _onLoginSuccess(user);
                              } else {
                                print("❌ Google Sign-in failed");
                                // Optionally show a SnackBar or AlertDialog for failure
                              }
                            },
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(
                            color: DesignSystem.textSecondary.withOpacity(0.5), width: 1),
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(DesignSystem.radiusMedium),
                        ),
                        backgroundColor: DesignSystem.backgroundLight,
                        foregroundColor: DesignSystem.textPrimary,
                        elevation: 3, // Added slight elevation for Google button
                        shadowColor: DesignSystem.textSecondary.withOpacity(0.3),
                      ),
                    ),
                  ),
                
                  const SizedBox(height: DesignSystem.spacing24),
                  // Row(
                  //   mainAxisAlignment: MainAxisAlignment.center,
                  //   children: [
                  //     Text(
                  //       "Don't have an account?",
                  //       style: DesignSystem.textTheme.bodyMedium
                  //           ?.copyWith(color: DesignSystem.textSecondary),
                  //     ),
                  //     TextButton(
                  //       onPressed: () {
                  //         // Navigate to registration/onboarding screen
                  //         Navigator.push(
                  //           context,
                  //           MaterialPageRoute(
                  //               builder: (context) => const OnboardingScreen()), // Assuming OnboardingScreen is your signup
                  //         );
                  //       },
                  //       child: Text(
                  //         "Sign up",
                  //         style: DesignSystem.textTheme.labelLarge?.copyWith(
                  //           color: DesignSystem.secondaryColor,
                  //           fontWeight: FontWeight.bold,
                  //         ),
                  //       ),
                  //     ),
                  //   ],
                  // ),
               
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _onLoginSuccess(User user) {
    // Navigate to SuperShell or appropriate screen
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const SuperShell()),
    );
  }
}