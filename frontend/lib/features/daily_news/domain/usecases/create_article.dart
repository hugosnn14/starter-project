import 'package:news_app_clean_architecture/core/usecase/usecase.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article_thumbnail.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/repository/article_repository.dart';

class CreateArticleParams {
  final String authorName;
  final String title;
  final String description;
  final String content;
  final ArticleThumbnailEntity thumbnail;

  const CreateArticleParams({
    required this.authorName,
    required this.title,
    required this.description,
    required this.content,
    required this.thumbnail,
  });
}

class CreateArticleUseCase
    implements UseCase<ArticleEntity, CreateArticleParams> {
  final ArticleRepository _articleRepository;

  CreateArticleUseCase(this._articleRepository);

  @override
  Future<ArticleEntity> call({CreateArticleParams? params}) {
    return _articleRepository.createArticle(
      ArticleEntity(
        author: params!.authorName,
        title: params.title,
        description: params.description,
        content: params.content,
      ),
      thumbnail: params.thumbnail,
    );
  }
}
