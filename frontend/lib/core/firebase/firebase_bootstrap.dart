import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

import '../constants/constants.dart';
import '../../firebase_options.dart';

Future<void> bootstrapFirebaseForAndroidApp() async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await _warmAnonymousSessionIfAvailable(FirebaseAuth.instance);
}

Future<void> _warmAnonymousSessionIfAvailable(FirebaseAuth auth) async {
  if (!enableAnonymousAuth) {
    return;
  }

  if (auth.currentUser != null) {
    return;
  }

  try {
    await auth.signInAnonymously();
  } on FirebaseAuthException catch (error) {
    if (_isAnonymousAuthUnavailable(error)) {
      return;
    }

    rethrow;
  }
}

bool _isAnonymousAuthUnavailable(FirebaseAuthException error) {
  return error.code == 'operation-not-allowed' ||
      error.code == 'admin-restricted-operation';
}
