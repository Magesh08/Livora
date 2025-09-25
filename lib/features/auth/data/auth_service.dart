import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class AuthService {
  final FirebaseAuth _firebaseAuth;

  AuthService(this._firebaseAuth);

  Stream<User?> authStateChanges() => _firebaseAuth.authStateChanges();

  Future<User?> signInWithGoogle() async {
    if (kIsWeb) {
      // Web flow
      final googleProvider = GoogleAuthProvider();
      final cred = await _firebaseAuth.signInWithPopup(googleProvider);
      return cred.user;
    } else {
      // Mobile flow

      // First, initialize the GoogleSignIn instance with serverClientId
      await GoogleSignIn.instance.initialize(
        serverClientId: "154627419463-ljhla0no8q868fqr4ud1lh2ia7usu1ho.apps.googleusercontent.com",
      );

      // Then invoke authenticate()
      final googleUser = await GoogleSignIn.instance.authenticate(
        scopeHint: ['email', 'profile'],
      );

      if (googleUser == null) return null;

      final googleAuth = googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.idToken,
        idToken: googleAuth.idToken,
      );

      final cred = await _firebaseAuth.signInWithCredential(credential);
      return cred.user;
    }
  }

  Future<User?> signInWithEmail(String email, String password) async {
    final cred = await _firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    return cred.user;
  }

  Future<User?> registerWithEmail(String email, String password) async {
    final cred = await _firebaseAuth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    return cred.user;
  }

  Future<void> signOut() async {
    await _firebaseAuth.signOut();
    try {
      await GoogleSignIn.instance.signOut();
    } catch (_) {}
  }
}
