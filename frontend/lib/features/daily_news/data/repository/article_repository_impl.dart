import 'package:news_app_clean_architecture/features/daily_news/data/data_sources/local/article_thumbnail_picker_data_source.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/data_sources/local/article_draft_local_data_source.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/data_sources/local/saved_article_local_data_source.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/data_sources/remote/article_auth_remote_data_source.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/data_sources/remote/article_firestore_remote_data_source.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/data_sources/remote/article_storage_remote_data_source.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/models/article.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article_draft.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article_thumbnail.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/repository/article_repository.dart';

import '../../../../core/constants/constants.dart';
import '../../../../core/resources/data_state.dart';

class ArticleRepositoryImpl implements ArticleRepository {
  ArticleRepositoryImpl({
    required ArticleAuthRemoteDataSource authRemoteDataSource,
    required ArticleDraftLocalDataSource articleDraftLocalDataSource,
    required ArticleFirestoreRemoteDataSource firestoreRemoteDataSource,
    required SavedArticleLocalDataSource savedArticleLocalDataSource,
    required ArticleStorageRemoteDataSource storageRemoteDataSource,
    required ArticleThumbnailPickerDataSource thumbnailPickerDataSource,
  })  : _authRemoteDataSource = authRemoteDataSource,
        _articleDraftLocalDataSource = articleDraftLocalDataSource,
        _firestoreRemoteDataSource = firestoreRemoteDataSource,
        _savedArticleLocalDataSource = savedArticleLocalDataSource,
        _storageRemoteDataSource = storageRemoteDataSource,
        _thumbnailPickerDataSource = thumbnailPickerDataSource;

  final ArticleAuthRemoteDataSource _authRemoteDataSource;
  final ArticleDraftLocalDataSource _articleDraftLocalDataSource;
  final ArticleFirestoreRemoteDataSource _firestoreRemoteDataSource;
  final SavedArticleLocalDataSource _savedArticleLocalDataSource;
  final ArticleStorageRemoteDataSource _storageRemoteDataSource;
  final ArticleThumbnailPickerDataSource _thumbnailPickerDataSource;

  @override
  Future<ArticleThumbnailEntity?> pickArticleThumbnail() {
    return _thumbnailPickerDataSource.pickThumbnail();
  }

  @override
  Future<List<ArticleEntity>> getArticles() async {
    final articleDocuments =
        await _firestoreRemoteDataSource.getPublishedArticles();

    return _mapArticles(articleDocuments);
  }

  @override
  Future<ArticleEntity?> getArticleById(String articleId) async {
    final articleDocument =
        await _firestoreRemoteDataSource.getArticleById(articleId);

    if (articleDocument == null) {
      return null;
    }

    return _mapArticle(articleDocument);
  }

  @override
  Future<ArticleEntity> createArticle(
    ArticleEntity article, {
    required ArticleThumbnailEntity thumbnail,
  }) async {
    final articleId = _firestoreRemoteDataSource.createArticleId();
    final authorId = await _authRemoteDataSource.getCurrentUserId();
    final thumbnailPath = _buildThumbnailPath(articleId, thumbnail);

    await _firestoreRemoteDataSource.createArticle(
      articleId: articleId,
      authorId: authorId,
      authorName: article.author ?? '',
      title: article.title ?? '',
      description: article.description ?? '',
      content: article.content ?? '',
      thumbnailPath: thumbnailPath,
      sourceUrl: article.url,
    );

    try {
      await _storageRemoteDataSource.uploadThumbnail(
        thumbnailPath: thumbnailPath,
        thumbnail: thumbnail,
      );
    } catch (_) {
      await _rollbackArticleDocument(articleId);
      rethrow;
    }

    final createdArticle = await getArticleById(articleId);

    if (createdArticle != null) {
      return createdArticle;
    }

    final fallbackThumbnailUrl =
        await _storageRemoteDataSource.getDownloadUrl(thumbnailPath);

    return ArticleEntity(
      id: articleId,
      author: article.author,
      title: article.title,
      description: article.description,
      url: article.url,
      urlToImage: fallbackThumbnailUrl,
      publishedAt: DateTime.now().toIso8601String().split('T').first,
      content: article.content,
    );
  }

  @override
  Future<DataState<List<ArticleEntity>>> getNewsArticles() async {
    final articles = await getArticles();
    return DataSuccess<List<ArticleEntity>>(articles);
  }

  @override
  Future<List<ArticleEntity>> getSavedArticles() async {
    return _savedArticleLocalDataSource.getSavedArticles();
  }

  @override
  Future<void> saveArticle(ArticleEntity article) async {
    final savedArticles = await _savedArticleLocalDataSource.getSavedArticles();
    final alreadySaved = savedArticles.any((item) => item.id == article.id);

    if (!alreadySaved) {
      await _savedArticleLocalDataSource.saveArticle(article);
    }
  }

  @override
  Future<void> removeArticle(ArticleEntity article) async {
    await _savedArticleLocalDataSource.removeArticle(article);
  }

  @override
  Future<ArticleDraftEntity?> getArticleDraft(String draftKey) {
    return _articleDraftLocalDataSource.getDraft(draftKey);
  }

  @override
  Future<void> saveArticleDraft(ArticleDraftEntity draft) {
    return _articleDraftLocalDataSource.saveDraft(draft);
  }

  @override
  Future<void> clearArticleDraft(String draftKey) {
    return _articleDraftLocalDataSource.clearDraft(draftKey);
  }

  Future<List<ArticleEntity>> _mapArticles(
    List<Map<String, dynamic>> articleDocuments,
  ) {
    return Future.wait(
      articleDocuments.map(_mapArticle),
    );
  }

  Future<ArticleEntity> _mapArticle(
      Map<String, dynamic> articleDocument) async {
    final thumbnailUrl = await _resolveThumbnailUrl(
      articleDocument['thumbnailPath'] as String?,
    );

    final articleModel = ArticleModel.fromFirestoreData(
      articleDocument,
      thumbnailUrl: thumbnailUrl,
    );

    return articleModel.toEntity();
  }

  Future<String?> _resolveThumbnailUrl(String? thumbnailPath) async {
    if (thumbnailPath == null || thumbnailPath.isEmpty) {
      return kDefaultImage;
    }

    try {
      return await _storageRemoteDataSource.getDownloadUrl(thumbnailPath);
    } catch (_) {
      return kDefaultImage;
    }
  }

  Future<void> _rollbackArticleDocument(String articleId) async {
    try {
      await _firestoreRemoteDataSource.deleteArticle(articleId);
    } catch (_) {
      // Best effort rollback. The original upload error remains the primary
      // failure and can be inspected during manual verification.
    }
  }

  String _buildThumbnailPath(
    String articleId,
    ArticleThumbnailEntity thumbnail,
  ) {
    final source = (thumbnail.fileName ?? thumbnail.path).toLowerCase();
    final dotIndex = source.lastIndexOf('.');
    final extension = dotIndex == -1 || dotIndex == source.length - 1
        ? 'jpg'
        : source.substring(dotIndex + 1);

    return 'media/articles/$articleId/thumbnail.$extension';
  }
}
