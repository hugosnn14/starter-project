import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article.dart';

abstract class ArticleRepository {
  Future<List<ArticleEntity>> getArticles();

  Future<ArticleEntity?> getArticleById(int articleId);

  Future<ArticleEntity> createArticle(ArticleEntity article);
}
