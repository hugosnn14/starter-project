import 'package:news_app_clean_architecture/core/usecase/usecase.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article_thumbnail.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/repository/article_repository.dart';

class SelectArticleThumbnailUseCase
    implements UseCase<ArticleThumbnailEntity?, void> {
  final ArticleRepository _articleRepository;

  SelectArticleThumbnailUseCase(this._articleRepository);

  @override
  Future<ArticleThumbnailEntity?> call({void params}) {
    return _articleRepository.pickArticleThumbnail();
  }
}
