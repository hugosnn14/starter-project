import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/data_sources/local/article_thumbnail_picker_data_source.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article_draft.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article_thumbnail.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/repository/article_repository.dart';

class InMemoryArticleRepository implements ArticleRepository {
  InMemoryArticleRepository({
    ArticleThumbnailPickerDataSource? thumbnailPickerDataSource,
  }) : _thumbnailPickerDataSource =
            thumbnailPickerDataSource ?? ArticleThumbnailPickerDataSourceImpl();

  final ArticleThumbnailPickerDataSource _thumbnailPickerDataSource;
  final List<ArticleEntity> _articles = [
    const ArticleEntity(
      id: '1',
      author: 'Ada Lovelace',
      title: 'Cities can reuse water better than we think',
      description:
          'A short piece about practical water reuse strategies that can be deployed right now.',
      url: 'https://example.com/articles/water-reuse',
      urlToImage: 'https://placehold.co/600x400/png?text=Water+Reuse',
      thumbnailPath: 'media/articles/1/thumbnail.png',
      publishedAt: '2026-03-24',
      content:
          'Water reuse is no longer a futuristic idea. Municipal systems can adopt small improvements that generate measurable impact in the short term.',
      status: 'published',
    ),
    const ArticleEntity(
      id: '2',
      author: 'Grace Hopper',
      title: 'Why public tech products need simpler writing',
      description:
          'Clarity in digital services is not decoration. It is part of whether a product actually works.',
      url: 'https://example.com/articles/simpler-writing',
      urlToImage: 'https://placehold.co/600x400/png?text=Simple+Writing',
      thumbnailPath: 'media/articles/2/thumbnail.png',
      publishedAt: '2026-03-22',
      content:
          'When interfaces are difficult to understand, the system fails before the user even starts. Clear text is product quality, not polish.',
      status: 'published',
    ),
    const ArticleEntity(
      id: '3',
      author: 'Katherine Johnson',
      title: 'Small teams win by finishing smaller scopes',
      description:
          'The fastest way to show quality is to close a small vertical slice end to end.',
      url: 'https://example.com/articles/small-scope',
      urlToImage: 'https://placehold.co/600x400/png?text=Small+Scope',
      thumbnailPath: 'media/articles/3/thumbnail.png',
      publishedAt: '2026-03-20',
      content:
          'Small scopes reduce uncertainty, make testing easier, and help teams prove reliability with less noise.',
      status: 'published',
    ),
  ];
  final List<ArticleEntity> _savedArticles = [];
  final Map<String, ArticleDraftEntity> _drafts = {};

  int _nextId = 4;

  @override
  Future<ArticleThumbnailEntity?> pickArticleThumbnail() {
    return _thumbnailPickerDataSource.pickThumbnail();
  }

  @override
  Future<List<ArticleEntity>> getArticles() async {
    return List.unmodifiable(_articles);
  }

  @override
  Future<List<ArticleEntity>> getMyArticles() async {
    return List.unmodifiable(_articles);
  }

  @override
  Future<ArticleEntity?> getArticleById(String articleId) async {
    for (final article in _articles) {
      if (article.id == articleId) {
        return article;
      }
    }
    return null;
  }

  @override
  Future<ArticleEntity> createArticle(
    ArticleEntity article, {
    required ArticleThumbnailEntity thumbnail,
  }) async {
    final createdArticle = ArticleEntity(
      id: (_nextId++).toString(),
      author: article.author,
      title: article.title,
      description: article.description,
      url:
          'https://example.com/articles/${DateTime.now().millisecondsSinceEpoch}',
      urlToImage: 'https://placehold.co/600x400/png?text=New+Article',
      thumbnailPath: 'media/articles/${_nextId - 1}/thumbnail.jpg',
      publishedAt: DateTime.now().toIso8601String().split('T').first,
      content: article.content,
      status: 'published',
    );

    _articles.insert(0, createdArticle);

    return createdArticle;
  }

  @override
  Future<ArticleEntity> updateArticle(
    String articleId,
    ArticleEntity article, {
    ArticleThumbnailEntity? thumbnail,
  }) async {
    final index = _articles.indexWhere((item) => item.id == articleId);
    if (index == -1) {
      throw StateError('Article not found');
    }

    final currentArticle = _articles[index];
    final updatedArticle = ArticleEntity(
      id: currentArticle.id,
      author: article.author,
      title: article.title,
      description: article.description,
      url: article.url,
      urlToImage: currentArticle.urlToImage,
      thumbnailPath: currentArticle.thumbnailPath,
      publishedAt: currentArticle.publishedAt,
      content: article.content,
      status: currentArticle.status,
    );

    _articles[index] = updatedArticle;
    return updatedArticle;
  }

  @override
  Future<void> archiveArticle(String articleId) async {
    _articles.removeWhere((item) => item.id == articleId);
    _savedArticles.removeWhere((item) => item.id == articleId);
  }

  @override
  Future<DataState<List<ArticleEntity>>> getNewsArticles() async {
    return DataSuccess(List.unmodifiable(_articles));
  }

  @override
  Future<List<ArticleEntity>> getSavedArticles() async {
    return List.unmodifiable(_savedArticles);
  }

  @override
  Future<void> saveArticle(ArticleEntity article) async {
    final alreadySaved = _savedArticles.any((item) => item.id == article.id);
    if (!alreadySaved) {
      _savedArticles.add(article);
    }
  }

  @override
  Future<void> removeArticle(ArticleEntity article) async {
    _savedArticles.removeWhere((item) => item.id == article.id);
  }

  @override
  Future<ArticleDraftEntity?> getArticleDraft(String draftKey) async {
    return _drafts[draftKey];
  }

  @override
  Future<void> saveArticleDraft(ArticleDraftEntity draft) async {
    _drafts[draft.draftKey] = draft;
  }

  @override
  Future<void> clearArticleDraft(String draftKey) async {
    _drafts.remove(draftKey);
  }
}
