import 'package:flutter_test/flutter_test.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/data_sources/remote/article_news_remote_data_source.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/data_sources/local/article_draft_local_data_source.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/data_sources/local/article_thumbnail_picker_data_source.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/data_sources/local/saved_article_local_data_source.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/data_sources/remote/article_auth_remote_data_source.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/data_sources/remote/article_firestore_remote_data_source.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/data_sources/remote/article_storage_remote_data_source.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/models/article.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/models/article_thumbnail.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/repository/article_repository_impl.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article_draft.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article_thumbnail.dart';

void main() {
  late ArticleRepositoryImpl repository;
  late _FakeArticleFirestoreRemoteDataSource firestoreRemoteDataSource;
  late _FakeArticleNewsRemoteDataSource newsRemoteDataSource;
  late _FakeSavedArticleLocalDataSource savedArticleLocalDataSource;
  late _FakeArticleStorageRemoteDataSource storageRemoteDataSource;

  setUp(() {
    firestoreRemoteDataSource = _FakeArticleFirestoreRemoteDataSource();
    newsRemoteDataSource = _FakeArticleNewsRemoteDataSource();
    savedArticleLocalDataSource = _FakeSavedArticleLocalDataSource();
    storageRemoteDataSource = _FakeArticleStorageRemoteDataSource();
    repository = ArticleRepositoryImpl(
      authRemoteDataSource: _FakeArticleAuthRemoteDataSource(),
      articleDraftLocalDataSource: _FakeArticleDraftLocalDataSource(),
      firestoreRemoteDataSource: firestoreRemoteDataSource,
      newsRemoteDataSource: newsRemoteDataSource,
      savedArticleLocalDataSource: savedArticleLocalDataSource,
      storageRemoteDataSource: storageRemoteDataSource,
      thumbnailPickerDataSource: _FakeArticleThumbnailPickerDataSource(),
    );
  });

  group('getArticles', () {
    test('merges Firestore articles with NewsAPI headlines', () async {
      firestoreRemoteDataSource.publishedArticles = [
        _articleDocument(articleId: 'article-1'),
      ];
      newsRemoteDataSource.topHeadlines = const [
        ArticleModel(
          id: 'newsapi:headline-1',
          author: 'NewsAPI',
          title: 'External headline',
          description: 'Breaking update',
          url: 'https://example.com/external-headline',
          urlToImage: 'https://example.com/external-headline.png',
          publishedAt: '2026-03-26',
          content: 'External content',
          status: 'published',
        ),
      ];

      final articles = await repository.getArticles();

      expect(articles, hasLength(2));
      expect(articles.first.id, 'article-1');
      expect(articles.last.id, 'newsapi:headline-1');
    });

    test('returns NewsAPI headlines when Firestore loading fails', () async {
      firestoreRemoteDataSource.shouldThrowOnGetPublishedArticles = true;
      newsRemoteDataSource.topHeadlines = const [
        ArticleModel(
          id: 'newsapi:headline-2',
          title: 'Recovered from NewsAPI',
          url: 'https://example.com/recovered-headline',
          publishedAt: '2026-03-26',
          status: 'published',
        ),
      ];

      final articles = await repository.getArticles();

      expect(articles, hasLength(1));
      expect(articles.single.title, 'Recovered from NewsAPI');
    });
  });

  test('getArticleById resolves NewsAPI articles through the news source',
      () async {
    newsRemoteDataSource.topHeadlines = const [
      ArticleModel(
        id: 'newsapi:headline-3',
        title: 'Lookup by synthetic id',
        url: 'https://example.com/headline-lookup',
        publishedAt: '2026-03-26',
        status: 'published',
      ),
    ];

    final article = await repository.getArticleById('newsapi:headline-3');

    expect(article, isNotNull);
    expect(article?.title, 'Lookup by synthetic id');
  });

  group('updateArticle', () {
    test('keeps the current thumbnailPath when image does not change',
        () async {
      firestoreRemoteDataSource.articleById = _articleDocument(
        articleId: 'article-1',
        thumbnailPath: 'media/articles/article-1/thumbnail.jpg',
      );

      await repository.updateArticle(
        'article-1',
        const ArticleEntity(
          author: 'Hugo',
          title: 'Updated',
          description: 'Updated description',
          content: 'Updated content',
        ),
      );

      expect(
        firestoreRemoteDataSource.lastUpdatedThumbnailPath,
        'media/articles/article-1/thumbnail.jpg',
      );
      expect(storageRemoteDataSource.uploadCalls, isEmpty);
    });

    test('reuses the existing thumbnail path when a new image is uploaded',
        () async {
      firestoreRemoteDataSource.articleById = _articleDocument(
        articleId: 'article-2',
        thumbnailPath: 'media/articles/article-2/thumbnail.webp',
      );
      const thumbnail = ArticleThumbnailEntity(
        path: '/tmp/new-cover.png',
        fileName: 'new-cover.png',
      );

      await repository.updateArticle(
        'article-2',
        const ArticleEntity(
          author: 'Hugo',
          title: 'Updated',
          description: 'Updated description',
          content: 'Updated content',
        ),
        thumbnail: thumbnail,
      );

      expect(
        firestoreRemoteDataSource.lastUpdatedThumbnailPath,
        'media/articles/article-2/thumbnail.webp',
      );
      expect(
        storageRemoteDataSource.uploadCalls,
        [('media/articles/article-2/thumbnail.webp', thumbnail)],
      );
    });

    test('generates a new thumbnail path only when the article had none',
        () async {
      firestoreRemoteDataSource.articleById = _articleDocument(
        articleId: 'article-3',
      );
      const thumbnail = ArticleThumbnailEntity(
        path: '/tmp/cover.png',
        fileName: 'cover.png',
      );

      await repository.updateArticle(
        'article-3',
        const ArticleEntity(
          author: 'Hugo',
          title: 'Updated',
          description: 'Updated description',
          content: 'Updated content',
        ),
        thumbnail: thumbnail,
      );

      expect(
        firestoreRemoteDataSource.lastUpdatedThumbnailPath,
        'media/articles/article-3/thumbnail.png',
      );
      expect(
        storageRemoteDataSource.uploadCalls,
        [('media/articles/article-3/thumbnail.png', thumbnail)],
      );
    });

    test('keeps a missing thumbnailPath as null when image does not change',
        () async {
      firestoreRemoteDataSource.articleById = _articleDocument(
        articleId: 'article-4',
      );

      await repository.updateArticle(
        'article-4',
        const ArticleEntity(
          author: 'Hugo',
          title: 'Updated',
          description: 'Updated description',
          content: 'Updated content',
        ),
      );

      expect(firestoreRemoteDataSource.lastUpdatedThumbnailPath, isNull);
      expect(storageRemoteDataSource.uploadCalls, isEmpty);
    });
  });

  test('archiveArticle marks the article as archived instead of deleting it',
      () async {
    await repository.archiveArticle('article-9');

    expect(firestoreRemoteDataSource.archivedArticleIds, ['article-9']);
    expect(firestoreRemoteDataSource.deletedArticleIds, isEmpty);
    expect(savedArticleLocalDataSource.removedArticleIds, ['article-9']);
  });
}

