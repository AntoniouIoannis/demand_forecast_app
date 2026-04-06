import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

// https://firebase.flutter.dev/docs/auth/social/#yahoo
Future<UserCredential?> yahooSignInFunc() async {
  final yahooProvider = OAuthProvider('yahoo.com');

  if (kIsWeb) {
    return await FirebaseAuth.instance.signInWithPopup(yahooProvider);
  }
  return await FirebaseAuth.instance.signInWithProvider(yahooProvider);
}
