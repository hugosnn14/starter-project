import 'package:news_app_clean_architecture/core/usecase/usecase.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article_thumbnail.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/repository/article_repository.dart';

class UpdateArticleParams {
  const UpdateArticleParams({
    required this.articleId,
    required this.authorName,
    required this.title,
    required this.description,
    required this.content,
    this.sourceUrl,
    this.thumbnail,
  });

  final String articleId;
  final String authorName;
  final String title;
  final String description;
  final String content;
  final String? sourceUrl;
  final ArticleThumbnailEntity? thumbnail;
}

class UpdateArticleUseCase
    implements UseCase<ArticleEntity, UpdateArticleParams> {
  UpdateArticleUseCase(this._articleRepository);

  final ArticleRepository _articleRepository;

  @override
  Future<ArticleEntity> call({UpdateArticleParams? params}) {
    return _articleRepository.updateArticle(
      params!.articleId,
      ArticleEntity(
        author: params.authorName,
        title: params.title,
        description: params.description,
        url: params.sourceUrl,
        content: params.content,
      ),
      thumbnail: params.thumbnail,
    );
  }
}
