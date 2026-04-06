import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

Future<UserCredential?> microsoftSignInFunc({
  List<String> scopes = const <String>[],
  String tenantId = 'common',
}) async {
  final microsoftProvider = OAuthProvider('microsoft.com');

  for (final scope in scopes) {
    if (scope.trim().isNotEmpty) {
      microsoftProvider.addScope(scope.trim());
    }
  }

  if (tenantId.trim().isNotEmpty) {
    microsoftProvider.setCustomParameters(<String, String>{
      'tenant': tenantId.trim(),
    });
  }

  if (kIsWeb) {
    return FirebaseAuth.instance.signInWithPopup(microsoftProvider);
  }
  return FirebaseAuth.instance.signInWithProvider(microsoftProvider);
}
