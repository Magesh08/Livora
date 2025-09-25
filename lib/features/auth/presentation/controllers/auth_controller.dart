import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../data/auth_service.dart' show AuthService;

final firebaseAuthProvider =
    Provider<FirebaseAuth>((ref) => FirebaseAuth.instance);

final authServiceProvider =
    Provider<AuthService>((ref) => AuthService(ref.read(firebaseAuthProvider)));

final authStateProvider = StreamProvider<User?>((ref) {
  return ref.read(authServiceProvider).authStateChanges();
});

class AuthController extends StateNotifier<AsyncValue<User?>> {
  AuthController(this.ref) : super(const AsyncValue.loading()) {
    _sub = ref.read(authStateProvider.stream).listen(
      (user) => state = AsyncValue.data(user),
      onError: (e, st) => state = AsyncValue.error(e, st),
    );
  }

  final Ref ref;
  late final StreamSubscription<User?> _sub;

  Future<User?> signIn(String email, String password) async {
    state = const AsyncValue.loading();
    try {
      final user =
          await ref.read(authServiceProvider).signInWithEmail(email, password);
      state = AsyncValue.data(user);
      return user;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return null;
    }
  }

  Future<User?> register(String email, String password) async {
    state = const AsyncValue.loading();
    try {
      final user =
          await ref.read(authServiceProvider).registerWithEmail(email, password);
      state = AsyncValue.data(user);
      return user;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return null;
    }
  }

  Future<User?> signInWithGoogle() async {
    state = const AsyncValue.loading();
    try {
      final user = await ref.read(authServiceProvider).signInWithGoogle();
      state = AsyncValue.data(user);
      return user;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return null;
    }
  }

  Future<void> signOut() async {
    await ref.read(authServiceProvider).signOut();
  }

  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }
}

final authControllerProvider =
    StateNotifierProvider<AuthController, AsyncValue<User?>>(
  (ref) => AuthController(ref),
);
