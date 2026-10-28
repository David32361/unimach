import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:unimatch_user/core/errors/auth_failure.dart';
import 'package:unimatch_user/core/validators/auth_validators.dart';

class AuthService {
  AuthService(this._auth);

  final FirebaseAuth _auth;
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;
  Future<void>? _googleInitialization;
  DateTime? _verificationSentAt;
  String? _verificationUid;

  Stream<User?> authStateChanges() => _auth.userChanges();

  Future<UserCredential> register(String email, String password) {
    final error = AuthValidators.password(password);
    if (error != null) throw AuthFailure(error, code: 'weak-password');
    return _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
  }

  Future<UserCredential> signIn(String email, String password) {
    return _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
  }

  Future<UserCredential> signInWithGoogle() async {
    try {
      await _ensureGoogleInitialized();
      final googleUser = await _googleSignIn.authenticate();
      final idToken = googleUser.authentication.idToken;
      if (idToken == null) {
        throw const AuthFailure(
          'Google no devolvio una credencial valida.',
          code: 'missing-google-id-token',
        );
      }
      return _auth.signInWithCredential(
        GoogleAuthProvider.credential(idToken: idToken),
      );
    } on GoogleSignInException catch (error) {
      throw AuthFailure.fromGoogle(error);
    }
  }

  Future<void> sendPasswordReset(String email) async {
    await _auth.setLanguageCode('es');
    await _auth.sendPasswordResetEmail(email: email.trim());
  }

  Future<void> sendEmailVerification() async {
    final user = _auth.currentUser;
    if (user == null) {
      throw const AuthFailure('Inicia sesión para verificar tu correo.');
    }
    if (user.emailVerified) return;
    final now = DateTime.now();
    if (_verificationUid == user.uid &&
        _verificationSentAt != null &&
        now.difference(_verificationSentAt!).inSeconds < 60) {
      throw const AuthFailure(
        'Espera un minuto antes de solicitar otro enlace.',
      );
    }
    _verificationUid = user.uid;
    _verificationSentAt = now;
    try {
      await _auth.setLanguageCode('es');
      // Firebase applies the action in the browser first. Continue then opens
      // the verified Android App Link; the app reloads Auth, never trusts a URL.
      await user.sendEmailVerification(
        ActionCodeSettings(
          url: 'https://unimatch-daniel-2026.web.app/email-verified/',
          handleCodeInApp: false,
        ),
      );
    } catch (_) {
      _verificationSentAt = null;
      rethrow;
    }
  }

  Future<bool> refreshEmailVerification() async {
    if (_auth.currentUser == null) return false;
    await _auth.currentUser!.reload();
    final user = _auth.currentUser;
    if (user == null) return false;
    await user.getIdToken(true);
    return user.emailVerified;
  }

  Future<void> signOut() async {
    await _auth.signOut();
    try {
      await _ensureGoogleInitialized();
      await _googleSignIn.signOut();
    } on GoogleSignInException {
      // Firebase Auth is the source of truth and is already signed out.
    }
  }

  Future<void> _ensureGoogleInitialized() {
    return _googleInitialization ??= _googleSignIn.initialize();
  }
}
