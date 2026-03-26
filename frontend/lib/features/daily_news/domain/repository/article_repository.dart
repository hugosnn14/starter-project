import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article_draft.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article_thumbnail.dart';

abstract class ArticleRepository {
  Future<ArticleThumbnailEntity?> pickArticleThumbnail();

  Future<List<ArticleEntity>> getArticles();

  Future<ArticleEntity?> getArticleById(String articleId);

  Future<ArticleEntity> createArticle(
    ArticleEntity article, {
    required ArticleThumbnailEntity thumbnail,
  });

  // Legacy API kept so previous files remain available in the tree.
  Future<DataState<List<ArticleEntity>>> getNewsArticles();

  Future<List<ArticleEntity>> getSavedArticles();

  Future<void> saveArticle(ArticleEntity article);

  Future<void> removeArticle(ArticleEntity article);

  Future<ArticleDraftEntity?> getArticleDraft(String draftKey);

  Future<void> saveArticleDraft(ArticleDraftEntity draft);

  Future<void> clearArticleDraft(String draftKey);
}
