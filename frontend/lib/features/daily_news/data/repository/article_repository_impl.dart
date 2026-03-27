import 'package:dio/dio.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/data_sources/local/article_thumbnail_picker_data_source.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/data_sources/local/article_draft_local_data_source.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/data_sources/local/saved_article_local_data_source.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/data_sources/remote/article_auth_remote_data_source.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/data_sources/remote/article_firestore_remote_data_source.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/data_sources/remote/article_news_remote_data_source.dart';
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
    required ArticleNewsRemoteDataSource newsRemoteDataSource,
    required SavedArticleLocalDataSource savedArticleLocalDataSource,
    required ArticleStorageRemoteDataSource storageRemoteDataSource,
    required ArticleThumbnailPickerDataSource thumbnailPickerDataSource,
  })  : _authRemoteDataSource = authRemoteDataSource,
        _articleDraftLocalDataSource = articleDraftLocalDataSource,
        _firestoreRemoteDataSource = firestoreRemoteDataSource,
        _newsRemoteDataSource = newsRemoteDataSource,
        _savedArticleLocalDataSource = savedArticleLocalDataSource,
        _storageRemoteDataSource = storageRemoteDataSource,
        _thumbnailPickerDataSource = thumbnailPickerDataSource;

  final ArticleAuthRemoteDataSource _authRemoteDataSource;
  final ArticleDraftLocalDataSource _articleDraftLocalDataSource;
  final ArticleFirestoreRemoteDataSource _firestoreRemoteDataSource;
  final ArticleNewsRemoteDataSource _newsRemoteDataSource;
  final SavedArticleLocalDataSource _savedArticleLocalDataSource;
  final ArticleStorageRemoteDataSource _storageRemoteDataSource;
  final ArticleThumbnailPickerDataSource _thumbnailPickerDataSource;

  @override
  Future<ArticleThumbnailEntity?> pickArticleThumbnail() {
    return _thumbnailPickerDataSource.pickThumbnail();
  }

  @override
  Future<List<ArticleEntity>> getArticles() async {
    Object? firestoreError;
    Object? newsApiError;
    List<ArticleEntity> firestoreArticles = const [];
    List<ArticleEntity> newsApiArticles = const [];

    try {
      final articleDocuments =
          await _firestoreRemoteDataSource.getPublishedArticles();
      firestoreArticles = await _mapArticles(articleDocuments);
    } catch (error) {
      firestoreError = error;
    }

    try {
      newsApiArticles = await _getNewsApiArticles();
    } catch (error) {
      newsApiError = error;
    }

    final mergedArticles = _mergeArticles(
      firestoreArticles: firestoreArticles,
      newsApiArticles: newsApiArticles,
    );

    if (mergedArticles.isNotEmpty) {
      return mergedArticles;
    }

    if (firestoreError != null) {
      throw firestoreError;
    }

    if (newsApiError != null) {
      throw newsApiError;
    }

    return const [];
  }

  @override
  Future<List<ArticleEntity>> getMyArticles() async {
    final authorId = await _authRemoteDataSource.getCurrentUserId();
    final articleDocuments =
        await _firestoreRemoteDataSource.getArticlesByAuthorId(authorId);

    return _mapArticles(articleDocuments);
  }

  @override
  Future<ArticleEntity?> getArticleById(String articleId) async {
    if (_newsRemoteDataSource.isNewsApiArticleId(articleId)) {
      final newsArticle = await _newsRemoteDataSource.getArticleById(articleId);
      return newsArticle?.toEntity();
    }

    final articleDocument =
        await _firestoreRemoteDataSource.getArticleById(articleId);

    if (articleDocument != null) {
      return _mapArticle(articleDocument);
    }

    final newsArticle = await _newsRemoteDataSource.getArticleById(articleId);
    return newsArticle?.toEntity();
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
      thumbnailPath: thumbnailPath,
      publishedAt: DateTime.now().toIso8601String().split('T').first,
      content: article.content,
      status: 'published',
    );
  }

  @override
  Future<ArticleEntity> updateArticle(
    String articleId,
    ArticleEntity article, {
    ArticleThumbnailEntity? thumbnail,
  }) async {
    final currentArticleDocument =
        await _firestoreRemoteDataSource.getArticleById(articleId);

    if (currentArticleDocument == null) {
      throw StateError('No se encontro el articulo a editar.');
    }

    final currentThumbnailPath =
        currentArticleDocument['thumbnailPath'] as String?;
    final nextThumbnailPath = _resolveNextThumbnailPath(
      articleId: articleId,
      currentThumbnailPath: currentThumbnailPath,
      thumbnail: thumbnail,
    );

    if (thumbnail != null) {
      await _storageRemoteDataSource.uploadThumbnail(
        thumbnailPath: nextThumbnailPath!,
        thumbnail: thumbnail,
      );
    }

    await _firestoreRemoteDataSource.updateArticle(
      articleId: articleId,
      authorName: article.author ?? '',
      title: article.title ?? '',
      description: article.description ?? '',
      content: article.content ?? '',
      thumbnailPath: nextThumbnailPath,
      sourceUrl: article.url,
    );

    final updatedArticle = await getArticleById(articleId);

    if (updatedArticle != null) {
      return updatedArticle;
    }

    final fallbackThumbnailUrl =
        nextThumbnailPath == null || nextThumbnailPath.isEmpty
            ? kDefaultImage
            : await _storageRemoteDataSource.getDownloadUrl(nextThumbnailPath);

    return ArticleEntity(
      id: articleId,
      author: article.author,
      title: article.title,
      description: article.description,
      url: article.url,
      urlToImage: fallbackThumbnailUrl,
      thumbnailPath: nextThumbnailPath,
      publishedAt: _formatFallbackPublishedAt(
        currentArticleDocument['publishedAt'],
      ),
      content: article.content,
      status: currentArticleDocument['status'] as String? ?? 'published',
    );
  }

  @override
  Future<void> archiveArticle(String articleId) async {
    await _firestoreRemoteDataSource.archiveArticle(articleId);
    await _savedArticleLocalDataSource.removeArticle(
      ArticleEntity(id: articleId),
    );
  }

  @override
  Future<DataState<List<ArticleEntity>>> getNewsArticles() async {
    try {
      final articles = await _getNewsApiArticles();
      return DataSuccess<List<ArticleEntity>>(articles);
    } on DioError catch (error) {
      return DataFailed<List<ArticleEntity>>(error);
    } catch (error) {
      return DataFailed<List<ArticleEntity>>(
        DioError(
          requestOptions: RequestOptions(path: '/top-headlines'),
          error: error,
          type: DioErrorType.other,
        ),
      );
    }
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

  Future<List<ArticleEntity>> _getNewsApiArticles() async {
    final newsArticles = await _newsRemoteDataSource.getTopHeadlines();
    return newsArticles.map((article) => article.toEntity()).toList();
  }

  List<ArticleEntity> _mergeArticles({
    required List<ArticleEntity> firestoreArticles,
    required List<ArticleEntity> newsApiArticles,
  }) {
    final mergedArticles = <ArticleEntity>[];
    final seenKeys = <String>{};

    void addUniqueArticles(Iterable<ArticleEntity> articles) {
      for (final article in articles) {
        final mergeKey = _buildMergeKey(article);
        if (seenKeys.add(mergeKey)) {
          mergedArticles.add(article);
        }
      }
    }

    // Keep authored Firestore articles first and append external headlines
    // without duplicating stories that point to the same source URL.
    addUniqueArticles(firestoreArticles);
    addUniqueArticles(newsApiArticles);

    return mergedArticles;
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

  String? _resolveNextThumbnailPath({
    required String articleId,
    required String? currentThumbnailPath,
    required ArticleThumbnailEntity? thumbnail,
  }) {
    if (thumbnail == null) {
      return currentThumbnailPath;
    }

    if (currentThumbnailPath != null && currentThumbnailPath.isNotEmpty) {
      return currentThumbnailPath;
    }

    return _buildThumbnailPath(articleId, thumbnail);
  }

  String _formatFallbackPublishedAt(Object? publishedAt) {
    if (publishedAt is DateTime) {
      return publishedAt.toIso8601String().split('T').first;
    }

    return DateTime.now().toIso8601String().split('T').first;
  }

  String _buildMergeKey(ArticleEntity article) {
    final normalizedUrl = article.url?.trim();
    if (normalizedUrl != null && normalizedUrl.isNotEmpty) {
      return 'url:$normalizedUrl';
    }

    final normalizedId = article.id?.trim();
    if (normalizedId != null && normalizedId.isNotEmpty) {
      return 'id:$normalizedId';
    }

    return 'title:${article.title ?? ''}|date:${article.publishedAt ?? ''}';
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
