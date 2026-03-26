import 'package:news_app_clean_architecture/core/usecase/usecase.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article_draft.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/repository/article_repository.dart';

class GetArticleDraftUseCase implements UseCase<ArticleDraftEntity?, String> {
  GetArticleDraftUseCase(this._articleRepository);

  final ArticleRepository _articleRepository;

  @override
  Future<ArticleDraftEntity?> call({String? params}) {
    return _articleRepository.getArticleDraft(params!);
  }
}
