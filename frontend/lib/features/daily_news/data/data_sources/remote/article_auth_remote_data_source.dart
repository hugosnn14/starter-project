import 'package:firebase_auth/firebase_auth.dart';

abstract class ArticleAuthRemoteDataSource {
  Future<String> getCurrentUserId();
}

class ArticleAuthRemoteDataSourceImpl implements ArticleAuthRemoteDataSource {
  ArticleAuthRemoteDataSourceImpl({
    FirebaseAuth? firebaseAuth,
  }) : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance;

  final FirebaseAuth _firebaseAuth;

  @override
  Future<String> getCurrentUserId() async {
    final currentUser = _firebaseAuth.currentUser;

    if (currentUser == null) {
      try {
        final credential = await _firebaseAuth.signInAnonymously();
        final anonymousUser = credential.user;

        if (anonymousUser == null) {
          throw StateError(
            'No se pudo iniciar sesion en Firebase para publicar el articulo.',
          );
        }

        return anonymousUser.uid;
      } on FirebaseAuthException catch (error) {
        if (_isAnonymousAuthUnavailable(error)) {
          throw StateError(
            'Firebase Auth no permite el acceso anonimo en este proyecto. '
            'Activa Anonymous sign-in en Firebase Console o usa otro metodo '
            'de autenticacion.',
          );
        }

        rethrow;
      }
    }

    return currentUser.uid;
  }

  bool _isAnonymousAuthUnavailable(FirebaseAuthException error) {
    return error.code == 'operation-not-allowed' ||
        error.code == 'admin-restricted-operation';
  }
}
