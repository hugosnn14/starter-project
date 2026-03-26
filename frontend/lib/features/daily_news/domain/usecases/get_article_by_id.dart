import 'package:news_app_clean_architecture/core/usecase/usecase.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/repository/article_repository.dart';

class GetArticleByIdUseCase implements UseCase<ArticleEntity?, String> {
  final ArticleRepository _articleRepository;

  GetArticleByIdUseCase(this._articleRepository);

  @override
  Future<ArticleEntity?> call({String? params}) {
    return _articleRepository.getArticleById(params!);
  }
}