Map<String, dynamic> _articleDocument({
  required String articleId,
  String? thumbnailPath,
}) {
  return {
    'id': articleId,
    'authorId': 'author-1',
    'authorName': 'Hugo',
    'title': 'Original',
    'description': 'Original description',
    'content': 'Original content',
    'thumbnailPath': thumbnailPath,
    'publishedAt': DateTime(2026, 3, 20),
  };
}

class _FakeArticleAuthRemoteDataSource implements ArticleAuthRemoteDataSource {
  @override
  Future<String> getCurrentUserId() async => 'author-1';
}

class _FakeArticleDraftLocalDataSource implements ArticleDraftLocalDataSource {
  @override
  Future<void> clearDraft(String draftKey) async {}

  @override
  Future<ArticleDraftEntity?> getDraft(String draftKey) async => null;

  @override
  Future<void> saveDraft(ArticleDraftEntity draft) async {}
}

class _FakeArticleFirestoreRemoteDataSource
    implements ArticleFirestoreRemoteDataSource {
  Map<String, dynamic>? articleById;
  List<Map<String, dynamic>> publishedArticles = [];
  String? lastUpdatedThumbnailPath;
  final List<String> archivedArticleIds = [];
  final List<String> deletedArticleIds = [];
  bool shouldThrowOnGetPublishedArticles = false;

  @override
  Future<void> archiveArticle(String articleId) async {
    archivedArticleIds.add(articleId);
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
  }) async {}

  @override
  String createArticleId() => 'generated-id';

  @override
  Future<void> deleteArticle(String articleId) async {
    deletedArticleIds.add(articleId);
  }

  @override
  Future<Map<String, dynamic>?> getArticleById(String articleId) async {
    return articleById;
  }

  @override
  Future<List<Map<String, dynamic>>> getArticlesByAuthorId(
    String authorId,
  ) async {
    return const [];
  }

  @override
  Future<List<Map<String, dynamic>>> getPublishedArticles() async {
    if (shouldThrowOnGetPublishedArticles) {
      throw StateError('getPublishedArticles failed');
    }

    return publishedArticles;
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
  }) async {
    lastUpdatedThumbnailPath = thumbnailPath;
    articleById = {
      ...?articleById,
      'id': articleId,
      'authorName': authorName,
      'title': title,
      'description': description,
      'content': content,
      'thumbnailPath': thumbnailPath,
      'sourceUrl': sourceUrl,
    };
  }
}

class _FakeSavedArticleLocalDataSource implements SavedArticleLocalDataSource {
  final List<String?> removedArticleIds = [];

  @override
  Future<List<ArticleEntity>> getSavedArticles() async => const [];

  @override
  Future<void> removeArticle(ArticleEntity article) async {
    removedArticleIds.add(article.id);
  }

  @override
  Future<void> saveArticle(ArticleEntity article) async {}
}

class _FakeArticleStorageRemoteDataSource
    implements ArticleStorageRemoteDataSource {
  final List<(String, ArticleThumbnailEntity)> uploadCalls = [];

  @override
  Future<String> getDownloadUrl(String thumbnailPath) async {
    return 'https://example.com/$thumbnailPath';
  }

  @override
  Future<void> uploadThumbnail({
    required String thumbnailPath,
    required ArticleThumbnailEntity thumbnail,
  }) async {
    uploadCalls.add((thumbnailPath, thumbnail));
  }
}

class _FakeArticleNewsRemoteDataSource implements ArticleNewsRemoteDataSource {
  List<ArticleModel> topHeadlines = const [];

  @override
  Future<ArticleModel?> getArticleById(String articleId) async {
    for (final article in topHeadlines) {
      if (article.id == articleId) {
        return article;
      }
    }

    return null;
  }

  @override
  Future<List<ArticleModel>> getTopHeadlines() async {
    return topHeadlines;
  }

  @override
  bool isNewsApiArticleId(String articleId) {
    return articleId.startsWith('newsapi:');
  }
}

class _FakeArticleThumbnailPickerDataSource
    implements ArticleThumbnailPickerDataSource {
  @override
  Future<ArticleThumbnailModel?> pickThumbnail() async => null;
}
