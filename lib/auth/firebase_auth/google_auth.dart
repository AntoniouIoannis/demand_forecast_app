import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

final _googleSignIn = GoogleSignIn.instance;

Future<UserCredential?> googleSignInFunc() async {
  if (kIsWeb) {
    // Once signed in, return the UserCredential
    return await FirebaseAuth.instance.signInWithPopup(GoogleAuthProvider());
  }

  await signOutWithGoogle().catchError((_) => null);
  final account = await _googleSignIn.authenticate();
  final auth = account.authentication;
  final authz = await account.authorizationClient
      .authorizationForScopes(['profile', 'email']);

  if (auth.idToken == null || authz == null) {
    return null;
  }
  final credential = GoogleAuthProvider.credential(
      idToken: auth.idToken, accessToken: authz.accessToken);
  return FirebaseAuth.instance.signInWithCredential(credential);
}

Future signOutWithGoogle() => _googleSignIn.signOut();
