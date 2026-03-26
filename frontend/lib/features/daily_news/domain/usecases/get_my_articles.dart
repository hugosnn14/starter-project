import 'package:news_app_clean_architecture/core/usecase/usecase.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/repository/article_repository.dart';

class GetMyArticlesUseCase implements UseCase<List<ArticleEntity>, void> {
  GetMyArticlesUseCase(this._articleRepository);

  final ArticleRepository _articleRepository;

  @override
  Future<List<ArticleEntity>> call({void params}) {
    return _articleRepository.getMyArticles();
  }
}
