import 'package:firebase_auth/firebase_auth.dart';

abstract class ArticleAuthRemoteDataSource {
  String getCurrentUserId();
}

class ArticleAuthRemoteDataSourceImpl implements ArticleAuthRemoteDataSource {
  ArticleAuthRemoteDataSourceImpl({
    FirebaseAuth? firebaseAuth,
  }) : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance;

  final FirebaseAuth _firebaseAuth;

  @override
  String getCurrentUserId() {
    final currentUser = _firebaseAuth.currentUser;

    if (currentUser == null) {
      throw StateError(
        'No authenticated Firebase user is available for article writes.',
      );
    }

    return currentUser.uid;
  }
}
