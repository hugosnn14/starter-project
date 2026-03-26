import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:news_app_clean_architecture/core/constants/constants.dart';

abstract class ArticleFirestoreRemoteDataSource {
  String createArticleId();

  Future<List<Map<String, dynamic>>> getPublishedArticles();

  Future<List<Map<String, dynamic>>> getArticlesByAuthorId(String authorId);

  Future<Map<String, dynamic>?> getArticleById(String articleId);

  Future<void> createArticle({
    required String articleId,
    required String authorId,
    required String authorName,
    required String title,
    required String description,
    required String content,
    required String thumbnailPath,
    String? sourceUrl,
  });

  Future<void> updateArticle({
    required String articleId,
    required String authorName,
    required String title,
    required String description,
    required String content,
    String? thumbnailPath,
    String? sourceUrl,
  });

  Future<void> archiveArticle(String articleId);

  Future<void> deleteArticle(String articleId);
}

class ArticleFirestoreRemoteDataSourceImpl
    implements ArticleFirestoreRemoteDataSource {
  ArticleFirestoreRemoteDataSourceImpl({
    FirebaseFirestore? firebaseFirestore,
  }) : _firebaseFirestore = firebaseFirestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firebaseFirestore;

  CollectionReference<Map<String, dynamic>> get _articlesCollection =>
      _firebaseFirestore.collection('articles');

  @override
  String createArticleId() {
    return _articlesCollection.doc().id;
  }

  @override
  Future<List<Map<String, dynamic>>> getPublishedArticles() async {
    final querySnapshot = await _articlesCollection
        .where('status', isEqualTo: 'published')
        .orderBy('publishedAt', descending: true)
        .get();

    return querySnapshot.docs.map(_normalizeArticleDocument).toList();
  }

  @override
  Future<List<Map<String, dynamic>>> getArticlesByAuthorId(
      String authorId) async {
    final querySnapshot = await _articlesCollection
        .where('authorId', isEqualTo: authorId)
        .orderBy('createdAt', descending: true)
        .get();

    return querySnapshot.docs.map(_normalizeArticleDocument).toList();
  }

  @override
  Future<Map<String, dynamic>?> getArticleById(String articleId) async {
    final documentSnapshot = await _articlesCollection.doc(articleId).get();

    if (!documentSnapshot.exists || documentSnapshot.data() == null) {
      return null;
    }

    return _normalizeArticleDocument(documentSnapshot);
  }

  @override
  Future<void> createArticle({
    required String articleId,
    required String authorId,
    required String authorName,
    required String title,
    required String description,
    required String content,
    required String thumbnailPath,
    String? sourceUrl,
  }) {
    return _articlesCollection.doc(articleId).set({
      'authorId': authorId,
      'authorName': authorName,
      'title': title,
      'description': description,
      'content': content,
      'category': categoryQuery,
      'thumbnailPath': thumbnailPath,
      'status': 'published',
      'publishedAt': FieldValue.serverTimestamp(),
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
      'sourceUrl': sourceUrl,
      'tags': const <String>[],
    });
  }

  @override
  Future<void> updateArticle({
    required String articleId,
    required String authorName,
    required String title,
    required String description,
    required String content,
    String? thumbnailPath,
    String? sourceUrl,
  }) {
    return _articlesCollection.doc(articleId).update({
      'authorName': authorName,
      'title': title,
      'description': description,
      'content': content,
      'thumbnailPath': thumbnailPath,
      'sourceUrl': sourceUrl,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  Future<void> archiveArticle(String articleId) {
    return _articlesCollection.doc(articleId).update({
      'status': 'archived',
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  Future<void> deleteArticle(String articleId) {
    return _articlesCollection.doc(articleId).delete();
  }

  Map<String, dynamic> _normalizeArticleDocument(
    DocumentSnapshot<Map<String, dynamic>> documentSnapshot,
  ) {
    final data = documentSnapshot.data() ?? <String, dynamic>{};

    return {
      'id': documentSnapshot.id,
      'authorId': data['authorId'],
      'authorName': data['authorName'],
      'title': data['title'],
      'description': data['description'],
      'content': data['content'],
      'category': data['category'],
      'thumbnailPath': data['thumbnailPath'],
      'status': data['status'],
      'publishedAt': _timestampToDateTime(data['publishedAt']),
      'createdAt': _timestampToDateTime(data['createdAt']),
      'updatedAt': _timestampToDateTime(data['updatedAt']),
      'sourceUrl': data['sourceUrl'],
      'tags': data['tags'],
    };
  }

  DateTime? _timestampToDateTime(Object? value) {
    if (value is Timestamp) {
      return value.toDate();
    }

    return null;
  }
}
