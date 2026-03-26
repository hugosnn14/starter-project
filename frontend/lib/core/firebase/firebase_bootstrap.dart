import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

import '../../firebase_options.dart';

Future<void> bootstrapFirebaseForAndroidApp() async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await _ensureAnonymousSession(FirebaseAuth.instance);
}

Future<void> _ensureAnonymousSession(FirebaseAuth auth) async {
  if (auth.currentUser != null) {
    return;
  }

  try {
    await auth.signInAnonymously();
  } on FirebaseAuthException catch (error) {
    if (error.code == 'operation-not-allowed') {
      throw StateError(
        'Firebase Anonymous Auth must be enabled for the Android bootstrap.',
      );
    }

    rethrow;
  }
}
