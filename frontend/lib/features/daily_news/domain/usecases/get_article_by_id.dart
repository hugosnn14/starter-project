import 'package:news_app_clean_architecture/core/usecase/usecase.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/repository/article_repository.dart';

class GetArticleByIdUseCase implements UseCase<ArticleEntity?, int> {
  final ArticleRepository _articleRepository;

  GetArticleByIdUseCase(this._articleRepository);

  @override
  Future<ArticleEntity?> call({int? params}) {
    return _articleRepository.getArticleById(params!);
  }
}
