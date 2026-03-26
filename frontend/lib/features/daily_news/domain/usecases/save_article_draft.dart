import 'package:news_app_clean_architecture/core/usecase/usecase.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article_draft.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/repository/article_repository.dart';

class SaveArticleDraftUseCase implements UseCase<void, ArticleDraftEntity> {
  SaveArticleDraftUseCase(this._articleRepository);

  final ArticleRepository _articleRepository;

  @override
  Future<void> call({ArticleDraftEntity? params}) {
    return _articleRepository.saveArticleDraft(params!);
  }
}
