import 'package:news_app_clean_architecture/core/usecase/usecase.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/repository/article_repository.dart';

class ArchiveArticleUseCase implements UseCase<void, String> {
  ArchiveArticleUseCase(this._articleRepository);

  final ArticleRepository _articleRepository;

  @override
  Future<void> call({String? params}) {
    return _articleRepository.archiveArticle(params!);
  }
}
