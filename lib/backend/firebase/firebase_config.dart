import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

Future initFirebase() async {
  if (kIsWeb ||
      defaultTargetPlatform == TargetPlatform.windows ||
      defaultTargetPlatform == TargetPlatform.macOS) {
    await Firebase.initializeApp(
        options: FirebaseOptions(
            apiKey: "AIzaSyBq1A9mmXd5loG0ysU1dAg1gDDRu51mO6k",
            authDomain: "demand-forecast-ian.firebaseapp.com",
            projectId: "demand-forecast-ian",
            storageBucket: "demand-forecast-ian.firebasestorage.app",
            messagingSenderId: "1072203670086",
            appId: "1:1072203670086:web:55c85ffd0c44220b432047"));
    if (kIsWeb) {
      await FirebaseAuth.instance.setPersistence(Persistence.LOCAL);
    }
  } else {
    await Firebase.initializeApp();
  }
}
