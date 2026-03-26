import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article_thumbnail.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/repository/article_repository.dart';

class FakeArticleRepository implements ArticleRepository {
  FakeArticleRepository({
    List<ArticleEntity> articles = const [],
    List<ArticleEntity> savedArticles = const [],
    this.pickedThumbnail,
    this.shouldThrowOnGetArticles = false,
    this.shouldThrowOnPickArticleThumbnail = false,
    this.shouldThrowOnGetArticleById = false,
    this.shouldThrowOnCreateArticle = false,
    this.shouldThrowOnGetSavedArticles = false,
    this.shouldThrowOnSaveArticle = false,
    this.shouldThrowOnRemoveArticle = false,
  })  : _articles = List<ArticleEntity>.of(articles),
        _savedArticles = List<ArticleEntity>.of(savedArticles);

  final List<ArticleEntity> _articles;
  final List<ArticleEntity> _savedArticles;
  final ArticleThumbnailEntity? pickedThumbnail;
  final bool shouldThrowOnGetArticles;
  final bool shouldThrowOnPickArticleThumbnail;
  final bool shouldThrowOnGetArticleById;
  final bool shouldThrowOnCreateArticle;
  final bool shouldThrowOnGetSavedArticles;
  final bool shouldThrowOnSaveArticle;
  final bool shouldThrowOnRemoveArticle;

  @override
  Future<ArticleThumbnailEntity?> pickArticleThumbnail() async {
    if (shouldThrowOnPickArticleThumbnail) {
      throw Exception('pickArticleThumbnail failed');
    }

    return pickedThumbnail;
  }

  @override
  Future<List<ArticleEntity>> getArticles() async {
    if (shouldThrowOnGetArticles) {
      throw Exception('getArticles failed');
    }

    return List<ArticleEntity>.unmodifiable(_articles);
  }

  @override
  Future<ArticleEntity?> getArticleById(String articleId) async {
    if (shouldThrowOnGetArticleById) {
      throw Exception('getArticleById failed');
    }

    for (final article in _articles) {
      if (article.id == articleId) {
        return article;
      }
    }

    return null;
  }

  @override
  Future<ArticleEntity> createArticle(ArticleEntity article) async {
    if (shouldThrowOnCreateArticle) {
      throw Exception('createArticle failed');
    }

    _articles.add(article);
    return article;
  }

  @override
  Future<DataState<List<ArticleEntity>>> getNewsArticles() async {
    return DataSuccess<List<ArticleEntity>>(
      List<ArticleEntity>.unmodifiable(_articles),
    );
  }

  @override
  Future<List<ArticleEntity>> getSavedArticles() async {
    if (shouldThrowOnGetSavedArticles) {
      throw Exception('getSavedArticles failed');
    }

    return List<ArticleEntity>.unmodifiable(_savedArticles);
  }

  @override
  Future<void> saveArticle(ArticleEntity article) async {
    if (shouldThrowOnSaveArticle) {
      throw Exception('saveArticle failed');
    }

    _savedArticles.add(article);
  }

  @override
  Future<void> removeArticle(ArticleEntity article) async {
    if (shouldThrowOnRemoveArticle) {
      throw Exception('removeArticle failed');
    }

    _savedArticles.removeWhere((item) => item.id == article.id);
  }
}
