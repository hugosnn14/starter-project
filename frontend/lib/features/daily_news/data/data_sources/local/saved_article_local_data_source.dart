import 'package:news_app_clean_architecture/features/daily_news/data/data_sources/local/DAO/article_dao.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/models/article.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article.dart';

abstract class SavedArticleLocalDataSource {
  Future<List<ArticleEntity>> getSavedArticles();

  Future<void> saveArticle(ArticleEntity article);

  Future<void> removeArticle(ArticleEntity article);
}

class SavedArticleLocalDataSourceImpl implements SavedArticleLocalDataSource {
  SavedArticleLocalDataSourceImpl({
    required ArticleDao articleDao,
  }) : _articleDao = articleDao;

  final ArticleDao _articleDao;

  @override
  Future<List<ArticleEntity>> getSavedArticles() async {
    final savedArticles = await _articleDao.getArticles();
    return savedArticles.map((article) => article.toEntity()).toList();
  }

  @override
  Future<void> saveArticle(ArticleEntity article) async {
    await _articleDao.insertArticle(
      ArticleModel.fromEntity(article),
    );
  }

  @override
  Future<void> removeArticle(ArticleEntity article) async {
    await _articleDao.deleteArticle(
      ArticleModel.fromEntity(article),
    );
  }
}
