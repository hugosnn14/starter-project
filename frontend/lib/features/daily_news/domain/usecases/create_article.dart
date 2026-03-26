import 'package:news_app_clean_architecture/core/usecase/usecase.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/repository/article_repository.dart';

class CreateArticleParams {
  final String authorName;
  final String title;
  final String description;
  final String content;

  const CreateArticleParams({
    required this.authorName,
    required this.title,
    required this.description,
    required this.content,
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
    );
  }
}
